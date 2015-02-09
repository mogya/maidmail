require 'error_catch'

task :send_morning_mail => [:environment] do
error_catch{
	logger = ActiveRecord::Base.logger
	logger.progname="send_morning_mail"
	
	if (
		(/^[0-2][0-9]:[0-5][0-9]$/ !~ (ENV['start'] || "") ) or
		(/^[0-2][0-9]:[0-5][0-9]$/ !~ (ENV['end'] || "") )
	)
		puts "error:starttime,endtime not found(or invalid)."
		logger.error  "error:starttime,endtime not found."
		puts %Q(rake send_morning_mail start="xx:xx" end="xx:xx") 
		exit
	end
	if (ENV['start']>ENV['end'])
		puts "error:endtime must be bigger than starttime"
		logger.error "error:endtime must be bigger than starttime"
		puts %Q(rake send_morning_mail start="xx:xx" end="xx:xx") 
		exit
	end
	logger.debug "start time:#{ENV['start']}"
	logger.debug "end time:#{ENV['end']}"

	connection = ActiveRecord::Base.connection
		condition = ["morningMailTime>? and morningMailTime <= ? and calendarToken!=''",ENV['start'],ENV['end']]
	User.find(:all, :conditions => condition, :order=>"morningMailTime" ).each{|user|
		puts "user:#{user.mail}"
		logger.debug "user:#{user.mail}"
		begin
			MaidMailSender.deliver_morning_schedule_mail(user,Time.now)
		rescue => ex
			bt = ex.backtrace
			logger.fatal "\n !!!!!!!!!!!!!!!!!!!!!!\nexception caught:\n"
			logger.fatal "#{bt.shift}: #{ex.message} (#{ex.class})"
			logger.fatal bt.map{|s| "\tfrom #{s}"}.join("\n")
			logger.fatal "\n !!!!!!!!!!!!!!!!!!!!!!\n\n"
			next
		end
	}

	logger.info "done"
}
end
