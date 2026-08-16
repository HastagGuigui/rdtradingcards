local command = {}
function command.run(message, mt)
	local uj = db.get_user(message.author.id)
	local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)
	local time = sw:getTime()
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/lab/lab.json", "")
	local request = mt[1]

	if request == "spider" or request == "spiderweb" or request == "web" or request == "spider web" or (uj.lang ~= "en" and request == lang.request_spider_1 or request == lang.request_spider_2) then
		ynbuttons(message, lang.spider_alert, "spideruse", {}, uj.id, uj.lang)
		return true
	elseif request == "table" or (uj.lang ~= "en" and request == lang.request_table) then
		message:reply { embed = {
			color = uj.embedc,
			title = lang.using_table,
			description = lang.use_table,
		} }
	elseif request == "poster" or request == "catposter" or request == "cat poster" or (uj.lang ~= "en" and request == lang.request_poster_1 or request == lang.request_poster_2 or request == lang.request_poster_3) then
		if wj.ws ~= 901 then
			message:reply { embed = {
				color = uj.embedc,
				title = lang.using_poster_before801,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/838793078574809098/blankwall.png'
				}
			} }
		else
			message:reply { embed = {
				color = uj.embedc,
				title = lang.using_poster,
				description = lang.use_poster,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/862883805786144768/scanner.png'
				}
			} }
			wj.ws = 902
		end
	elseif request == "mouse hole" or request == "mouse" or request == "mousehole" or (uj.lang ~= "en" and request == lang.request_hole_1 or request == lang.request_hole_2 or request == lang.request_hole_3) then
		if uj.equipped == "brokenmouse" then
			ynbuttons(message, {
				color = uj.embedc,
				title = lang.using_hole,
				description = message.author.mentionString .. lang.use_hole_mouse,
			}, "usemousehole", {}, uj.id, uj.lang)
			return true
		else
			message:reply { embed = {
				color = uj.embedc,
				title = lang.using_hole,
				description = lang.use_hole,
			} }
		end
	elseif request == "peculiar box" or request == "box" or request == "peculiarbox" or (uj.lang ~= "en" and request == lang.request_box_1 or request == lang.request_box_2 or request == lang.request_box_3) then
		cmd.lab_box.use(message, mt, uj, wj)

		-- elseif request == "scanner" and wj.ws >= 902 then
		--   if wj.ws < 904 then -- lab not unlocked
		--     if uj.storage.key then
		--       --interact with key card and unlock hallway
		--       wj.ws = 904
		--     else
		--       -- no key card, but interacted with
		--     end
		--   else
		--     --hallway unlocked
		--   end
	elseif request == "terminal" or (uj.lang ~= "en" and request == lang.request_terminal) then
		cmd.lab_terminal.use(message, mt, uj, wj)
	else
		return false
	end

	dpf.savejson("savedata/worldsave.json", wj)
	return true
end

return command
