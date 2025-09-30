local command = {}
function command.run(message, mt)
	local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json",defaultjson)
	local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)
	local time = sw:getTime()
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/lab/lab.json", "")
	local request = mt[1]

	if request == "spider" or request == "spiderweb" or request == "web" or request == "spider web" or (uj.lang ~= "en" and request == lang.request_spider_1 or request == lang.request_spider_2) then
		ynbuttons(message, lang.spider_alert, "spideruse", {}, uj.id, uj.lang)
		return true
	elseif request == "table" or (uj.lang ~= "en" and request == lang.request_table) then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.using_table,
			description = lang.use_table,
		} }
	elseif request == "poster" or request == "catposter" or request == "cat poster" or (uj.lang ~= "en" and request == lang.request_poster_1 or request == lang.request_poster_2 or request == lang.request_poster_3) then
		if wj.ws ~= 901 then
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.using_poster_before801,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/838793078574809098/blankwall.png'
				}
			} }
		else
			message.channel:send { embed = {
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
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.using_hole,
				description = lang.use_hole,
			} }
		end
	elseif request == "peculiar box" or request == "box" or request == "peculiarbox" or (uj.lang ~= "en" and request == lang.request_box_1 or request == lang.request_box_2 or request == lang.request_box_3) then
		local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/lab/box.json", "")
		if not uj.lastbox then
			uj.lastbox = -24
		end
		local cooldown = (uj.equipped == "stainedgloves") and 8 or 11.5
		if uj.lastbox + cooldown > time:toHours() then
			local minutesleft = math.ceil(uj.lastbox * 60 - time:toMinutes() + cooldown * 60)
			local durationtext = formattime(minutesleft, uj.lang)
			message.channel:send(formatstring(lang.wait_message, { durationtext }))
			return true
		end

		if not next(uj.inventory) then
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.embed_title,
				description = lang.embed_no_card,
			} }
			return true
		end

		if not uj.skipprompts then
			ynbuttons(message, {
				color = uj.embedc,
				title = lang.embed_title,
				description = message.author.mentionString .. lang.confirm_message,
			}, "usebox", {}, uj.id, uj.lang)
			return true
		else
			local iptable = {}
			for k, v in pairs(uj.inventory) do
				for i = 1, v do
					table.insert(iptable, k)
				end
			end

			local givecard = iptable[math.random(#iptable)]
			print("user giving " .. givecard)
			local boxpoolindex = math.random(#wj.boxpool)
			local getcard = wj.boxpool[boxpoolindex]
			print("user getting " .. getcard)

			uj.inventory[getcard] = uj.inventory[getcard] and uj.inventory[getcard] + 1 or 1
			uj.inventory[givecard] = uj.inventory[givecard] - 1
			if uj.inventory[givecard] == 0 then
				uj.inventory[givecard] = nil
			end

			wj.boxpool[boxpoolindex] = givecard

			message.channel:send(formatstring(lang.boxed_message,
				{ uj.id, cdb[givecard].name, uj.pronouns["their"], cdb[getcard].name, getcard }))

			if not uj.storage[getcard] then
				if not uj.togglecheckcard then
					message.channel:send(formatstring(lang.not_in_storage, { cdb[getcard].name }))
				end
			end
			uj.timesusedbox = uj.timesusedbox and uj.timesusedbox + 1 or 1
			uj.lastbox = time:toHours()
			if uj.sodapt then
				if uj.sodapt.box then
					uj.lastbox = uj.lastbox + uj.sodapt.box
					uj.sodapt.box = nil
					if uj.sodapt == {} then
						uj.sodapt = nil
					end
				end
			end
		end

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
		local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/lab/terminal.json", "")
		uj.timesused = uj.timesused and uj.timesused + 1 or 1
		if not mt[2] then
			mt[2] = ""
		end
		local filename = nil
		local embedfiles = nil
		local embed = {
			color = uj.embedc,
			title = lang.using_terminal,
			description = nil,
			footer = {
				text = message.author.name,
				icon_url = message.author.avatarURL
			}
		}
		print("on the terminal. doing my " .. mt[2])
		if wj.ws < 508 then
			if string.lower(mt[2]) == "gnuthca" then
				embed["image"] = { url =
				"https://cdn.discordapp.com/attachments/829197797789532181/838841498757234728/terminal3.png" }
				wj.ws = 508
			else
				embed["image"] = { url =
				"https://cdn.discordapp.com/attachments/829197797789532181/838841479698579587/terminal4.png" }
			end
		else
			if string.lower(mt[2]) == "gnuthca" then
				embed["description"] = lang.logged_in
				embed["image"] = { url =
				"https://cdn.discordapp.com/attachments/829197797789532181/838836625391484979/terminal2.gif" }
			elseif string.lower(mt[2]) == "cat" then
				embed["description"] = '`=^•_•^=`'
				embed["image"] = { url =
				"https://cdn.discordapp.com/attachments/829197797789532181/838840001310752788/terminalcat.gif" }
			elseif string.lower(mt[2]) == "dog" then
				embed["description"] = [[```
	 __
o-''|\\_____/)
 \\_/|_)     )
		\\  __  /
		(_/ (_/
					```]]
			elseif string.lower(mt[2]) == "savedata" then
				local data = "savedata/" .. uj.id .. ".json"
				if not (mt[3] == "") then
					data = usernametojson(mt[3])
				end
				if not data then
					embed["description"] = lang.savedata_not_found
				else
					embed["description"] = lang.savedata_success
					filename = data
				end
			elseif string.lower(mt[2]) == "piss" then
				embed["description"] = lang.piss_message
				embed["image"] = { url =
				"https://cdn.discordapp.com/attachments/793993844789870603/880369620442304552/unknown.png" }
			elseif string.lower(mt[2]) == "teikyou" then
				embed["image"] = { url =
				"https://cdn.discordapp.com/attachments/829197797789532181/849431570103664640/teikyou.png" }
			elseif string.lower(mt[2]) == "help" or mt[2] == "" then
				local command_options = { "HELP", "STATS", "UPGRADE", "CREDITS", "SAVEDATA" }
				if wj.ws >= 701 then command_options[#command_options + 1] = "LOGS" end
				if wj.ws >= 1102 then command_options[#command_options + 1] = "TRADE" end
				local prefix = wj.ws >= 1102 and "```" or "`"
				local join = wj.ws >= 1102 and "\n  " or "\n"
				embed["description"] = prefix .. lang.help_message .. join .. table.concat(command_options, join) .. prefix
				embed["image"] = { url =
				"https://cdn.discordapp.com/attachments/829197797789532181/838836625391484979/terminal2.gif" }
			elseif string.lower(mt[2]) == "stats" then
				embed["title"] = "Statistics"
				if not uj.timespulled then uj.timespulled = 0 end
				if not uj.timesshredded then uj.timesshredded = 0 end
				if not uj.timesused then uj.timesused = 0 end
				if not uj.timesitemused then uj.timesitemused = 0 end
				if not uj.timesprayed then uj.timesprayed = 0 end
				if not uj.timesstored then uj.timesstored = 0 end
				if not uj.timestraded then uj.timestraded = 0 end
				if not uj.timesusedbox then uj.timesusedbox = 0 end
				if not uj.timescardgiven then uj.timescardgiven = 0 end
				if not uj.tokensdonated then uj.tokensdonated = 0 end
				if not uj.timescardreceived then uj.timescardreceived = 0 end
				if not uj.timeslooked then uj.timeslooked = 0 end
				if not uj.timesdoubleclicked then uj.timesdoubleclicked = 0 end
				if not uj.timesthrown then uj.timesthrown = 0 end
				if not uj.timescaught then uj.timescaught = 0 end
				if not uj.timesitemgiven then uj.timesitemgiven = 0 end
				if not uj.timesitemreceived then uj.timesitemreceived = 0 end
				if not uj.timesprestiged then uj.timesprestiged = 0 end
				if not uj.timesrobbed then uj.timesrobbed = 0 end
				if not uj.timesrobsucceeded then uj.timesrobsucceeded = 0 end
				if not uj.timesrobfailed then uj.timesrobfailed = 0 end
				embed["description"] = lang.stats_message ..
				"\n```" ..
				lang.stats_timespulled ..
				uj.timespulled ..
				"\n" ..
				lang.stats_timesused ..
				uj.timesused ..
				"\n" ..
				lang.stats_timesitemused ..
				uj.timesitemused ..
				"\n" ..
				lang.stats_timeslooked ..
				uj.timeslooked ..
				"\n" ..
				lang.stats_timesprayed ..
				uj.timesprayed ..
				"\n" ..
				lang.stats_timesshredded ..
				uj.timesshredded ..
				"\n" ..
				lang.stats_timesstored ..
				uj.timesstored ..
				"\n" ..
				lang.stats_timestraded ..
				uj.timestraded ..
				"\n" ..
				lang.stats_timesusedbox ..
				uj.timesusedbox ..
				"\n" ..
				lang.stats_timesdoubleclicked ..
				uj.timesdoubleclicked ..
				"\n" ..
				lang.stats_timesdonated ..
				uj.tokensdonated ..
				"\n" ..
				lang.stats_timesitemgiven ..
				uj.timesitemgiven ..
				"\n" ..
				lang.stats_timesitemreceived ..
				uj.timesitemreceived ..
				"\n" ..
				lang.stats_timescardgiven ..
				uj.timescardgiven ..
				"\n" ..
				lang.stats_timescardreceived ..
				uj.timescardreceived ..
				"\n" ..
				lang.stats_timesthrown ..
				uj.timesthrown ..
				"\n" ..
				lang.stats_timescaught ..
				uj.timescaught ..
				"\n" ..
				lang.stats_timesprestiged ..
				uj.timesprestiged ..
				"\n" ..
				lang.stats_timesrobbed ..
				uj.timesrobbed ..
				"\n" ..
				lang.stats_timesrobsucceeded ..
				uj.timesrobsucceeded ..
				"\n" ..
				lang.stats_timesrobfailed ..
				uj.timesrobfailed .. (math.random(100) == 1 and "\n" .. lang.stats_factory or "") .. "```"
			elseif string.lower(mt[2]) == "credits" then
				embed["title"] = lang.credits_title
				embed["description"] =
				'https://docs.google.com/document/d/1WgUqA8HNlBtjaM4Gpp4vTTEZf9t60EuJ34jl2TleThQ/edit?usp=sharing'
			elseif string.lower(mt[2]) == "logs" then
				embed["title"] = lang.logs_title
				embed["description"] =
				'https://docs.google.com/document/d/1td9u_n-ou-yIKHKU766T-Ue4EdJGYThjcl-MRxRUA5E/edit?usp=sharing'
			elseif string.lower(mt[2]) == "laureladams" and wj.ws >= 701 then
				embed["title"] = lang.emaillogs_title
				embed["description"] =
				"https://docs.google.com/document/d/1_dXPtCVsvDOL_XHpQ6CzX8A2KcLtymPERV3MSEJ5eZo/edit?usp=sharing"
				if wj.ws == 701 then wj.ws = 702 end
			elseif string.lower(mt[2]) == "upgrade" then
				if (wj.ws >= 702 and wj.ws <= 1101) then
					ynbuttons(message, {
						color = uj.embedc,
						title = lang.using_terminal_upgrade,
						description = "A new RDCards version was detected! Would you like to upgrade?",
						image = {
							url = "https://media.discordapp.net/attachments/1030420309947469904/1412415322258145341/upgrade1101.png"
						},
						footer = {
							text = message.author.name,
							icon_url = message.author.avatarURL
						}
					}, "usehole", {}, uj.id, uj.lang)
					return true
				else
					if uj.tokens > 0 then
						if not uj.skipprompts then
							ynbuttons(message, {
								color = uj.embedc,
								title = lang.using_terminal_upgrade,
								description = formatstring(lang.upgrade_prompt, { uj.tokens }),
								image = {
									url = "https://cdn.discordapp.com/attachments/829197797789532181/838894186472275988/terminal5.png"
								},
								footer = {
									text = message.author.name,
									icon_url = message.author.avatarURL
								}
							}, "usehole", {}, uj.id, uj.lang)
							return true
						else
							uj.tokens = uj.tokens - 1
							uj.timesused = uj.timesused and uj.timesused + 1 or 1
							uj.tokensdonated = uj.tokensdonated and uj.tokensdonated + 1 or 1
							wj.tokensdonated = wj.tokensdonated + 1
							embed["description"] = formatstring(lang.donated_terminal, { wj.tokensdonated })
							embed["image"] = { url = upgradeimages[math.random(#upgradeimages)] }
						end
					else
						embed["description"] = lang.upgrade_no_tokens
						embed["image"] = { url =
						"https://cdn.discordapp.com/attachments/829197797789532181/838894186472275988/terminal5.png" }
					end
				end
			elseif string.lower(mt[2]) == "pull" then
				-- if (wj.ws == 1101) then
				-- if (wj.ws >= 904)  then
				--   embed["title"] = lang.pull_title
				--   embed["description"] = '`message.author.mentionString .. \" got a **\" .. KEY .. \"** card! The **\" .. KEY ..\"** card has been added to \" .. uj.pronouns[\"their\"] .. \"STORAGE. The shorthand form of this card is **\" .. newcard .. \"**.\" uj.storage.key = 1 dpf.savejson(\"savedata/\" .. message.author.id .. \".json\", uj)`'
				--   embed["image"] = {url = "https://cdn.discordapp.com/attachments/829197797789532181/865792363167219722/key.png"}
				--   uj.storage.key = 1
				-- else
				embed["description"] = lang.pull_jammed
				-- end
			elseif string.lower(mt[2]) == "trade" then
				if (wj.ws >= 1102) then
					local trade_cards = uj.themeoffers[uj.currentoffer]
					local show_trade = true
					if mt[3] then
						print("got response" .. mt[3])
						if string.lower(mt[3]) == "yes" then
							show_trade = false
							local can_trade = true
							for i, value in ipairs(trade_cards) do
								if not uj.inventory[value] then
									can_trade = false
								end
							end
							if can_trade then
								if uj.currentoffer == "_owo" then
									embed["description"] = formatstring(lang.trade_successful_engwish, { prefix })
									uj.hasengwish = true
								else
									embed["description"] = formatstring(lang.trade_successful_theme,
										{ string.upper(uj.currentoffer), prefix, uj.currentoffer })
									embed["color"] = embed_colors[uj.currentoffer].colorcode
									for i, value in ipairs(trade_cards) do
										uj.inventory[value] = uj.inventory[value] - 1
										if uj.inventory[value] == 0 then uj.inventory[value] = nil end
									end
									uj.unlocked_colors[uj.currentoffer] = true
								end
								reload_theme_trade(uj)
							else
								embed["description"] = lang.trade_not_enough
							end
						elseif string.lower(mt[3]) == "no" then
							show_trade = false
							embed["description"] = lang.trade_no
							embed["image"] = { url =
							"https://cdn.discordapp.com/attachments/829197797789532181/838836625391484979/terminal2.gif" }
						elseif string.lower(mt[3]) == "reload" then
							reload_theme_trade(uj)
							print("new theme offer: " .. tostring(uj.currentoffer))
							trade_cards = uj.themeoffers[uj.currentoffer]
							local funnystring = string.upper(trade_cards[1])
							for i, value in ipairs(trade_cards) do
								if i > 1 then
									funnystring = funnystring .. ", " .. string.upper(value)
								end
							end
							local name = uj.currentoffer ~= "_owo" and string.upper(uj.currentoffer) .. "_THEME" or "OWO_LANG"
							embed["description"] = formatstring(lang.trade_reload, { name, funnystring })
						else
							embed["description"] = lang.trade_unknown
						end
					end
					if show_trade then
						local funnystring = string.upper(trade_cards[1])
						for i, value in ipairs(trade_cards) do
							if i > 1 then
								funnystring = funnystring .. ", " .. string.upper(value)
							end
						end
						if not embed["description"] then
							local name = uj.currentoffer ~= "_owo" and string.upper(uj.currentoffer) .. "_THEME" or "OWO_LANG"
							embed["description"] = formatstring(lang.trade_offer, { name, funnystring })
						end
						if not embed["image"] then
							embed["image"] = { url = "attachment://terminal_trade.png" }
							embedfiles = { getthemeofferimage(uj) }
						end
					end
				else
					embed["description"] = formatstring(lang.unknown, { mt[2] })
				end
			else
				embed["description"] = formatstring(lang.unknown, { mt[2] })
			end
		end
		message.channel:send { embed = embed, files = embedfiles }
		if filename then
			message.channel:send {
				file = filename
			}
		end
	else
		return false
	end
	
	dpf.savejson("savedata/worldsave.json", wj)
	dpf.savejson("savedata/" .. message.author.id .. ".json",uj)
	return true
end
return command
