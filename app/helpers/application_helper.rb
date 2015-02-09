# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	def timelist()
		return [
			["朝４時頃","04:00"],	["朝４時半頃","04:30"],	["朝５時頃","05:00"],	["朝５時半頃","05:30"],
			["朝６時頃","06:00"],	["朝６時半頃","06:30"],	["朝７時頃","07:00"],	["朝７時半頃","07:30"],
			["朝８時頃","08:00"],	["朝８時半頃","08:30"],	["朝９時頃","09:00"],	["朝９時半頃","09:30"],
			["１０時頃","10:00"],	["１０時半頃","10:30"],	["１１時頃","11:00"],	["１１時半頃","11:30"],
			["１２時頃","12:00"],	["１２時半頃","12:30"],
		]
	end

	def option_groups_of_cities()
		ret = ""
		City.find_by_sql("select distinct area1 from cities").each{|area|
			ret << %Q!<optgroup label="#{area.area1}">!
			City.find_all_by_area1(area.area1).each{|city|
				if (city.id == @user.city_id)
					ret << %Q!<option value="#{city.id}" selected="selected">#{city.name}</option>!
				else
					ret << %Q!<option value="#{city.id}">#{city.name}</option>!
				end
			}
			ret << %Q!</optgroup>!
		}
		return ret
	end
end
