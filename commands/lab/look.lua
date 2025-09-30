local command = {}
function command.run(message, mt, uj, wj)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/look/lab.json", "")

	if (string.lower(mt[1]) == "lab" or string.lower(mt[1]) == "abandoned lab" or mt[1] == "" or (uj.lang ~= "en" and mt[1] == lang.request_lab_1 or mt[1] == lang.request_lab_2 or mt[1] == lang.request_lab_3)) and wj.labdiscovered then
		local laburl = "https://cdn.discordapp.com/attachments/829197797789532181/862885457854726154/lab_scanner.png"
		local labdesc = lang.looking_lab_post_901
		if wj.ws <= 9999 then
			laburl = labimages[getletterindex(string.sub(wj.lablooktext, wj.lablookindex + 1, wj.lablookindex + 1))]
			labdesc = lang.looking_lab
		end
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.looking_at_lab,
			description = labdesc,
			image = {
				url = laburl
			}
		} }
		wj.lablookindex = wj.lablookindex + 1
		wj.lablookindex = wj.lablookindex % string.len(wj.lablooktext)
		dpf.savejson("savedata/worldsave.json", wj)
	elseif (string.lower(mt[1]) == "spider" or string.lower(mt[1]) == "spiderweb" or string.lower(mt[1]) == "web" or string.lower(mt[1]) == "spider web" or (uj.lang ~= "en" and mt[1] == lang.request_spider_1 or mt[1] == lang.request_spider_2)) and wj.labdiscovered then
		local newmessage = ynbuttons(message, lang.spider_alert, "spiderlook", {}, uj.id, uj.lang)
	elseif (string.lower(mt[1]) == "terminal" or (uj.lang ~= "en" and mt[1] == lang.request_terminal)) and wj.labdiscovered then    --FONT IS MS GOTHIC AT 24PX, 8PX FOR SMALL FONT
		if wj.ws < 508 then
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_terminal,
				description = lang.looking_terminal_pre_508,
				image = {
					url = "https://cdn.discordapp.com/attachments/829197797789532181/838832581147361310/terminal1.png"
				}
			} }
		else
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_terminal,
				description = lang.looking_terminal,
				image = {
					url = "https://cdn.discordapp.com/attachments/829197797789532181/838836625391484979/terminal2.gif"
				}
			} }
		end
	elseif (string.lower(mt[1]) == "database" or (uj.lang ~= "en" and mt[1] == lang.request_database)) and wj.labdiscovered then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.looking_at_database,
			description = lang.looking_database,
			image = {
				url = labimages[getletterindex(string.sub(wj.lablooktext, wj.lablookindex + 1, wj.lablookindex + 1))]
			}
		} }
		wj.lablookindex = wj.lablookindex + 1

		wj.lablookindex = wj.lablookindex % string.len(wj.lablooktext)
		dpf.savejson("savedata/worldsave.json", wj)
	elseif (string.lower(mt[1]) == "table" or (uj.lang ~= "en" and mt[1] == lang.request_table)) and wj.labdiscovered then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.looking_at_table,
			description = lang.looking_table,
		} }
	elseif (string.lower(mt[1]) == "poster" or string.lower(mt[1]) == "catposter" or string.lower(mt[1]) == "cat poster" or (uj.lang ~= "en" and mt[1] == lang.request_poster_1 or mt[1] == lang.request_poster_2 or mt[1] == lang.request_poster_3)) and wj.labdiscovered then
		if tonumber(wj.ws) ~= 901 then   --normal cat poster
			local postermessage = { lang.looking_poster_1, lang.looking_poster_2, lang.looking_poster_3, lang.looking_poster_4,
				lang.looking_poster_5, lang.looking_poster_6, lang.looking_poster_7, lang.looking_poster_8, lang
					.looking_poster_9, lang.looking_poster_10, lang.looking_poster_11 }
			local posterimage = { "https://cdn.discordapp.com/attachments/829197797789532181/838962876751675412/poster1.png",
				"https://cdn.discordapp.com/attachments/829197797789532181/839214962786172928/poster3.png",
				"https://cdn.discordapp.com/attachments/829197797789532181/838791958905618462/poster4.png",
				"https://cdn.discordapp.com/attachments/829197797789532181/838799811813441607/poster6.png",
				"https://cdn.discordapp.com/attachments/829197797789532181/838937070616444949/poster7.png",
				"https://cdn.discordapp.com/attachments/829197797789532181/838819064884232233/poster8.png",
				"https://cdn.discordapp.com/attachments/829197797789532181/838799792267067462/poster9.png",
				"https://cdn.discordapp.com/attachments/829197797789532181/838864622878588989/poster10.png",
				"https://cdn.discordapp.com/attachments/829197797789532181/838870206687346768/poster11.png",
				"https://cdn.discordapp.com/attachments/829197797789532181/839214999884398612/poster12.png",
				"https://cdn.discordapp.com/attachments/829197797789532181/839215023662039060/poster13.png" }
			local cposter = math.random(1, #postermessage)
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_poster,
				description = postermessage[cposter],
				image = {
					url = posterimage[cposter]
				}
			} }
		else   -- pull away cat poster
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_poster,
				description = lang.looking_poster_901,
				image = {
					url = "https://cdn.discordapp.com/attachments/829197797789532181/860703201224949780/posterpeeling.png"
				}
			} }
		end
	elseif (string.lower(mt[1]) == "mouse hole" or string.lower(mt[1]) == "mouse" or string.lower(mt[1]) == "mousehole" or (uj.lang ~= "en" and mt[1] == lang.request_mousehole_1 or mt[1] == lang.request_mousehole_2 or mt[1] == lang.request_mousehole_3)) and wj.labdiscovered then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.looking_at_mousehole,
			description = lang.looking_mousehole,
		} }
	elseif (string.lower(mt[1]) == "peculiar box" or string.lower(mt[1]) == "box" or string.lower(mt[1]) == "peculiarbox" or (uj.lang ~= "en" and mt[1] == lang.request_box_1 or mt[1] == lang.request_box_2 or mt[1] == lang.request_box_3)) and wj.labdiscovered then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.looking_at_box,
			description = lang.looking_box,
		} }
	elseif (string.lower(mt[1]) == "scanner") and wj.ws >= 902 then
		message.channel:send { embed = {
			color = uj.embedc,
			title = "Looking at scanner...",
			description = 'TODO: scanner look text',
		} }
	else
		return false
	end
	return true
end

return command
