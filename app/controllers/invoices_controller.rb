# frozen_string_literal: true

# Invoice controller with search, sort, and filter
class InvoicesController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action :authenticate_user!
  before_action :set_invoice, only: %i[show edit update destroy issue]
  before_action :ensure_draft, only: %i[edit update]

  # GET /invoices or /invoices.json
  def index # rubocop:disable Metrics/AbcSize
    @invoices = current_user.invoices
    @invoices = @invoices.filter_status(params[:status]) if params[:status].present?
    @invoices = @invoices.search(params[:query]) if params[:query].present?
    @pagy, @invoices = pagy @invoices.reorder(sort_column => sort_direction), items: params.fetch(:count, 10)
  end

  def sort_column
    %w[number total status date due_date].include?(params[:sort]) ? params[:sort] : 'number'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  # GET /invoices/1 or /invoices/1.json
  def show
    @client = Client.find(@invoice.client_id).full_name
    respond_to do |format|
      format.html
      format.json
      format.pdf { send_pdf }
    end
  end

  # GET /invoices/new
  def new
    @invoice = Invoice.new
    @invoice.line_items.build
    @series = current_user.invoice_series.order(:prefix)
    # Default to the user's default series (prefix 'A') if it exists
    default = @series.find_by(prefix: 'A') || @series.first
    @invoice.series_id = default&.id
  end

  # GET /invoices/1/edit
  def edit
    @client = Client.find(@invoice.client_id)
    @series = current_user.invoice_series.order(:prefix)
  end

  # POST /invoices or /invoices.json
  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.user = current_user
    # Always born a draft: an invoice is never persisted as issued-but-unnumbered.
    # The Issue button then runs the same transition as the Issue action.
    @invoice.status = 'borrador'

    respond_to do |format|
      if save_and_maybe_issue
        format.html do
          redirect_to invoices_path, notice: I18n.t('factura_creada')
        end
        format.json { render :show, status: :created, location: @invoice }
      else
        # The form needs the series list back to re-render its selector.
        @series = current_user.invoice_series.order(:prefix)
        format.html { render :new, status: :unprocessable_entity }
        format.json do
          render json: @invoice.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def add_item
    helpers.fields model: Invoice.new do |f|
      render turbo_stream: turbo_stream.append(
        'line_items',
        partial: 'item_fields',
        locals: { f:, line_item: LineItem.new, turboid: Process.clock_gettime(Process::CLOCK_REALTIME, :millisecond) }
      )
    end
  end

  # PATCH/PUT /invoices/1 or /invoices/1.json
  def update
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html do
          redirect_to invoices_url,
                      notice: I18n.t('factura_editada')
        end
        format.json { render :show, status: :ok, location: @invoice }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json do
          render json: @invoice.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /invoices/1 or /invoices/1.json
  def destroy
    if @invoice.destroy
      respond_to do |format|
        format.html do
          redirect_to invoices_url, notice: I18n.t('factura_borrada')
        end
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html do
          redirect_to invoices_url, alert: @invoice.errors.full_messages.join(', ')
        end
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /invoices/:id/issue
  def issue
    respond_to do |format|
      success = Invoice.transaction do
        @invoice.issue!
        true
      end

      if success
        format.html do
          redirect_to invoices_path, notice: I18n.t('invoice.issued')
        end
        format.json { render :show, status: :ok, location: @invoice }
      else
        format.html do
          redirect_to invoices_path, alert: I18n.t('invoice.issue_failed')
        end
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  rescue StandardError => e
    # A rejected Issue is ordinary user error (a backdated invoice, say), so
    # show what the model said rather than the raw exception text.
    message = @invoice.errors.full_messages.to_sentence.presence || e.message

    respond_to do |format|
      format.html do
        redirect_to invoices_path, alert: message
      end
      format.json { render json: { error: message }, status: :unprocessable_entity }
    end
  end

  private

  # Draft and Issue commit together or not at all, so a rejected Issue leaves
  # no half-created invoice and burns no number. Returns false on either
  # failure, with the reason on @invoice.errors either way.
  def save_and_maybe_issue
    Invoice.transaction do
      raise ActiveRecord::Rollback unless @invoice.save

      @invoice.issue! if params[:save_and_issue].present?

      true
    end
  rescue ActiveRecord::RecordInvalid => e
    # The insert is rolled back, but the object keeps the id it was given, so
    # the re-rendered form would aim a PATCH at a row that no longer exists.
    # Hand the view an unsaved invoice carrying the same input and the reason.
    @invoice = Invoice.new(invoice_params)
    @invoice.errors.copy!(e.record.errors)
    false
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_invoice
    @invoice = current_user.invoices.find(params[:id])
  end

  # Issued invoices are immutable. The model rejects the field writes on its
  # own, but a nested line-item destroy gets through as a raise rather than a
  # validation error, so update is turned away here alongside edit.
  def ensure_draft
    return if @invoice.draft?

    redirect_to invoices_path, alert: I18n.t('invoice.update_blocked')
  end

  # Only allow a list of trusted parameters through.
  def invoice_params
    params.require(:invoice).permit(
      :client_id,
      :date,
      :due_date,
      :subtotal,
      :iva,
      :irpf,
      :total,
      :notes,
      :series_id,
      line_items_attributes: %i[id item_id invoice_id quantity price iva total _destroy]
    )
  end

  def send_pdf
    # Render the PDF in memory and send as the response
    send_data @invoice.pdf.render,
              filename: "#{@invoice.created_at.strftime('%Y-%m-%d')}-invoice.pdf",
              type: 'application/pdf',
              disposition: :inline # or :attachment to download
  end
end
