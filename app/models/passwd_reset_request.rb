class PasswdResetRequest < ActiveRecord::Base
	belongs_to :user

	# 今使ってもいいデータかどうか判定。
	# valid?は、保存する時に正当性を判定する関数。
	# reliable?は、使おうとした時にまだ有効かどうかを判定するのに使う。
	def reliable?
		#一度使われていたらもう無効。
		return false if self.used
		# ３日以上経過したものも無効
		return false if (Time.now - self.updated_at > 3.day )
		# 存在しないユーザーのキーも無効
		return false if (nil == self.user )
	
		return true
	end

	def self.newRequest(id)
		request = self.new()
		request.user_id = id

		length=32;
		retry_times=100;
		source=["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9"]
		key=nil
		retry_times.times {|t|
			key=""
			length.times{ key << source[rand(source.size)].to_s }
			break if !find_by_key(key)
			logger.warn("#{t}th retry newRequest...")
			if (t>=retry_times-1) 
				raise TooMuchTryException,"#{t}times retried. give up.." 
			end
		}
		request.key = key
		request.used = false
		return request
	end

end
