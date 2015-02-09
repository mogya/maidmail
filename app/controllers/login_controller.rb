require "pp"
require 'gcalapi'
require 'googlecalendar/auth_sub_util'
class LoginController < ApplicationController
	before_filter :require_login, :only=>['config','update','google_auth','regist_done','google_auth_responce','regenerate_mailto_address','send_welcome_mail']
	before_filter :require_not_login, :only=>['regist','login','passwd_reset']

	def index
		if (session[:user_id]) 
			redirect_to(:action=>'config') 
		else
			@charactor="img2094_2"
			render(:action=>"index")
		end
	end
	
	def login
		auth_ok = false
		if (params[:password].blank? or params[:mail].blank?)
			#認証失敗
		else
			@user_candidate = User.find_by_mail(params[:mail])
			if (nil == @user_candidate)
				#認証失敗
			elsif(@user_candidate.auth(params[:password]) )
				auth_ok = true
			else
				#認証失敗
			end
		end

		if (auth_ok)
			session[:user_id] = @user_candidate.id
			flash[:notice]="おかえりなさいませ、ごしゅじんさま。" 
			redirect_to(:action=>'config')
		else
			flash[:notice]="ユーザー名とパスワードの組み合わせが違うみたいですよ。" 
			redirect_to(:action=>'index')
		end
	end

	def logout
		session[:user_id] = nil
		reset_session
		flash[:notice]="ログアウトしました。" 
		redirect_to(:action=>'index')
	end

	def config
		@user = User.find(session[:user_id])
		@charactor="img2140_7"
	end

	def update
		logger.debug "params[:user]:#{params[:user].pretty_inspect}"
		@user = User.find(session[:user_id])
		@user.attributes = params[:user]
		if (@user.check_params)
			@user.save!
			flash[:notice]="更新しました。"
			redirect_to(:action=>"config")
		else
			flash.now[:notice]="エラーがあります。"
			flash.now[:error]=@user.error_msg
			@error_params = @user.error_params
			@charactor="img2136_3"
			render(:action=>"config")
		end
	end
	
	def google_auth
		@google_auth_url = GoogleCalendar::AuthSubUtil.build_request_url(
			url_for(:controller=>"login",:action=>"google_auth_responce"),
			'http://www.google.com/calendar/feeds/',
			false, #use_secure
			true  #use_session
		) 
		render(:action=>'google_auth')
	end

	def regist
		logger.debug "params[:user]:#{params[:user].pretty_inspect}"
		@user = User.new
		@user.attributes = params[:user]
		if (nil==params[:user])
			#最初に来た時
			@charactor="img2139_6"
			@user.morningMailTime = "10:00"
			@user.city_id = 66
			render(:action=>"regist")
		elsif (nil==params[:agree_rule] or params[:agree_rule]["yes"]!="1")
			flash.now[:error] = "利用規約に同意いただけない場合は、ユーザー登録していただくことが出来ません。"
			render(:action=>"regist")
		elsif (@user.check_params)
			#登録できる
			@user.calendarFeedUri = "http://www.google.com/calendar/feeds/default/private/full"
			@user.save!
			@user.reset_mailto_address!
			session[:user_id]=@user.id

			@google_auth_url = GoogleCalendar::AuthSubUtil.build_request_url(
				url_for(:action=>"regist_done"),
				'http://www.google.com/calendar/feeds/',
				false, #use_secure
				true  #use_session
			) 
			render(:action=>'google_auth')
		else
			#登録できない
			flash.now[:notice]="エラーがあります。"
			flash.now[:error]=@user.error_msg
			@error_params = @user.error_params
			@charactor="img2136_3"
			render(:action=>"regist")
		end
	end

	def regist_done
		ret = google_responce_handler()
		@user = User.find(session[:user_id])
		if ret
			MaidMailSender.deliver_user_registerd_mail(@user)
			render(:action=>"regist_done")
		else
			flash.now[:notice]="Googleカレンダーの認証に失敗しました。"
			@google_auth_url = GoogleCalendar::AuthSubUtil.build_request_url(
				url_for(:controller=>"login",:action=>"regist_done"),
				'http://www.google.com/calendar/feeds/',
				false, #use_secure
				true  #use_session
			) 
			render(:action=>'google_auth')
		end
	end

	def google_auth_responce
		ret = google_responce_handler()
		if ret
			flash[:notice]="Googleカレンダーの認証に成功しました。"
		else
			flash[:notice]="Googleカレンダーの認証に失敗しました。"
		end
		redirect_to(:action=>"config")
	end

	def regenerate_mailto_address
		@user = User.find(session[:user_id])
		@user.reset_mailto_address!
		send_welcome_mail
	end
	
	def send_welcome_mail
		@user = User.find(session[:user_id])
		MaidMailSender.deliver_user_registerd_mail(@user)
		flash[:notice]="#{@user.mail}宛にメールを送信しました。"
		redirect_to(:action=>"config")
	end

	def withdraw_confirm
		@charactor="img2135_2"
	end

	def withdraw
		@user = User.find(session[:user_id])
		@user.destroy
		session[:user_id] = nil
		reset_session
	end

	def passwd_reset
		logger.debug("login controller passwd_reset.")

		passwd_reset_request = PasswdResetRequest.find_by_key(params[:user_key])
		if (nil == passwd_reset_request || false == passwd_reset_request.reliable?)
			redirect_to(:status=>:bad_request, :controller=>'top',:action=>'index')
		else
			if (params[:password])
				if (params[:password]!=params[:password_confirm])
					flash[:notice]="入力したパスワードが一致しないみたいです。もう一回入力してください。"
				elsif (params[:password].length < 5)
					flash[:notice]="パスワードが短すぎます。5文字以上にしてください"
				else
					#パスワードを変更。変更リクエストに使用済みの印をつける
					@user = passwd_reset_request.user
					@user.raw_password = params[:password]
					@user.save!
					passwd_reset_request.used=true
					passwd_reset_request.save!
					
					flash[:notice]="パスワードを変更しました。新しいパスワードでログインしてください。"
					redirect_to(:action=>'index')
				end
			else
				flash[:notice]="パスワードを再設定します。新しいパスワードを入力してください。"
			end
			@charactor="img2140_7"
		end
	end

	def remind
		if (params[:mail])
			user = User.find_by_mail(params[:mail])
			if (user)
				MaidMailSender.deliver_password_reset_mail(user,request.domain)
				flash[:notice]="送信しました。メールを確認して、書かれているURLにアクセスしてください。"
			else
				flash[:notice]="入力していただいたメールアドレスのユーザーさんが見つかりませんでした。メイドさんから届いているメールを、もう一度確認してみていただけますか？"
			end
		else
			flash[:notice]="パスワードを再設定するためのURLが記載されたメールを送信しますので、メールアドレスを入力して「送信」を押してください。"
		end
		
	end

	######################################################################################
	#ここから下はprivateメソッド！

	private 
	def require_login
		if(session[:user_id])
			@user=User.find(session[:user_id])
		else
			redirect_to(:controller=>'login',:action=>'index')
		end
	end

	def require_not_login
		#ログイン済みの人は登録できない
		if(session[:user_id])
			redirect_to(:controller=>'login',:action=>'config')
		end
	end

	def google_responce_handler
		ret = false
		authsub_token = ''
		one_time_token = params[:token]

		logger.debug("got one_time_token: #{one_time_token} for user ##{session[:user_id]} ")

		session_token = nil
		begin
			session_token =  GoogleCalendar::AuthSubUtil.exchange_session_token(one_time_token)
		rescue
			session_token = nil
		end
		

		logger.debug("got session token: #{session_token}")
		if (session_token)
			@user = User.find(session[:user_id])
			@user.calendarToken = session_token
			@user.calendarFeedUri = 'http://www.google.com/calendar/feeds/default/private/full'
			@user.save
			ret = true
		end
		return ret
	end

end
