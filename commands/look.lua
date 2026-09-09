local command = {
	name = "look",
	description = "Allows you to look at things.",
	options = {
		{
			name = "point_of_interest",
			description = "Look at something in the room you're in.",
			type = 3,
			autocomplete = true
		},
		{
			name = "object",
			description = "A card, an item, a medal, etc...",
			type = 3,
			autocomplete = true
		}
	}
}

function command.autocomplete(ia, comm, focused_option, args)
	local uj = db.get_user(ia.user.id)
	local out = {}
	if focused_option.name == "point_of_interest" then
		local points_of_interest = {
			[0] = cmd.pyrowmid_look.points_of_interest,
			[1] = cmd.lab_look.points_of_interest,
			[2] = cmd.mountains_look.points_of_interest,
			[3] = cmd.shop_look.points_of_interest
		}
		for _, point in pairs(points_of_interest[uj.room]) do
			out[#out + 1] = {
				name = point,
				value = point
			}
		end
	elseif focused_option.name == "object" then
		local cardlist = {}
		local namelist = {}
		for k, v in pairs(uj.inventory) do
			cardlist[k] = true
		end
		for k, v in pairs(uj.storage) do
			cardlist[k] = true
		end
		for k, _ in pairs(cardlist) do
			local name = cdb[k] and cdb[k].name or "UNKNOWN CARD"
			if (string.find(name, args.object) or string.find(k, args.object)) and #namelist < 25 then
				namelist[#namelist + 1] = { name = string.format("%s (%s, card)", name, k ), value = k }
			end
		end
		for k, v in pairs(uj.items) do
			local name = itemdb[k].name
			if (string.find(name, args.object) or string.find(k, args.object)) and #namelist < 25 then
				namelist[#namelist + 1] = { name = string.format("%s (%s, item)", name, k ), value = k }
			end
		end
        for k, v in pairs(uj.consumables) do
            local name = consdb[k].name
            if (string.find(name, args.object) or string.find(k, args.object)) and #namelist < 25 then
                namelist[#namelist + 1] = { name = string.format("%s (%s, consumable)", name, k ), value = k }
            end
        end
        print("Choice count: ", #namelist)
		out = namelist
	end
	ia:autocomplete(out)
end

function command.run(message, mt)
	local author = message.author or message.user
	print(author.name .. " did !look")
	local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)
	if not wj.ws then
		wj.ws = 508
		dpf.savejson("savedata/worldsave.json", wj)
	end
	local uj = db.get_user(author.id)

	if uj.room == nil then
		uj.room = 0
	end

	if uj.timeslooked == nil then
		uj.timeslooked = 1
	else
		uj.timeslooked = uj.timeslooked + 1
	end

	local query = mt[1]

	if not mt[1] then
		if mt["point_of_interest"] then
			query = mt["point_of_interest"]
		elseif mt["object"] then
			query = mt["object"]
		else
			query = ""
		end
	end

	if texttofn(query) or itemtexttofn(query) or constexttofn(query) or medaltexttofn(query) then
		if (nopeeking and (uj.inventory[texttofn(query)] or uj.storage[texttofn(query)] or uj.items[itemtexttofn(query)] or uj.medals[medaltexttofn(query)])) or not nopeeking then
			if texttofn(query) then
				cmd.show.run(message, { query })
			elseif itemtexttofn(query) or constexttofn(query) then
				cmd.showitem.run(message, { query })
			elseif medaltexttofn(query) then
				cmd.showmedal.run(message, { query })
			end
			return
		end
	end

	local found = true
	if uj.room == 0 then -- PYROWMID --
		found = cmd.pyrowmid_look.run(message, { query }, uj, wj)
	end

	if uj.room == 1 then -- LAB --
		found = cmd.lab_look.run(message, { query }, uj, wj)
	end

	if uj.room == 2 then -- MOUNTAINS --
		found = cmd.mountains_look.run(message, { query }, uj, wj)
	end

	if uj.room == 3 then -- SHOP --
		found = cmd.shop_look.run(message, { query }, uj, wj)
	end

	if not found then                                                                                                                                                                                                                                                                                   ----------------------------------NON-ROOM ITEMS GO HERE!--------------------------------------------------
		local lang = dpf.loadjson("langs/" .. uj.lang .. "/look/nonrooms.json", "")
		if string.lower(query) == "card factory" or string.lower(query) == "factory" or string.lower(query) == "cardfactory" or string.lower(query) == "the card factory" or (uj.lang ~= "en" and query == lang.request_factory_1 or query == lang.request_factory_2 or query == lang.request_factory_3) then --TODO: move these to not found
			message:reply {
				content = lang.looking_factory
			}
		elseif string.lower(query) == "token" or (uj.lang ~= "en" and query == lang.request_token) then
			message:reply { embed = {
				color = uj.embedc,
				title = lang.looking_at_token,
				description = lang.looking_token,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/829255830485598258/token.png'
				}
			} }
		else
			message:reply(lang.not_found_1 .. query .. lang.not_found_2)
			uj.timeslooked = uj.timeslooked - 1
		end
	end
end

return command
