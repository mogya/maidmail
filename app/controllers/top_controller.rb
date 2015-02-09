require "gcal_event"

class TopController < ApplicationController
	def index
		@charactor = "img2093_1"
		@logo_l = true
	end

	def mailhelp
		if (!session[:user_id]) 
			redirect_to(:controller=>'login',:action=>'config') 
		else
			@charactor = "img2141_016"
			@user = User.find(session[:user_id])
			render(:action=>'mailhelp')
		end
	end

	def more
		@charactor = "img2141_016"
	end

	def about
		@charactor = "img2141_016"
	end

	def try
		@charactor = "img2141_016"
		
		logger.debug "params:#{params.pretty_inspect}"
		if (params[:try_input])
			#メール内容の解析
			text = ""
			params[:try_input].each_line{|line|
				next if (/^(from|date|subject|to|cc):/i =~ line)
				text<<line
			}
			event_params = text2gcalevent(text)
			if (!event_params)
				logger.warn "fail to get mextractrAPI event_params."
				params[:try_output] = "ごめんなさい。エラーになっちゃいました。"
				exit
			end
			if (!event_params['start'])
				raise "cannot get start time."
			end

			params[:try_output]=""
			params[:try_output]<< "タイトル：#{event_params['title']||""}\n"
			params[:try_output]<< "日時：#{event_params['start'].strftime("%y/%m/%d %H:%M:%S") rescue "取得失敗"}"
			if (event_params['allday']) 
				params[:try_output]<< "(終日の予定)\n"
			else
				params[:try_output]<< "-#{event_params['end'].strftime("%y/%m/%d %H:%M:%S")}\n"
			end
			params[:try_output]<< "場所：#{event_params['where']||""}\n"
			params[:try_output]<< "詳細：\n#{event_params['desc']}\n"
		end
	end

end
