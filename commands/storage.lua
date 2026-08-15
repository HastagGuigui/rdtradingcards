local command = {
	name = "storage",
	description = "View cards in your storage. Cards in here are safe and unaffected by everything else.",
	options = {
		{
			name = "page",
			type = 4, -- INTEGER
			description = "Page Number (Every page shows 10 cards)",
			required = false,
			min_value = 0,
		},
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
				{ name = "count",     value = "count" }
			}
		}
	}
}

function command.run(message, mt)
	local author = message._author
    print(author.name .. " did !storage")
	local uj = db.get_user(author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/storage.json", "")
	local placeholder = dpf.loadjson("langs/" .. uj.lang .. "/look/missingcard.json", "")

	local enableShortNames = true
	local enableSeason = false

	local filterSeasons = {}
	local filterSeasonsCount = 0
	local filterRarities = {}
	local filterRaritiesCount = 0

	local pagenumber = 1
	local sort_type = "name"

	local args = {}
	if mt[1] then
		for substring in mt[1]:gmatch("%S+") do
			table.insert(args, substring)
		end
	elseif not next(mt) == nil then
		if mt.page then pagenumber = mt.page end
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
				table.insert(args, "-rarity" .. substring)
			end
		end
		if mt["sorting"] and command.sort[mt.sorting] then
			sort_type = mt.sorting
		end
	end

	for index, value in ipairs(args) do
		if tonumber(value) then
			pagenumber = math.floor(tonumber(value))
		end
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
			if command.sort[sorting_method] then
				sort_type = sorting_method
			end
		else
			local filename = usernametojson(value)
			if filename then
				uj = dpf.loadjson(filename, defaultjson)
			end
		end
	end

	local storagestring = ''
	local invfilter = uj.storage

	if not next(invfilter) then
		message:reply({
			embed = {
				color = uj.embedc,
				title = formatstring(lang.empty_storage_title, {}),
				description = formatstring(lang.empty_storage_desc, { prefix }),
			}
		})
		return
	end

	if filterSeasonsCount > 0 then
		for k, v in pairs(invfilter) do
			if not filterSeasons[cdb[k] and cdb[k].season or -1] then
				invfilter[k] = nil
			end
		end
	end


	if filterRaritiesCount > 0 then
		for k, v in pairs(invfilter) do
			if not filterRarities[cdb[k] and cdb[k].type and rarities_invert[cdb[k].type] or "null"] then
				invfilter[k] = nil
			end
		end
	end


	pagenumber = math.max(1, pagenumber)

	local sorted_inv = {}
	for k, v in pairs(invfilter) do
		sorted_inv[#sorted_inv + 1] = { k, v }
	end

	local numcards = #sorted_inv
	table.sort(sorted_inv, sort_types[sort_type])

	local maxpn = math.ceil(numcards / 10)
	pagenumber = math.min(pagenumber, maxpn)
	print("Page number is " .. pagenumber)

	storagestring = format_inventory_page(sorted_inv, pagenumber, 10, enableSeason, lang, placeholder)

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

	local name = { next(uj.names) }
	local embedtitle = formatstring(lang.embed_title, { uj.id == author.id and author.name or name[1] })
	if filterSeasonsCount > 0 then
		local filtertitle = ""
		if multipleSeasons then
			if lang.needs_plural_s then
				filtertitle = lang.plural_s .. seasonnum
			else
				filtertitle = seasonnum
			end
		else
			filtertitle = seasonnum
		end
		embedtitle = embedtitle .. formatstring(lang.season, { filtertitle })
	end

	if filterRaritiesCount > 0 then
		embedtitle = embedtitle .. formatstring(lang.rarity, { raritytext })
	end


	message:reply {
		content = formatstring(lang.embed_contains, { uj.id == author.id and author.mentionString or name[1] }),
		embed = {
			color = uj.embedc,
			title = embedtitle,
			description = storagestring,
			footer = {
				text = formatstring(lang.embed_page, { pagenumber, maxpn }),
				icon_url = author.avatarURL
			}
		}
	}
end

return command
