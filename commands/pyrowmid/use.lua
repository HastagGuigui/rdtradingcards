local command = {}
function command.run(message, mt)
	local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json",defaultjson)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/shop/pet.json", "") -- fallback when request is not shop
	local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)
	local request = string.lower(mt[1])
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/pyrowmid/pyrowmid.json", "")
	if request == "strange machine" or request == "machine" or (uj.lang ~= "en" and request == lang.request_machine_1 or request == lang.request_machine_2 or request == lang.request_machine_3) then
		local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/pyrowmid/machine.json", "")
		if not uj.tokens then
			uj.tokens = 0
		end
		if not uj.items then
			uj.items = { nothing = true }
		end
		if wj.ws ~= 506 then
			if not uj.skipprompts then
				ynbuttons(message, {
					color = uj.embedc,
					title = lang.using_machine,
					description = formatstring(lang.use_machine, { uj.tokens }),
				}, "usemachine", {}, uj.id, uj.lang)
			else
				cmdre.usemachine.run(message, null,null,"yes")
			end
			return true
		else
			if uj.tokens >= 4 then
				ynbuttons(message, {
					color = uj.embedc,
					title = lang.using_machine,
					description = formatstring(lang.use_machine_four, { uj.tokens }),
				}, "getladder", {}, uj.id, uj.lang)
				return true
			else
				message:reply(lang.notokens_four)
			end
		end
	elseif request == "hole" or (uj.lang ~= "en" and request == lang.request_hole) then
		if uj.tokens == nil then uj.tokens = 0 end
		if wj.ws >= 506 or wj.ws < 501 then
			message:reply(lang.hole_nodonations)
			return true
		end
		if uj.tokens > 0 then
			ynbuttons(message, {
				color = uj.embedc,
				title = lang.using_hole,
				description = formatstring(lang.use_hole, { uj.tokens }),
			}, "usehole", {}, uj.id, uj.lang)
			return true
		else
			message:reply(lang.hole_notokens)
		end
	elseif request == "panda" or (uj.lang ~= "en" and request == lang.request_panda) then
		if uj.equipped == "coolhat" then
			if not uj.storage.ssss45 then
				message:reply(lang.panda_ssss45)
				uj.storage.ssss45 = 1
			else
				message:reply(':pensive:')
			end
		else
			message:reply(':flushed:')
		end
		uj.timesused = uj.timesused and uj.timesused + 1 or 1
	elseif request == "throne" or (uj.lang ~= "en" and request == lang.request_throne) then
		message:reply(lang.throne_by_panda)
		uj.timesused = uj.timesused and uj.timesused + 1 or 1
	elseif (request == "necklace" or request == "faithfulnecklace" or request == "faithful necklace" or (uj.lang ~= "en" and request == lang.request_necklace)) and uj.items["faithfulnecklace"] then
		message:reply(lang.wash_necklace)
		uj.timesused = uj.timesused and uj.timesused + 1 or 1
	elseif request == "ladder" or (uj.lang ~= "en" and request == lang.request_ladder) then
		if wj.ws >= 507 then
			local embedtitle = lang.using_ladder
			if not wj.labdiscovered then
				embedtitle = lang.discovered_lab
				wj.labdiscovered = true
			end
			message:reply { embed = {
				color = uj.embedc,
				title = embedtitle,
				description = lang.used_ladder,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/831907381830746162/labfade.gif'
				}
			} }
			uj.room = 1
			dpf.savejson("savedata/worldsave.json", wj)
			dpf.savejson("savedata/" .. message.author.id .. ".json", uj)
			return true
		else
			message:reply { embed = {
				color = uj.embedc,
				title = lang.using_ladder,
				description = lang.using_ladder_small,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/831868583696269312/nowigglezone.png'
				}
			} }
		end
	else
		return false
	end
	dpf.savejson("savedata/" .. message.author.id .. ".json", uj)
	return true
end
return command
