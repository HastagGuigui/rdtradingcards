local command = {
	name = "fullstorage",
	description = "Sends your entire storage in DMs.",
	options = {
		{
			name = "show-season",
			type = 5, -- BOOLEAN
			description = "Shows seasons on cards. (Default: false)",
			required = false
		},
		{
			name = "season-filter",
			type = 3, -- STRING
			description = "In format \"1,2,3\". Also accepts 'maestro' as a shorthand for seasons 1 to 8.",
			required = false
		},
		{
			name = "rarity-filter",
			type = 3, -- STRING
			description =
			"In format \"sr,ur\". Rarity names are the ones used in card shorthands.",
			required = false
		},
		{
			name = "sorting",
			type = 3,
			description = "How cards should be ordered",
			required = false,
			choices = {
				{ name = "shorthand", value = "shorthand" },
				{ name = "name",      value = "name" },
				{ name = "count",     value = "count" },
				{ name = "rarity",    value = "rarity" },
			}
		}
	}
}
function command.run(message, mt)
	local author = message._author
	print(author.name .. " did !fullstorage")
	local uj = db.get_user(author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/fullstorage.json", "")
	local placeholder = dpf.loadjson("langs/" .. uj.lang .. "/look/missingcard.json", "")

	if message.replyDeferred then
		message:replyDeferred()
	end

	local enableSeason = false

	local filterSeasons = {}
	local filterSeasonsCount = 0
	local filterRarities = {}
	local filterRaritiesCount = 0
	local sort_type = "rarity"

	local args = {}
	if mt[1] then
		for substring in mt[1]:gmatch("%S+") do
			table.insert(args, substring)
		end
	elseif next(mt) ~= nil then
		if mt["show-season"] ~= nil then enableSeason = mt["show-season"] end
		if mt["season-filter"] ~= nil then
			for substring in mt["season-filter"]:gmatch('([^,]+)') do
				if substring == "maestro" then
					for i = 1, 8, 1 do
						filterSeasons[i] = true
						filterSeasonsCount = filterSeasonsCount + 1
					end
				end
				table.insert(args, "-season" .. substring)
			end
		end
		if mt["rarity-filter"] ~= nil then
			for substring in mt["rarity-filter"]:gmatch('([^,]+)') do
				if rarities[substring] then
					filterRarities[substring] = true
					filterRaritiesCount = filterRaritiesCount + 1
				end
			end
		end
		if mt["sorting"] and sort_types[mt.sorting] then
			sort_type = mt.sorting
		end
	end

	for index, value in ipairs(args) do
		if string.find(value, "-season") then
			if value == "-season" then
				enableSeason = true
				print("-season enabled")
			else
				local num = string.gsub(value, "-season", "") -- fuck you gsub
				local season = math.abs(tonumber(num))
				if season and season <= 11 then
					filterSeasons[season] = true
					filterSeasonsCount = filterSeasonsCount + 1
					print("filtering for season " .. season)
				end
			end
		elseif string.find(value, "-rarity") then
			local rarity = string.gsub(value, "-rarity", "")
			if rarities[rarity] then
				filterRarities[rarity] = true
				filterRaritiesCount = filterRaritiesCount + 1
				print("filtering for rarity " .. rarity)
			end
		elseif string.find(value, "-sort-") then
			local sorting_method = string.gsub(value, "-sort-", "")
			if sort_types[sorting_method] then
				sort_type = sorting_method
			end
		else
			local filename = usernametojson(value)
			if filename then
				uj = dpf.loadjson(filename, defaultjson)
			end
		end
	end

	local storetable = {}
	local storestring = ''
	local invfilter = table.shallow_copy(uj.storage)

	if filterSeasonsCount > 0 then
		for k, v in pairs(invfilter) do
			if not filterSeasons[cdb[k] and cdb[k].season or -1] then
				invfilter[k] = nil
			end
		end
	end


	if filterRaritiesCount > 0 then
		for k, v in pairs(invfilter) do
			if not filterRarities[rarities_invert[cdb[k].type or "null"]] then
				invfilter[k] = nil
			end
		end
	end

	local numkey = tablelength(invfilter)



	local seasonnum = ""
	local raritytext = ""
	local multipleSeasons = filterSeasonsCount > 1
	local multipleRarities = filterRaritiesCount > 1

	for season, _ in pairs(filterSeasons) do
		if #seasonnum > 0 then seasonnum = seasonnum .. ", " end
		seasonnum = seasonnum .. tostring(season)
	end

	for rarity_short, _ in pairs(filterRarities) do
		if #raritytext > 0 then raritytext = raritytext .. ", " end
		raritytext = raritytext .. rarities[rarity_short]
	end

	local embedtitle = lang.embed_title
	if filterSeasonsCount > 0 then
		local filtertitle = ""
		if multipleSeasons then
			if lang.needs_plural_s then
				filtertitle = lang.plural_s .. " " .. seasonnum
			else
				filtertitle = " " .. seasonnum
			end
		else
			filtertitle = " " .. seasonnum
		end
		embedtitle = embedtitle .. formatstring(lang.season, { filtertitle })
	end

	if filterRaritiesCount > 0 then
		embedtitle = embedtitle .. formatstring(lang.rarity, { raritytext })
	end

	local contentstring = (uj.id == author.id and lang.embed_your or "<@" .. uj.id .. ">" .. lang.embed_s) ..
		lang.embed_contains
	local prevstorestring = ''
	local sorted_inv = {}
	for k, v in pairs(invfilter) do
		sorted_inv[#sorted_inv + 1] = { k, v }
	end
	table.sort(sorted_inv, sort_types[sort_type])
	for _, v in ipairs(sorted_inv) do
		table.insert(storetable,
			format_card_line(v, enableSeason, lang, placeholder)
		)
	end
	for i = 1, numkey do
		storestring = storestring .. storetable[i]
		if #storestring > 4096 then
			author:send {
				content = contentstring,
				embed = {
					color = uj.embedc,
					title = embedtitle,
					description = prevstorestring
				},
			}
			storestring = storetable[i]
			contentstring = ''
			embedtitle = embedtitle .. lang.embed_cont
		end
		prevstorestring = storestring
	end
	author:send {
		content = contentstring,
		embed = {
			color = uj.embedc,
			title = embedtitle,
			description = storestring
		},
	}
	message:reply("-# Sent!")
end

return command
