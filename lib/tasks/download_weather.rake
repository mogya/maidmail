require 'uri'
require 'net/http'
require 'kconv'
require 'rexml/document'
require 'date'

task :download_weather => [:environment] do
	logger = ActiveRecord::Base.logger
	logger.progname="download_weather"

	connection = ActiveRecord::Base.connection
	City.find(:all).each{|city_info|
		logger.info "download "+city_info.name+" rss...."
		uri = URI.parse(city_info.rss_uri)
		rss_data = nil
		Net::HTTP.start(uri.host,uri.port){|http|
			responce = http.get(uri.request_uri)
			rss_data = responce.body.toutf8
		}
		logger.info "download OK."+city_info.rss_uri
		logger.debug rss_data

		if ("livedoor_webservice"==city_info.rss_type)
			rexml = REXML::Document.new(rss_data)
			
			weather_info = Weather.new
			weather_info.city_id = city_info.id
			weather_info.rss_date = DateTime.parse(rexml.elements["/lwws/forecastdate"].text)
			weather_info.weather = rexml.elements["/lwws/telop"].text
			weather_info.high_temperature = rexml.elements["/lwws/temperature/max/celsius"].text.to_i
			weather_info.low_temperature = rexml.elements["/lwws/temperature/min/celsius"].text.to_i
			weather_info.save!
			logger.info "city #{weather_info.city_id} wrote to db. id=#{weather_info.id}"
		end
		
		sleep 1
	}
	logger.info "done."
end
