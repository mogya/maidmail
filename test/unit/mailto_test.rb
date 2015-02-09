require File.dirname(__FILE__) + '/../test_helper'

class MailtoTest < ActiveSupport::TestCase
  def test_regist
		address1 = Mailto.get_unique_mailto_address
		assert !Mailto.exist?(address1)
		Mailto.regist(address1)
		assert Mailto.exist?(address1)
  end
end
