require File.dirname(__FILE__) + '/../test_helper'
require 'tmail'

class SchduleMailReceiverTest < ActionMailer::TestCase
  tests SchduleMailReceiver
  # replace this with your real tests
  def test_is_error_mail?
		email = TMail::Mail.new
		email.to = ["mogya@mogya.com","mogya2@mogya.com"]
		email.from = "MAILER-DAEMON@mogya.com"

		assert SchduleMailReceiver.is_error_mail?(email)

		email.from = "mogya@mogya.com"
		assert !SchduleMailReceiver.is_error_mail?(email)

  end
end
