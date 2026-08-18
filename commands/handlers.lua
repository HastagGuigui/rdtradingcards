-- NOT AN ACTUAL COMMAND FILE
-- this is used to store the interaction handlers

_G["db"] = {
	cache = {},
	get_user = function(userid)
		if not _G["db"].cache[userid] then
			_G["db"].cache[userid] = dpf.loadjson("savedata/" .. userid .. ".json", defaultjson)
		end
		return _G["db"].cache[userid]
	end,
	save_user = function(userid)
		if _G["db"].cache[userid] then
			dpf.savejson("savedata/" .. userid .. ".json", _G["db"].cache[userid])
		else
			print("Tried to save nothing! Thank the stars I caught it.")
		end
	end,
	uncache_user = function(userid)
		_G["db"].cache[userid] = nil
	end
}

_G["update_missing_fields"] = function(userid)
	local uj = db.get_user(userid)
	local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
	if not uj.embedc then
		uj.embedc = embed_colors["default"].colorcode
	end
	if not uj.has_seen_tutorials then
		uj.has_seen_tutorials = {}
	end
	-- if not uj.unlocked_colors then
	--   uj.unlocked_colors = {default = true}
	-- end
	-- if not uj.themeoffers then
	--   setup_theme_offers(uj)
	-- end
	if not sj.stocknum then
		sj.stocknum = 1
		dpf.savejson("savedata/shop.json", sj)
	end
	if not uj.lang then
		uj.lang = "en"
	end
	if not uj.pronouns["selection"] then
		uj.pronouns["selection"] = uj.pronouns["they"]
	end
	if not uj.lastrob then
		uj.lastrob = 0
	end
end

_G["handle_autocomplete"] = function(ia, cmd, focused_option, args)
	print(ia, cmd.name, focused_option.name, args)
	if cmdslash[cmd.name].autocomplete then
		local status, err = xpcall(function()
			cmdslash[cmd.name].autocomplete(ia, cmd, focused_option, args)
		end, debug.traceback)
		if not status then
			ia:autocomplete { {
				name = "An error occured! Please report...",
				value = "????"
			} }
			print(err)
		end
	end
end

_G["handleslash"] = function(interaction, command, args)
	print("args: " .. inspect(args))
	interaction._author = interaction.user
	if command.name == "c" then
		handlecprefix(interaction, command, args)
		return
	end
	if cmdslash[command.name] then
		if args == nil then args = {} end
		update_missing_fields(interaction._author.id)
		local status, err = xpcall(function()
			cmdslash[command.name].run(interaction, args)
		end, debug.traceback)
		if not status then
			print("uh oh")
			print(err)
			if errorping then
				interaction:reply("Oops! An error has occured! Error message: ```" ..
					err .. "``` (" .. config.errorping .. " please fix this thanks)")
			else
				interaction:reply("Oops! An error has occured! Error message: ```" ..
					err .. "``` (please fix this thanks)")
			end
		else
			db.save_user(interaction._author.id)
			db.uncache_user(interaction._author.id)
		end
	else
		interaction:reply("Command doesn't exist! This is bad. please report. ")
	end
end

_G['handlecprefix'] = function(interaction, command, args)
	local str_mt = args.args or ""
	local command_found = false
	print("/c command! " .. tostring(args.command))
	for _, v in ipairs(commands) do
		local trigger = string.gsub(v.trigger, prefix, "", 1)
		if string.trim(string.lower(args.command)) == trigger then
			print("found " .. v.trigger)
			command_found = true
			update_missing_fields(interaction._author.id)
			local mt = {}
			local nmt = {}
			if v.expectedargs == 0 then
				mt = string.split(str_mt, "/")
				for a, b in ipairs(mt) do
					b = string.trim(b)
					nmt[a] = b
				end
				if nmt[#mt] == "" then
					nmt[#mt] = nil
				end
			elseif v.expectedargs == 1 then
				nmt = { string.trim(str_mt) }
			end --might have to expand later?
			if v.force then
				for c, d in ipairs(v.force) do
					table.insert(nmt, c, d)
				end
			end
			print("nmt: " .. inspect(nmt))
			local status, err = xpcall(function()
				v.commandfunction.run(interaction, nmt, v.usebypass, nil)
			end, debug.traceback)
			if not status then
				print("uh oh")
				print(err)
				if errorping then
					interaction:reply("Oops! An error has occured! Error message: ```" ..
						err .. "``` (" .. config.errorping .. " please fix this thanks)")
				else
					interaction:reply("Oops! An error has occured! Error message: ```" ..
						err .. "``` (please fix this thanks)")
				end
			else
				db.save_user(interaction._author.id)
				db.uncache_user(interaction._author.id)
			end
			break
		end
	end
	if not command_found then
		interaction:reply("Command doesn't exist!", true)
	end
end

_G['handlemessage'] = function(message, content)
	message._author = message.author
	if message.author.id ~= client.user.id or content then
		local messagecontent = content or message.content
		for i, v in ipairs(commands) do
			if string.trim(string.lower(string.sub(messagecontent, 0, #v.trigger + 1))) == v.trigger then
				if not (message.author.bot == true) then
					update_missing_fields(message.author.id)
				end
				print("found " .. v.trigger)
				local mt = {}
				local nmt = {}
				if v.expectedargs == 0 then
					mt = string.split(string.sub(messagecontent, #v.trigger + 1), "/")
					for a, b in ipairs(mt) do
						b = string.trim(b)
						nmt[a] = b
					end
					if nmt[#mt] == "" then
						nmt[#mt] = nil
					end
				elseif v.expectedargs == 1 then
					nmt = { string.trim(string.sub(messagecontent, #v.trigger + 1)) }
				end --might have to expand later?
				if v.force then
					for c, d in ipairs(v.force) do
						table.insert(nmt, c, d)
					end
				end
				print("nmt: " .. inspect(nmt))
				local status, err = xpcall(function()
					v.commandfunction.run(message, nmt, v.usebypass, content)
				end, debug.traceback)
				if not status then
					print("uh oh")
					print(err)
					if errorping then
						message:reply("Oops! An error has occured! Error message: ```" ..
							err .. "``` (" .. config.errorping .. " please fix this thanks)")
					else
						message:reply("Oops! An error has occured! Error message: ```" ..
							err .. "``` (please fix this thanks)")
					end
				else
					db.save_user(message.author.id)
					db.uncache_user(message.author.id)
				end
				break
			end
		end
	end
end

_G["sort_types"] = {}

function sort_types.shorthand(card_1, card_2)
	return card_1[1] < card_2[1]
end

function sort_types.name(card_1, card_2)
	local c1 = (cdb[card_1[1]] and cdb[card_1[1]].name or card_1[1]):upper()
	local c2 = (cdb[card_2[1]] and cdb[card_2[1]].name or card_2[1]):upper()
	return c1 < c2
end

function sort_types.count(card_1, card_2)
	return card_1[2] < card_2[2]
end

function sort_types.rarity(card_1, card_2)
	local rar1 = rarities_invert[cdb[card_1[1]] and cdb[card_1[1]].type or "s"]
	local rar2 = rarities_invert[cdb[card_2[1]] and cdb[card_2[1]].type or "s"]
	local sell1 = rarity_sell_prices[rar1] or 999
	local sell2 = rarity_sell_prices[rar2] or 999
	sell1 = type(sell1) == "number" and sell1 or sell1[1]
	sell2 = type(sell2) == "number" and sell2 or sell2[1]
    if sell1 == sell2 then
        if rar1 == rar2 then
            return sort_types.shorthand(card_1, card_2)
        end
        return (rar1 or "ZZZZZZZ") < (rar2 or "ZZZZZZZ")
    end
	return sell1 < sell2
end

_G['ynbuttons'] = function(message, content, pressedfunc, data, userid, lang)
	local messagecontent, messageembed
	local langfile = dpf.loadjson("langs/" .. lang .. "/ynbuttons.json", "")

	if type(content) == "table" then
		messageembed = content
	else
		messagecontent = content
	end

	print('making yesbutton')
	local yesbutton = {
		type = 2, -- button type
		custom_id = "yes",
		label = langfile.button_yes,
		style = 3 -- success
	}

	print("making nobutton")
	local nobutton = {
		type = 2, -- button type
		custom_id = "no",
		label = langfile.button_no,
		style = 4 -- danger
	}

	print(inspect(messageembed))
	local message_content_field = {}
	if type(content) == "table" then
		message_content_field = messageembed
	else
		message_content_field = {
			type = 10,
			content = messagecontent
		}
	end

	local action_bar = {
		type = 1,
		components = { yesbutton, nobutton }
	}

	print("writing message")
	local newmessage = message:replyComponents {
		flags = 32768, -- google IS_COMPONENTS_V2. holy hell.
		components = { message_content_field, action_bar }
	}

	local pressed, interaction = newmessage:waitComponent("button", nil, 1000 * 1800, function(interaction)
		local reactionid = userid or message.author.id

		if interaction.user.id ~= reactionid then
			local uj2 = db.get_user(interaction.user.id)
			local langfile2 = dpf.loadjson("langs/" .. uj2.lang .. "/ynbuttons.json", "")
			interaction:reply(langfile2.cannot_interact, true)
		end

		return interaction.user.id == reactionid
	end)

	yesbutton["disabled"] = true
	nobutton["disabled"] = true

	newmessage:update { components = { message_content_field, action_bar } }

	if not pressed then
		print("Button timed out")
		return
	end

	print("Button pressed, running attached command")

	local status, err = xpcall(function()
		pressedfunc(message, interaction, data, interaction.data.custom_id, newmessage)
	end, debug.traceback)

	if not status then
		print("uh oh")
		if errorping then
			message:reply("Oops! An error has occured! Error message: ```" ..
				err .. "``` (" .. config.errorping .. " please fix this thanks)")
		else
			message:reply("Oops! An error has occured! Error message: ```" .. err .. "``` (please fix this thanks)")
		end
	end
end
