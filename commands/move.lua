local command = {
	name = "move",
	description = "Move to another location.",
	options = {
		{
			name = "location",
			description = "Where do you want to move?",
			type = 3,
			autocomplete = true
		}
	}
}

function command.autocomplete(ia, comm, focused_option, args)
	ia:autocomplete({
		{ name = "Pyrowmid",      value = "pyrowmid" },
		{ name = "Abandoned Lab", value = "lab" },
		{ name = "Mountains",     value = "mountains" },
		{ name = "Shop",          value = "shop" }
	})
end

_G["room_definitions"] = {
	[0] = {
		name = "pyrowmid", -- codename
		requirements = function(wj)  -- can anyone access it?
			return true
		end
	},
	[1] = {
		name = "lab",
		requirements = function(wj)
			return wj.ws >= 507 and wj.labdiscovered == true
		end
	},
	[2] = {
		name = "mountains",
		requirements = function(wj)
			return wj.ws >= 702
		end
	},
	[3] = {
		name = "shop",
		requirements = function(wj)
			return wj.ws >= 702
		end
	}
}

function command.run(message, mt)
	local author = message._author
	print(author.name .. " did !move")

	local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)
	local uj = db.get_user(author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/move.json", "")
	if not mt[1] or mt.location then
		mt[1] = "pyrowmid"
	end
	local locations = { lang.locations_pyrowmid, lang.locations_lab, lang.locations_mountains, lang.locations_shop, lang
		.locations_hallway, lang.locations_casino }
	local success = false
	local request = string.lower(mt[1] or mt.location)
	local newroom = 0

	--0: pyrowmid
	--1: lab
	--2: mountain
	--3: shop
	--4: hallway
	--5: casino

	for i, entry in pairs(room_definitions) do
		if entry.requirements(wj) then
			if request == lang["request_" .. entry.name] then
				success = true
				newroom = i
			elseif type(lang["request_" .. entry.name]) == "table" then
				for _, trigger in ipairs(lang["request_" .. entry.name]) do
					if request == trigger then
						success = true
						newroom = i
						break
					end
				end
			end
			if success then
				break
			end
		end
	end

	if success then
		print("newroom is " .. newroom)
		local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
		if newroom == uj.room then
			message:reply(formatstring(lang.already_in, { locations[newroom + 1] }))
			return
		elseif newroom == 3 and uj.lastrob + 4 > sj.stocknum and uj.lastrob ~= 0 then
			lang = dpf.loadjson("langs/" .. uj.lang .. "/rob.json")
			local time = sw:getTime()
			local stocksleft = uj.lastrob + 4 - sj.stocknum
			local stockstring = formatstring(lang.more_restock, { stocksleft })
			if lang.needs_plural_s == true then
				if stocksleft > 1 then
					stockstring = stockstring .. lang.plural_s
				end
			end
			local minutesleft = math.ceil((26 / 24 - time:toDays() + sj.lastrefresh) * 24 * 60)

			local durationtext = formattime(minutesleft, uj.lang)
			if uj.lastrob + 3 == sj.stocknum then
				message:reply(formatstring(lang.blacklist_next, { durationtext }))
			else
				message:reply(formatstring(lang.blacklist, { stockstring, durationtext }))
			end
			return "blacklisted"
		else
			uj.room = newroom
			local eu = uj.lang == "ko" and lang.eu or ""
			message:reply(formatstring(lang.room_changed, { locations[newroom + 1], eu }))
			return uj
		end
	else
		message:reply(formatstring(lang.no_room, { request }))
	end
end

return command
