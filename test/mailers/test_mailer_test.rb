require "test_helper"

class TestMailerTest < ActionMailer::TestCase
  test "hello" do
    mail = TestMailer.hello
    assert_equal "Hello from Postmark", mail.subject
    assert_equal ["ricardo@solucionesio.es"], mail.to
    assert_equal ["info@solucionesio.es"], mail.from
    assert_match "Test#hello", mail.body.encoded
  end

end
