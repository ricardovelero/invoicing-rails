# frozen_string_literal: true

# Invoice controller with search, sort, and filter
class InvoicesController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action :authenticate_user!
  before_action :set_invoice, only: %i[show edit update destroy]

  # GET /invoices or /invoices.json
  def index # rubocop:disable Metrics/AbcSize
    @invoices = current_user.invoices
    @invoices = current_user.invoices.filter_status(params[:status]) if params[:status].present?
    @invoices = current_user.invoices.search(params[:query]) if params[:query].present?
    @pagy, @invoices = pagy @invoices.reorder(sort_column => sort_direction), items: params.fetch(:count, 10)
  end

  def sort_column
    %w[invoice_number total status date due_date].include?(params[:sort]) ? params[:sort] : 'invoice_number'
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
  end

  # GET /invoices/1/edit
  def edit
    @client = Client.find(@invoice.client_id)
  end

  # POST /invoices or /invoices.json
  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.user = current_user

    respond_to do |format|
      if @invoice.save
        format.html do
          redirect_to invoices_path, notice: I18n.t('factura_creada')
        end
        format.json { render :show, status: :created, location: @invoice }
      else
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
    @invoice.destroy

    respond_to do |format|
      format.html do
        redirect_to invoices_url, notice: I18n.t('factura_borrada')
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def invoice_params
    params.require(:invoice).permit(
      :client_id,
      :invoice_number,
      :date,
      :due_date,
      :subtotal,
      :iva,
      :irpf,
      :total,
      :notes,
      :status,
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
