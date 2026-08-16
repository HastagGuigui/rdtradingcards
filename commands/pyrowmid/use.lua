local command = {}

function command.ladder(message, uj, wj, lang)
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
end

function command.panda(message, uj, wj, lang)
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
end

function command.run(message, mt)
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/pyrowmid/pyrowmid.json", "") -- fallback when request is not shop
	local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)
	local request = string.lower(mt[1])
	if request == "strange machine" or request == "machine" or (uj.lang ~= "en" and request == lang.request_machine_1 or request == lang.request_machine_2 or request == lang.request_machine_3) then
		cmd.pyrowmid_machine.use(message, uj, wj)
	elseif request == "hole" or (uj.lang ~= "en" and request == lang.request_hole) then
		cmd.pyrowmid_donation_hole.use(message, uj, wj)
	elseif request == "panda" or (uj.lang ~= "en" and request == lang.request_panda) then
		command.panda(message, uj, wj, lang)
	elseif request == "throne" or (uj.lang ~= "en" and request == lang.request_throne) then
		message:reply(lang.throne_by_panda)
		uj.timesused = uj.timesused and uj.timesused + 1 or 1
	elseif (request == "necklace" or request == "faithfulnecklace" or request == "faithful necklace" or (uj.lang ~= "en" and request == lang.request_necklace)) and uj.items["faithfulnecklace"] then
		message:reply(lang.wash_necklace)
		uj.timesused = uj.timesused and uj.timesused + 1 or 1
	elseif request == "ladder" or (uj.lang ~= "en" and request == lang.request_ladder) then
		command.ladder(message, uj, wj, lang)
	else
		return false
	end
	return true
end

return command
