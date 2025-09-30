local command = {}
function command.run(message, mt)
	local time = sw:getTime()
	local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json",defaultjson)
	local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/mountains.json")
	local request = mt[1]
	
	if (request == "pyrowmid" or (uj.lang ~= "en" and request == lang.request_pyrowmid)) then
		message.channel:send(lang.use_pyrowmid)
		uj.room = 0
		dpf.savejson("savedata/" .. message.author.id .. ".json", uj)
		cmd.look.run(message, { "pyrowmid" })
		--TODO: find a way to show a location's main c!look?
	elseif (request == "bridge" or (uj.lang ~= "en" and request == lang.request_bridge)) then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.using_bridge,
			description = lang.use_bridge,
		} }
	elseif (request == "shop" or request == "quaintshop" or request == "quaint shop" or (uj.lang ~= "en" and request == lang.request_shop_1 or request == lang.request_shop_2 or request == lang.request_shop_3 or request == lang.request_shop_4)) then
		local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
		if uj.lastrob + 4 > sj.stocknum and uj.lastrob ~= 0 then
			lang = dpf.loadjson("langs/" .. uj.lang .. "/rob.json")
			local stocksleft = uj.lastrob + 4 - sj.stocknum
			local stockstring = lang.more_restock_1 .. stocksleft .. lang.more_restock_2
			if lang.needs_plural_s == true then
				if stocksleft > 1 then
					stockstring = stockstring .. lang.plural_s
				end
			end
			local minutesleft = math.ceil((26 / 24 - time:toDays() + sj.lastrefresh) * 24 * 60)

			local durationtext = formattime(minutesleft, uj.lang)
			if uj.lastrob + 3 == sj.stocknum then
				message.channel:send(formatstring(lang.blacklist_next, { durationtext }))
			else
				message.channel:send(formatstring(lang.blacklist, { stockstring, durationtext }))
			end
			return true, uj, wj
		else
			message.channel:send(lang.use_shop)
			uj.room = 3
			dpf.savejson("savedata/" .. message.author.id .. ".json", uj)
		end
	elseif (request == "barrels" or (uj.lang ~= "en" and request == lang.request_barrels)) then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.using_barrels,
			description = lang.use_barrels,
		} }
	elseif (request == "clouds" or (uj.lang ~= "en" and request == lang.request_clouds)) then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.using_clouds,
			description = lang.use_clouds,
		} }
	else
		return false
	end
  	dpf.savejson("savedata/" .. message.author.id .. ".json",uj)
	return true
end

return command
