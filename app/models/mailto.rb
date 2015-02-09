class TooMuchTryException < StandardError; end
class DuplicateMailtoException < StandardError; end

class Mailto < ActiveRecord::Base
	def self.get_unique_mailto_address(seeds=nil)
#		logger.warn("get_unique_mailto_address. seed="+seeds.to_s)
		length=10;
		retry_times = 100;
#		seeds.to_s.each_byte{|c| srand(c)} if (seeds)

		#見間違えやすそうな文字 l,o は使わない
		source=["a","b","c","d","e","f","g","h","j","k","m","n","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9"]
		address=nil
		#mailtoDBにないアドレスができるまで試行
		retry_times.times {|t|
			address="mm_"
			length.times{ address << source[rand(source.size)].to_s }
			address << "@"+MAID_MAIL_DOMAIN
			break if !exist?(address)
			logger.warn("#{t}th retry get_mailto_address...")
			if (t>=retry_times-1) 
				raise TooMuchMailToException,"#{t}times retried. give up.." 
			end
		}
		return address
	end

	def self.exist?(address)
		return true if (find_by_mailto(address))
		return false
	end
	
	def self.regist(address)
		if (exist?(address)) 
			raise DuplicateMailtoException,"#{address} is already used as mailto_id:#{find_by_mailto(address).id}"
		end

		new_record = self.new
		new_record.mailto = address
		new_record.save!
	end
end
