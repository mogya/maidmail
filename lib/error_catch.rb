def error_catch
	logger = ActiveRecord::Base.logger
	begin
		yield
	rescue => ex
		bt = ex.backtrace
		logger.fatal "\n !!!!!!!!!!!!!!!!!!!!!!\nexception caught:\n"
		logger.fatal "#{bt.shift}: #{ex.message} (#{ex.class})"
		logger.fatal bt.map{|s| "\tfrom #{s}"}.join("\n")
		logger.fatal "\n !!!!!!!!!!!!!!!!!!!!!!\n\n"
	end
end
