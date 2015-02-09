require 'gcalapi'
require 'googlecalendar/service'
require 'googlecalendar/service_auth_sub'
require 'googlecalendar/calendar'
require "iso2022jp_mailer"
require 'pp'

# gcalapiに追加するコード。
module GoogleCalendar
	class ServiceAuthSub
	  CALENDAR_LIST_PATH = "http://www.google.com/calendar/feeds/default/allcalendars/full"

		# get the list of user's calendars and returns http response object
		#
		def calendar_list
		  logger.info("-- get_calendar_list_responce st --") if logger
		  auth unless @auth
		  uri = URI.parse(CALENDAR_LIST_PATH)
		  res = do_get(uri, {})
		  logger.info("-- get_calendar_list_responce en(#{res.message}) --") if logger
		  res
		end

	  alias :calendars :calendar_list
	end  
	class Calendar
		def self.get_gCalValues(srv)
			ret = srv.calendar_list
			list = REXML::Document.new(ret.body)
			h = {}
      if(!list) 
  		  logger.info("ERROR:failed on get_gCalValues.") if logger
  		  logger.info("ret.body:(${ret.body})") if logger
      end
			list.root.elements.each("entry/link") do |link|
				if link.attributes["rel"] == "alternate"
					feed = link.attributes["href"]
					h[feed] = Hash.new
					link.parent.elements.each{|entry_attr|
						h[feed][entry_attr.name] = entry_attr.attributes["value"]
					}
				end
			end
			h
		end
	end
end


class MaidMailSender < Iso2022jpMailer
	def morning_schedule_mail(user,target_date)
		logger.info "morning_schdule_mail >>> "
		logger.info(%Q[user:#{user.mail}\ntarget_date:#{target_date.strftime("%Y-%m-%d")}] )

		recipients user.mail
		from user.mailto
		subject base64(MAIL_TITLE_HEADER+"おはようございます！")

		#スケジュール 複数カレンダー対応
		gserver = GoogleCalendar::ServiceAuthSub.new(user.calendarToken)
#		calendar = GoogleCalendar::Calendar.new(gserver, GoogleCalendar::Calendar::DEFAULT_CALENDAR_FEED)
		calendars = GoogleCalendar::Calendar.calendars(gserver)
		gCalValues = GoogleCalendar::Calendar.get_gCalValues(gserver)

		timenow= Time.now()

		conditions = {}
		conditions['start-min']=target_date.beginning_of_day+1
		#翌日の今ぐらいの時間までの予定はメールする
		conditions['start-max']=target_date.tomorrow.beginning_of_day+ timenow.hour.hours + timenow.min.minutes
		conditions['sortorder']='d'
		conditions['timezone']='tokyo'
		events = []
		calendars.each_value{|calendar|
			#Googleカレンダー上で、選択(表示)されているカレンダーの予定だけを通知する
			next if ("true" != gCalValues[calendar.feed]["selected"])
			events << calendar.events(conditions)
		}
		events.flatten!
		#終日の予定に対して、時差分ずれてデータがとれてしまうことがある？問題の
		#対策として、終了時刻が範囲より前にある予定を削除
		events.delete_if{|event|
			event.en<conditions['start-min'] if (event.en)
		}
		events.each{|event|
			event.st.localtime if (event.st)
			event.en.localtime if (event.en)
		}
		events = events.sort{|a, b|
			if (nil==a.st)
				1
			elsif (nil==b.st)
				-1
			else
				a.st <=> b.st
			end
		}
		logger.debug("events:\n"+events.pretty_inspect)

		#天気予報
		weather = Weather.find(
			:first,
			:conditions => [ 
				"city_id= ? and rss_date like ?", 
				user.city_id,
				target_date.strftime("%Y-%m-%d")+'%'# 該当の日時で始まっていれば時刻は何でもいい
			],
			:order => "rss_date desc" # 該当条件で、一番遅い時刻のデータを一つとってくる
		)
		if (weather)
			logger.debug("weather:\n"+weather.pretty_inspect)
		else
			logger.error("can't get weather information for id:#{user.city_id}, time:#{target_date.strftime("%Y-%m-%d")}")
		end

		body :weather=>weather,:user=>user,:events=>events
		logger.info "<<< morning_schdule_mail end. "
	end

	def schdule_registerd_mail(from,user,event)
		recipients	from
		from	user.mailto
		subject_utf8= MAIL_TITLE_HEADER+"#{event.st.strftime("%m/%d")}に登録しました"
		subject base64(subject_utf8)
		body :user=>user,:event =>event
	end

	def schdule_register_failed_mail(from,user)
		recipients	from
		from	user.mailto
		subject_utf8= MAIL_TITLE_HEADER+"登録出来ませんでした"
		subject base64(subject_utf8)
		body :user=>user
	end

	def user_registerd_mail(user)
		recipients	user.mail
		from	user.mailto
		subject_utf8= MAIL_TITLE_HEADER+"はじめまして！"
		subject base64(subject_utf8)
		body :user=>user
	end

	def password_reset_mail(user,host)
		req = PasswdResetRequest.newRequest(user.id)
		req.save!
		reset_url=url_for(:host=>host, :controller=>"login",:action=>"passwd_reset",:user_key=>req.key)
		recipients	user.mail
		from	user.mailto
		subject_utf8= MAIL_TITLE_HEADER+"パスワード再設定のご案内"
		subject base64(subject_utf8)
		body :reset_url=>reset_url
	end
end
