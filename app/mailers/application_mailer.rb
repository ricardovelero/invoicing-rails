# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base # rubocop:disable Style/Documentation
  default from: 'info@solucionesio.es'
  layout 'mailer'
end
