require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  def test_regist_mailto_address!
		address1 = Mailto.get_unique_mailto_address
		user = users(:one)
		user.regist_mailto_address!(address1)
		assert(Mailto.exist?(user.mailto))
		assert(User.find(user.id).mailto == user.mailto)
  end

  def test_check_params!
		ok_param = {}
		ok_param["mail"]="mogya@mogya.com"
		ok_param["raw_password"]="aaaaa123"
		ok_param["raw_password_confirm"]="aaaaa123"
		ok_param["morningMailTime"]="08:00"
		ok_param["city_id"]=cities(:one).id
		
		user = users(:one)
		ng_param = ok_param.dup
		ng_param["mail"]=""
		user.attributes = ng_param
		assert(!user.check_params)
		assert(""!=user.error_msg)
		assert(user.error_params.include?(:mail))

		user = users(:one)
		ng_param = ok_param.dup
		ng_param["mail"]="mogya"
		user.attributes = ng_param
		assert(!user.check_params)
		assert(""!=user.error_msg)
		assert(user.error_params.include?(:mail))

		user = users(:one)
		ng_param = ok_param.dup
		ng_param["raw_password"]="a"
		ng_param["raw_password_confirm"]="a"
		user.attributes = ng_param
		assert(!user.check_params)
		assert(""!=user.error_msg)
		assert(user.error_params.include?(:raw_password))

		user = users(:one)
		ng_param = ok_param.dup
		ng_param["raw_password"]="aaaaa123"
		ng_param["raw_password_confirm"]="aaaaa987"
		user.attributes = ng_param
		assert(!user.check_params)
		assert(""!=user.error_msg)
		assert(user.error_params.include?(:raw_password))
		assert(user.error_params.include?(:raw_password_confirm))

		user = users(:one)
		ng_param = ok_param.dup
		ng_param["morningMailTime"]=""
		user.attributes = ng_param
		assert(!user.check_params)
		assert(""!=user.error_msg)
		assert(user.error_params.include?(:morningMailTime))

		user = users(:one)
		ng_param = ok_param.dup
		ng_param["morningMailTime"]="aaaaa"
		user.attributes = ng_param
		assert(!user.check_params)
		assert(""!=user.error_msg)
		assert(user.error_params.include?(:morningMailTime))

		user = users(:one)
		ng_param = ok_param.dup
		ng_param["morningMailTime"]="99:99"
		user.attributes = ng_param
		assert(!user.check_params)
		assert(""!=user.error_msg)
		assert(user.error_params.include?(:morningMailTime))

		user = users(:one)
		ng_param = ok_param.dup
		ng_param["city_id"]=nil
		user.attributes = ng_param
		assert(!user.check_params)
		assert(""!=user.error_msg)
		assert(user.error_params.include?(:city_id))

		user = users(:one)
		ng_param = ok_param.dup
		ng_param["city_id"]="aaaa"
		user.attributes = ng_param
		assert(!user.check_params)
		assert(""!=user.error_msg)
		assert(user.error_params.include?(:city_id))

		user = users(:one)
		ng_param = ok_param.dup
		ng_param["city_id"]=-1
		user.attributes = ng_param
		assert(!user.check_params)
		assert(""!=user.error_msg)
		assert(user.error_params.include?(:city_id))

		#OKになるケースの確認
		user = users(:one)
		user.attributes = ok_param
		assert(user.check_params)
		assert(""==user.error_msg)
		assert([]==user.error_params)

		user = users(:one)
		ok_param["raw_password"]=""
		ok_param["raw_password_confirm"]=""
		user.attributes = ok_param
		assert(user.check_params)
		assert(""==user.error_msg)
		assert([]==user.error_params)
		

  end
end
