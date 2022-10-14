class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_invoice, only: %i[show edit update destroy]

  # GET /invoices or /invoices.json
  def index
    @invoices = Invoice.all
  end

  # GET /invoices/1 or /invoices/1.json
  def show
  end

  # GET /invoices/new
  def new
    @invoice = Invoice.new
    @invoice.line_items.build
  end

  # GET /invoices/1/edit
  def edit
  end

  def add_item
    helpers.fields model: Invoice.new do |f|
      render turbo_stream:
               turbo_stream.append(
                 "line_items",
                 partial: "item_fields",
                 locals: {
                   f: f,
                   line_item: LineItem.new
                 }
               )
    end
  end

  # POST /invoices or /invoices.json
  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.user = current_user

    respond_to do |format|
      if @invoice.save
        format.html do
          redirect_to invoice_url(@invoice),
                      notice: "Invoice was successfully created."
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

  # PATCH/PUT /invoices/1 or /invoices/1.json
  def update
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html do
          redirect_to invoice_url(@invoice),
                      notice: "Invoice was successfully updated."
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
        redirect_to invoices_url, notice: "Invoice was successfully destroyed."
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
      item_ids: []
    )
  end
end
