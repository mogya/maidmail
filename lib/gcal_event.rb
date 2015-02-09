require "mextractr_webapi"

Mextractr_new_webapi_url = 'http://ap.mextractr.net/mextractr?text=[[text]]&out=[[out]]&apikey=[[apikey]]'

def text2gcalevent(text)
	event_params = {}

	mextractr_result = MextractrWebApi.new(MEXTRACTR_API_KEY,logger, {:webapi_url=>Mextractr_new_webapi_url} ).parse(text)
	if (nil==mextractr_result)
		logger.warn "fail to get mextractrAPI result."
		return nil
	end
	logger.debug "mextractrAPI result "
	logger.debug "#{mextractr_result.pretty_inspect}"

	event_params['start'] = Time.parse(mextractr_result['when'][0]['startTime'] ) if (mextractr_result['when'] && mextractr_result['when'][0] && mextractr_result['when'][0]['startTime'])
	if (mextractr_result['when'] && mextractr_result['when'][0] && mextractr_result['when'][0]['endTime'])
		event_params['end'] = Time.parse(mextractr_result['when'][0]['endTime'] )
		event_params['allday'] = false
	else
		#とれなかったら、とりあえず二時間後くらいで。
		event_params['end'] = event_params['start'] + (2*60*60) if (event_params['start'])
		event_params['allday'] = true 
	end
	event_params['end'] = event_params['start'] + (2*60*60) if (event_params['start'])
	event_params['where']= mextractr_result['where'][0]['valueString'] if (mextractr_result['where']&&mextractr_result['where'][0]&&mextractr_result['where'][0]['valueString'])
	event_params['title'] = mextractr_result['what'][0]['valueString'] if (mextractr_result['what']&&mextractr_result['what'][0]&&mextractr_result['what'][0]['valueString'])
	event_params['title'] = event_params['title'] || mextractr_result[:where] || nil
	event_params['desc'] = text+"\n"
	event_params['desc'] <<"\nこの予定は、#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}にmaidmail.jpで作成されました。\n"
	
	return event_params
end
