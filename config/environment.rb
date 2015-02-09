# Be sure to restart your server when you modify this file
require "pp"

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
#ENV['RAILS_ENV'] = 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.action_controller.session = {
    :session_key => '_maidmailWeb_session',
    :secret      => ''
  }

	config.action_mailer.raise_delivery_errors = true
	config.action_mailer.default_charset = 'iso-2022-jp'
	config.action_mailer.delivery_method = :sendmail
	config.action_mailer.sendmail_settings = {
		:location       => '/usr/sbin/sendmail',
		:arguments      => '-i -t -V -f error_maidmail@maidmail.jp'
	}

	File.umask(0111)
	config.logger = Logger.new(config.log_path)
	config.logger.datetime_format="%Y-%m-%dT%H:%M:%S.%06d "
	config.logger.progname="default"

end

class Logger
private
	if method_defined?(:formatter=)
		def format_message_with_datetime(severity, timestamp, progname, msg)
			app_format_message(msg)
		end
	else
		def format_message_with_datetime(severity, timestamp, msg, progname)
			app_format_message(msg)
		end
	end

	def app_format_message(msg)
		time = Time.now
		time_str = time.strftime("%Y-%m-%d %H:%M:%S") << "[#{progname}] "
		msg.to_s.split(/\n/).collect { |line| line =~ /^\s*$/ ? line : time_str + line }.join("\n") + "\n"
	end

	alias_method :format_message_without_datetime, :format_message
	alias_method :format_message, :format_message_with_datetime
end
