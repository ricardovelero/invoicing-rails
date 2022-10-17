class ContactController < ApplicationController
    def create
      @contact = Contact.new()
      @contact.name = params[:name]
      @contact.email = params[:email]
      @contact.message = params[:message]
      if @contact.deliver
        render json: {message: "Email sent successfully"}
      else
        render json: @contact.errors
      end
    end
  end