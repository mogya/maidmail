require "pp"
require "googlecalendar/calendar"
require 'googlecalendar/service'
require 'googlecalendar/service_auth_sub'
require 'error_catch'
require "gcal_event"

class SchduleMailReceiver < ActionMailer::Base

	def self.is_error_mail?(email)
		email.from.each{|mailfrom|
			return true if (/MAILER.DAEMON/i =~ mailfrom)
			return true if (/postmaster/i =~ mailfrom)
		}if(email.from)
		return true if (/failure notice/i =~ email.subject)
		return true if (/Delivery Failure/i =~ email.subject)
		return true if (/Delivery Status/i =~ email.subject)

		return false
	end

	def receive(email)
	error_catch{
		mail_subject = email.subject.toutf8
		mail_body = email.body.toutf8

		logger.info "SchduleMailReceiver >>> "
		
		logger.info %Q(email.subject:#{mail_subject})
		ENV.each{|name,value|
			logger.info %Q(ENV[#{name}]:#{value})
		}
		email.each_header{|name,value|
			logger.info %Q(header[#{name}]:#{value})
		}
		logger.info "email.body:\n #{mail_body.pretty_inspect}"

		#ユーザーの特定
		if (nil==email['X-Original-To'])
			logger.warn "X-Original-To header not found."
			exit
		end
		logger.info "x-original-to: #{email['x-original-to']}"
		if (SchduleMailReceiver.is_error_mail?(email))
			logger.warn "maybe error mail. Do not handle this."
			exit
		end
		user = User.find_by_mailto(email['x-original-to'].to_s)
		
		#デバッグ用機能。to:で始まるsubjectの時、残った部分を宛先の代わりに使う。
		if (user==nil && "production"!=RAILS_ENV)
			if (mail_subject=~/^to:(.+)/)
				user = User.find_by_mailto($1)
				logger.info "using debug special feature. use SUBJECT as TO."
			end
		end

		if (nil==user)
			logger.warn "user not found."
			exit
		end
		logger.info "user:#{user.id}"

		begin
			#メール内容の解析
			mailContents = ""
			mail_body.each_line{|line|
				next if (/^(from|date|subject|to|cc):/i =~ line)
				mailContents<<line
			}
			event_params = text2gcalevent(mailContents)
			if (!event_params)
				raise "cannot get event."
			end
			if (!event_params['start'])
				raise "cannot get start time."
			end

			#カレンダーに登録
			server = GoogleCalendar::ServiceAuthSub.new(user.calendarToken)
			calendar = GoogleCalendar::Calendar.new(server, user.calendarFeedUri)
			event = calendar.create_event
			event.st = event_params['start']
			event.en = event_params['end']
		  event.where = event_params['where']

			# text2gcaleventでうまくタイトルがとれたらベスト。
			# Re:以外で始まる場合、メールのタイトルをタイトルとして採用。
			# 最悪の場合"予定"とする
		  event.title = event_params['title']
			if ( mail_subject !~ /^re:(.+)/i )
				event.title ||= mail_subject
			end
			event.title ||= "予定"

		  event.title = MAIL_TITLE_HEADER+event.title if (ENV['RAILS_ENV']=='development')
		  event.allday = event_params['allday']
		  event.desc =event_params['desc'] 

			logger.debug "event:"
			logger.debug "#{event.pretty_inspect}"
		  event.save!

			logger.debug "1 event registerd."
			
#			MaidMailSender.deliver_schdule_registerd_mail(email.from,user,event)
			MaidMailSender.deliver_schdule_registerd_mail(user.mail,user,event)
		rescue => ex
			bt = ex.backtrace
			logger.fatal "\n !!!!!!!!!!!!!!!!\nexception caught on SchduleMailReceiver:\n"
			logger.fatal "#{bt.shift}: #{ex.message} (#{ex.class})"
			logger.fatal bt.map{|s| "\tfrom #{s}"}.join("\n")
			logger.fatal "\n !!!!!!!!!!!!!!!!\n\n"
			logger.fatal "\n Mail handler error catch mecanism send error mail to user. \n"
#			MaidMailSender.deliver_schdule_register_failed_mail(email.from,user)
			MaidMailSender.deliver_schdule_register_failed_mail(user.mail,user)
		end
		
		logger.info "<<< SchduleMailReceiver end. "
	}
	end

end
