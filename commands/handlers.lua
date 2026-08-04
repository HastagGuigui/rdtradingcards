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
	if command.name == "c" then
		handlecprefix(interaction, command, args)
		return
	end
	if cmdslash[command.name] then
		if args == nil then args = {} end
		update_missing_fields(interaction.user.id)
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
			db.save_user(interaction.user.id)
			db.uncache_user(interaction.user.id)
		end
	else
		interaction:reply("Command doesn't exist! This is bad. please report. ")
	end
end

_G['handlecprefix'] = function(interaction, command, args)
	local str_mt = args.args
	print("/c command! " .. tostring(args.command))
	for _, v in ipairs(commands) do
		local trigger = string.gsub(v.trigger, prefix, "", 1)
		if string.trim(string.lower(args.command)) == trigger then
			print("found " .. v.trigger)
			update_missing_fields(interaction.user.id)
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
				db.save_user(interaction.user.id)
				db.uncache_user(interaction.user.id)
			end
			break
		end
	end
end

_G['handlemessage'] = function(message, content)
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
