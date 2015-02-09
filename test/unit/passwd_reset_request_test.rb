require File.dirname(__FILE__) + '/../test_helper'

class PasswdResetRequestTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_reliable?

		passwd_reset_request = PasswdResetRequest.new
		passwd_reset_request.user_id = nil
		passwd_reset_request.save!
		#存在しないユーザーのデータは無効
		assert false == passwd_reset_request.reliable?

		passwd_reset_request.user_id = users(:one).id
		assert passwd_reset_request.reliable?

		passwd_reset_request.used = true
		#使用済みデータの場合は無効
		assert false == passwd_reset_request.reliable?
		
		passwd_reset_request.used = false
		assert passwd_reset_request.reliable?

		passwd_reset_request.updated_at = Time.parse("2005-12-09 15:15:08")
		#古いデータの場合は無効
		assert false == passwd_reset_request.reliable?
		
  end

  def test_newRequest
		req = PasswdResetRequest.newRequest(users(:one).id)
		req.save!
		assert req.reliable?
  end

end
