require 'digest/sha2'

class User < ActiveRecord::Base
	belongs_to :city
	attr_accessor :raw_password,:raw_password_confirm
	attr_accessor :error_msg,:error_params

	def check_params()
		@error_msg = ""
		@error_params = []
		# maidaddress
		if (self.mail.blank?)
			@error_msg << "メールアドレスが入力されていません\n" 
			@error_params << :mail
		elsif (/@/ !~ self.mail)
			@error_msg << "メールアドレスが変です。@がないですよ？\n" 
			@error_params << :mail
		end
		# password
		if (self.raw_password.blank?)
			#パスワードが入力されていなければ変更しないので、blankはエラーではない。
		elsif (self.raw_password.length < 5)
			@error_msg << "パスワードが短すぎます。5文字以上にしてください\n"
			@error_params << :raw_password
		elsif (self.raw_password != self.raw_password_confirm)
			@error_msg << "二回入力したパスワードが一致していません。\n"
			@error_params << :raw_password
			@error_params << :raw_password_confirm
		end
		# morningMailTime
		if (self.morningMailTime.blank?)
			@error_msg << "メールする時間の選択が変です。\n"
			@error_params << :morningMailTime
		elsif (/[012][0-9]:[0-5][0-9]/ !~ self.morningMailTime)
			@error_msg << "メールする時間の選択が変です。\n"
			@error_params << :morningMailTime
		end
		# city_id
		if (self.city_id.blank?)
			@error_msg << "都市名が変です\n"
			@error_params << :city_id
		elsif (nil == City.find_by_id(self.city_id))
			@error_msg << "都市名が変です\n"
			@error_params << :city_id
		end
		
		return (""==@error_msg)
	end
	
	def crypt_password(raw_password)
		return Digest::SHA256.hexdigest(raw_password+ self.id.to_s) 
	end

	def before_save
		self.password = crypt_password(self.raw_password) if (!raw_password.blank?)
	end

	def auth(raw_password)
		return (self.password == crypt_password(raw_password))
	end

	def regist_mailto_address!(address)
		Mailto.regist(address)
		self.mailto = address
		save!
	end

	def reset_mailto_address!
		self.mailto = Mailto.get_unique_mailto_address(mail)
		Mailto.regist(self.mailto)
		save!
	end

end
