module CurrentInvoice
  private

  def set_invoice
    @invoice = current_user.invoices.find(session[:invoice_id])
  rescue ActiveRecord::RecordNotFound
    @invoice = current_user.invoices.create
    session[:invoice_id] = @invoice.id
  end
end
