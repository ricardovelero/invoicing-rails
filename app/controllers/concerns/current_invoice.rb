module CurrentInvoice
  private
    def set_invoice
      @invoice = Invoice.find(session[:invoice_id])
    rescue ActiveRecord::RecordNotFound
      @invoice = Invoice.create
      session[:invoice_id] = @invoice.id
    end
end
