task :setup => [:environment] do
	logger = ActiveRecord::Base.logger
	logger.progname="setup"

	`chown -R :maidmail #{RAILS_ROOT}`
	`chmod -R 777 #{RAILS_ROOT}`

	logger.info "done"
end