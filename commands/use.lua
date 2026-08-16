local command = {
	name = "use",
	description = "Use... something. anything.",
	options = {
		{
			name = "point_of_interest",
			description = "Something in the room interests you?",
			type = 1,
			options = {
				{
					name = "point_of_interest",
					description = "The thing in the world to use.",
					type = 3,
					required = true
				}
			}
		},
		{
			name = "consumable",
			description = "Use a consumable in your inventory!",
			type = 1,
			options = {
				{
					name = "consumable",
					type = 3,
					required = true,
					description = "The consumable to use"
				},
				{
					name = "args",
					type = 3,
					required = false,
					description = "Some consumables require extra data."
				}
			}
		}
	}
}
function command.run(message, mt, bypass)
	local author = message._author
	print(author.name .. " did !use")
	local uj = db.get_user(author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/nonroom.json", "")
	local request = string.lower(
		mt[1]
		or (mt.point_of_interest and mt.point_of_interest.point_of_interest)
		or (mt.consumable and mt.consumable.consumable)
	)
	local is_poi = (mt[1] or mt.point_of_interest) ~= nil

	if not (message.guild or bypass or constexttofn(request)) then
		message:reply(lang.dm_message)
		return
	end
	local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)
	if not uj.room then uj.room = 0 end
	if not uj.discovered_rooms then
		uj.discovered_rooms = { pyrowmid = true }
		if uj.room ~= 0 then
			if amids[uj.room] then
				uj.discovered_rooms[amids[uj.room]] = true
			end
		end
	end

	if request == "shop" and uj.room == 2 then
	else
		local newuj = automove(uj.room, request, message)
		if newuj then
			if newuj == "blacklisted" or newuj == "undiscovered" then
				return
			else
				uj = newuj
			end
		end
	end

	local found = true

	----------------------------------------------------------PYROWMID
	if (uj.room == 0 or bypass) and is_poi then
		found = cmd.pyrowmid_use.run(message, {request, mt[2], mt[3]})
	end

	----------------------------------------------------------LAB
	if (uj.room == 1 or bypass) and wj.labdiscovered and is_poi then
		found = cmd.lab_use.run(message, {request, mt[2], mt[3]})
	end

	----------------------------------------------------------WINDY MOUNTAINS
	if uj.room == 2 and is_poi then
		found = cmd.mountains_use.run(message, {request, mt[2], mt[3]})
	end

	----------------------------------------------------------SHOP
	if (uj.room == 3) and is_poi then
		found = cmd.shop_use.run(message, {request, mt[2], mt[3]})
	end

	if found then return end

	if (not found) and (not bypass) then ----------------------------------NON-ROOM ITEMS GO HERE!-------------------------------------------------
		local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/nonroom.json", "")
		if request == "token" or (uj.lang ~= "en" and request == lang.request_token) then
			if uj.tokens > 0 then
				message:reply(formatstring(lang.tokenflip,
					{ math.random(2) == 1 and lang.token_heads or lang.token_tails }))
			else
				message:reply(lang.no_tokens)
			end
			uj.timesused = uj.timesused and uj.timesused + 1 or 1
		elseif constexttofn(request) then
			print("using consumable")
			if not uj.consumables then
				uj.consumables = {}
			end
			request = constexttofn(request)
			if uj.consumables[request] then
				if not consdb[request].unusable then
					if not uj.skipprompts then
						ynbuttons(message, {
							color = uj.embedc,
							title = formatstring(lang.using, { consdb[request].name }),
							description = formatstring(lang.use_confirm, { consdb[request].name }),
						}, "useconsumable", { crequest = request, mt = mt }, uj.id, uj.lang)
						return
					else
						if request == "..." then request = "ddd" end
						if request ~= "ddd" then
							if uj.equipped == 'aceofhearts' then
								if uj.acepulls ~= 0 then
									message:reply('The pulls stored in your **Ace of Hearts** disappear...')
									uj.acepulls = 0
								end
							end
						end
						local fn = request
						if consdb[request].command then
							request = consdb[request].command
						end
						cmdcons[request].run(uj, "savedata/" .. message.author.id .. ".json", message, mt, nil, fn)
						return
					end
				else
					message:reply('You cannot use this item!')
				end
			else
				message:reply(formatstring(lang.donthave, { consdb[request].name }))
			end
		else
			message:reply(formatstring(lang.unknown, { mt[1] }))
		end
	end
	print("that's worrying if this is a room")
	dpf.savejson("savedata/worldsave.json", wj)
	dpf.savejson("savedata/" .. message.author.id .. ".json", uj)
end

return command
