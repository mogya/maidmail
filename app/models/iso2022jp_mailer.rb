#Thanks to http://wota.jp/ac/?date=20050731
require 'nkf'

class Iso2022jpMailer < ActionMailer::Base
	@@default_charset = 'iso-2022-jp'  # これがないと "Content-Type: charset=utf-8" になる
	@@encode_subject	= false 				 # デフォルトのエンコード処理は行わない(自分でやる)

	# 1) base64 の符号化 (http://wiki.fdiary.net/rails/?ActionMailer より)
	def base64(text, charset="iso-2022-jp", convert=true)
		if convert
			if charset == "iso-2022-jp"
#				text = NKF.nkf('-j -m0', text)
				text = NKF.nkf('-Wxm0 --oc=ISO-2022-JP-1', text)
			end
		end
		text = [text].pack('m').delete("\r\n")
		"=?#{charset}?B?#{text}?="
	end

	# 2) 本文を iso-2022-jp へ変換
	# どこでやればいいのか迷ったので、とりあえず create! に被せています
	def create! (*)
		super
#		@mail.body = NKF::nkf('-jW --convert-jis78-jis83', @mail.body)
		@mail.body = NKF::nkf('-Wxm0 --oc=ISO-2022-JP-1', @mail.body)
		return @mail	 # メソッドチェインを期待した変更があったら怖いので
	end
end
