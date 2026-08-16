local command = {
	name = "terminal",
	description = "Access the terminal. If you know, you know.",
	pre_508_subcommands = {},
	subcommands = {}
}

function command.run(message, mt)
	local uj = db.get_user(message._author.id)
	local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)
	if (uj.unlocked_commands and uj.unlocked_commands.lab) or uj.room == 1 then
		command.use(message, mt, uj, wj)
	else
		message:reply(formatstring("You haven't discovered this yet! Try using {1} and {2} to find it.", {
			formatslash("look", message.guild.id), formatslash("move", message.guild.id),
		}))
	end
end

function command.pre_508_subcommands.gnuthca(message, mt, uj, wj, lang, embed)
	embed["image"] = {
		url = "https://cdn.discordapp.com/attachments/829197797789532181/838841498757234728/terminal3.png"
	}
	wj.ws = 508
end

function command.pre_508_subcommands.UNKNOWN(message, mt, uj, wj, lang, embed)
	embed["image"] = {
		url =
		"https://cdn.discordapp.com/attachments/829197797789532181/838841479698579587/terminal4.png"
	}
end

function command.subcommands.gnuthca(message, mt, uj, wj, lang, embed)
	embed["description"] = lang.logged_in
	embed["image"] = {
		url =
		"https://cdn.discordapp.com/attachments/829197797789532181/838836625391484979/terminal2.gif"
	}
end

function command.subcommands.cat(message, mt, uj, wj, lang, embed)
	embed["description"] = '`=^•_•^=`'
	embed["image"] = {
		url =
		"https://cdn.discordapp.com/attachments/829197797789532181/838840001310752788/terminalcat.gif"
	}
end

function command.subcommands.dog(message, mt, uj, wj, lang, embed)
	embed["description"] = [[```
	 __
o-''|\\_____/)
 \\_/|_)     )
		\\  __  /
		(_/ (_/
					```]]
end

function command.subcommands.savedata(message, mt, uj, wj, lang, embed)
	-- TODO: REWORK SAVEDATA
	local data = "savedata/" .. uj.id .. ".json"
	if mt[3] and not (mt[3] == "") then
		data = usernametojson(mt[3])
	end
	if not data then
		embed["description"] = lang.savedata_not_found
	else
		embed["description"] = lang.savedata_success
		filename = data
	end
end

function command.subcommands.piss(message, mt, uj, wj, lang, embed)
	embed["description"] = lang.piss_message
	embed["image"] = {
		url =
		"https://cdn.discordapp.com/attachments/793993844789870603/880369620442304552/unknown.png"
	}
end

function command.subcommands.teikyou(message, mt, uj, wj, lang, embed)
	embed["image"] = {
		url =
		"https://cdn.discordapp.com/attachments/829197797789532181/849431570103664640/teikyou.png"
	}
end

function command.subcommands.help(message, mt, uj, wj, lang, embed)
	local command_options = { "HELP", "STATS", "UPGRADE", "CREDITS", "SAVEDATA" }
	if wj.ws >= 701 then command_options[#command_options + 1] = "LOGS" end
	if wj.ws >= 1202 then command_options[#command_options + 1] = "TRADE" end
	local prefix = wj.ws >= 1202 and "```" or "`"
	local join = wj.ws >= 1202 and "\n  " or "\n"
	embed["description"] = prefix .. lang.help_message .. join .. table.concat(command_options, join) .. prefix
	embed["image"] = {
		url =
		"https://cdn.discordapp.com/attachments/829197797789532181/838836625391484979/terminal2.gif"
	}
end

function command.subcommands.stats(message, mt, uj, wj, lang, embed)
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
end

function command.subcommands.credits(message, mt, uj, wj, lang, embed)
	embed["title"] = lang.credits_title
	embed["description"] =
	'https://docs.google.com/document/d/1WgUqA8HNlBtjaM4Gpp4vTTEZf9t60EuJ34jl2TleThQ/edit?usp=sharing'
end

function command.subcommands.logs(message, mt, uj, wj, lang, embed)
	embed["title"] = lang.logs_title
	embed["description"] =
	'https://docs.google.com/document/d/1td9u_n-ou-yIKHKU766T-Ue4EdJGYThjcl-MRxRUA5E/edit?usp=sharing'
end

function command.subcommands.laureladams(message, mt, uj, wj, lang, embed)
	if wj.ws < 701 then return end
	embed["title"] = lang.emaillogs_title
	embed["description"] =
	"https://docs.google.com/document/d/1_dXPtCVsvDOL_XHpQ6CzX8A2KcLtymPERV3MSEJ5eZo/edit?usp=sharing"
	if wj.ws == 701 then wj.ws = 702 end
end

function command.subcommands.upgrade(message, mt, uj, wj, lang, embed)
	if uj.tokens > 0 then
		if not uj.skipprompts then
			ynbuttons(message, {
				color = uj.embedc,
				title = lang.using_terminal_upgrade,
				description = formatstring(lang.upgrade_prompt, { uj.tokens }),
				image = {
					url =
					"https://cdn.discordapp.com/attachments/829197797789532181/838894186472275988/terminal5.png"
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
		embed["image"] = {
			url =
			"https://cdn.discordapp.com/attachments/829197797789532181/838894186472275988/terminal5.png"
		}
	end
end

function command.subcommands.pull(message, mt, uj, wj, lang, embed)
	-- if (wj.ws == 1101) then
	-- if (wj.ws >= 904)  then
	--   embed["title"] = lang.pull_title
	--   embed["description"] = '`message.author.mentionString .. \" got a **\" .. KEY .. \"** card! The **\" .. KEY ..\"** card has been added to \" .. uj.pronouns[\"their\"] .. \"STORAGE. The shorthand form of this card is **\" .. newcard .. \"**.\" uj.storage.key = 1 dpf.savejson(\"savedata/\" .. message.author.id .. \".json\", uj)`'
	--   embed["image"] = {url = "https://cdn.discordapp.com/attachments/829197797789532181/865792363167219722/key.png"}
	--   uj.storage.key = 1
	-- else
	embed["description"] = lang.pull_jammed
	-- end
end

function command.subcommands.UNKNOWN(message, mt, uj, wj, lang, embed)
	embed["description"] = formatstring(lang.unknown, { mt[2] })
end

function command.use(message, mt, uj, wj)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/lab/terminal.json", "")
	uj.timesused = uj.timesused and uj.timesused + 1 or 1
	mt.command = mt.command or mt[2] or ""

	local out = nil
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
	print("on the terminal. doing my " .. mt.command)
	local request = string.lower(mt.command)
	if wj.ws < 508 then
		if not command.pre_508_subcommands[request] then request = "UNKNOWN" end
		out = command.pre_508_subcommands[request](message, mt, uj, wj, lang, embed)
	else
		if request == "" then request = "help" end
		if not command.subcommands[request] then request = "UNKNOWN" end
		out = command.subcommands[request](message, mt, uj, wj, lang, embed)
	end
	if out then return out end
	message:reply { embed = embed, files = embedfiles }
	if filename then
		message:reply {
			file = filename
		}
	end
	if not uj.unlocked_commands then
		uj.unlocked_commands = {}
	end
	uj.unlocked_commands.lab = true
end

return command
