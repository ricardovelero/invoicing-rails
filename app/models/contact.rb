class Contact < MailForm::Base
    attribute :name, validate: true
    attribute :email, validate: /\A[^@\s]+@[^@\s]+\z/i
    attribute :message
    def headers
      { 
        subject: "Forma Contacto Perfil Usuario",
        to: 'info@solucionesio.es',
        from: %("#{name}" <#{email}>)
      }
    end
  end