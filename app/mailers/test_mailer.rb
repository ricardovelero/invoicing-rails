# frozen_string_literal: true

class TestMailer < ApplicationMailer # rubocop:disable Style/Documentation
  default from: 'info@solucionesio.es'

  def hello
    mail(
      subject: 'Hello from Postmark',
      to: 'ricardo@solucionesio.es',
      from: 'info@solucionesio.es',
      html_body: '<strong>Hello</strong> dear Postmark user.',
      track_opens: 'true',
      message_stream: 'outbound'
    )
  end
end
