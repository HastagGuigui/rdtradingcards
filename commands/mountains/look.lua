local command = {}
function command.run(message, mt, uj, wj)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/look/mountains.json", "")
	local request = string.lower(mt[1]) --why tf didint i do this for all the other ones?????????????????
	if (request == "mountains" or request == "mountain" or request == "windymountains" or request == "the windy mountains" or request == "windy mountains" or mt[1] == "" or (uj.lang ~= "en" and mt[1] == lang.request_mountains_1 or mt[1] == lang.request_mountains_2 or mt[1] == lang.request_mountains_3)) then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.looking_at_mountains,
			description = lang.looking_mountains,
			image = {
				url = "https://cdn.discordapp.com/attachments/829197797789532181/871433038280675348/windymountains.png"
			}
		} }
	elseif (string.lower(mt[1]) == "pyrowmid" or (uj.lang ~= "en" and mt[1] == lang.request_pyrowmid)) then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.looking_at_pyrowmid,
			description = lang.looking_pyrowmid,
		} }
	elseif (string.lower(mt[1]) == "bridge" or (uj.lang ~= "en" and mt[1] == lang.request_bridge)) then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.looking_at_bridge,
			description = lang.looking_bridge,
		} }
	elseif (request == "shop" or request == "quaintshop" or request == "quaint shop" or (uj.lang ~= "en" and mt[1] == lang.request_shop_1 or mt[1] == lang.request_shop_2 or mt[1] == lang.request_shop_3 or mt[1] == lang.request_shop_4)) then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.looking_at_shop,
			description = lang.looking_shop,
		} }
	elseif (request == "barrels" or (uj.lang ~= "en" and mt[1] == lang.request_barrels)) then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.looking_at_barrels,
			description = lang.looking_barrels,
		} }
	elseif (request == "clouds" or (uj.lang ~= "en" and mt[1] == lang.request_clouds)) then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.looking_at_clouds,
			description = lang.looking_clouds,
		} }
	else
		return false
	end
	return true
end
return command