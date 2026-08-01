local command = {
    name = "fullinventory",
    description = "Sends your entire inventory in DMs.",
    options = {
        {
            name = "show-season",
            type = 5, -- BOOLEAN
            description = "Shows seasons on cards. (Default: false)",
            required = false
        },
        {
            name = "unstored-only",
            type = 5, -- BOOLEAN
            description = "Shows only cards that aren't present in storage. (Default: false)",
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
        }
    }
}
function command.run(message, mt)
    local author = message.author ~= nil and message.author or message.user
    print(author.name .. " did !fullinventory")
  if message.replyDeferred then
    message:replyDeferred(true)
  end
  local uj = db.get_user(author.id)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/fullinventory.json", "")
  local placeholder = dpf.loadjson("langs/" .. uj.lang .. "/look/missingcard.json", "")

  local enableShortNames = true
  local enableSeason = false

  local filterUnstored = false

  local filterSeasons = {}
  local filterSeasonsCount = 0
  local filterRarities = {}
  local filterRaritiesCount = 0

  local args = {}
  if mt[1] then
    for substring in mt[1]:gmatch("%S+") do
      table.insert(args, substring)
    end
    elseif not next(mt) == nil then
        if mt["show-season"] ~= nil then enableSeason = mt["show-season"] end
        if mt["unstored-only"] ~= nil then filterUnstored = mt["unstored-only"] end
        if mt["season-filter"] ~= nil then
            for substring in mt["season-filter"]:gmatch('([^,]+)') do
                table.insert(args, "-season"..substring)
            end
        end
        if mt["rarity-filter"] ~= nil then
            for substring in mt["rarity-filter"]:gmatch('([^,]+)') do
                table.insert(args, "-rarity"..substring)
            end
        end
    end

  for index, value in ipairs(args) do
    if value == "-s" then
      enableShortNames = true
--      print("-s enabled")
    elseif string.find(value, "-season") then
      if value == "-season" then
        enableSeason = true
  	  	print("-season enabled")
		  else
		  	local num = string.gsub(value, "-season", "") -- fuck you gsub
		  	local season = math.abs(tonumber(num))
		    if season and season <= 11 then
		      filterSeasons[season] = true
		      filterSeasonsCount = filterSeasonsCount+1
  	  	  print("filtering for season "..season)
		    end
		  end
		elseif string.find(value, "-rarity") then
		  local rarity = string.gsub(value, "-rarity", "")
		  if rarities[rarity] then
  		  filterRarities[rarity] = true
		    filterRaritiesCount = filterRaritiesCount+1
  	  	print("filtering for rarity "..rarity)
  		end
    elseif value == "-unstored" then
      filterUnstored = true
		else
			if value[0] ~= '-' and (tonumber(value) > 11 or not tonumber(value)) then
				local filename = usernametojson(value)
				uj = db.get_user(author.id)
			end
		end
  end

  local invtable = {}
  local invstring = ''
  local invfilter = uj.inventory

  if filterSeasonsCount > 0 then
    for k,v in pairs(invfilter) do
	    if not filterSeasons[cdb[k] and cdb[k].season or -1] then
	      invfilter[k] = nil
	    end
	  end
  end


	if filterRaritiesCount > 0 then
		for k,v in pairs(invfilter) do
		  if not filterRarities[cdb[k] and cdb[k].type and rarities_invert[cdb[k].type] or "null"] then
				invfilter[k] = nil
			end
		end
	end

	if filterUnstored then
	  for k,v in pairs(invfilter) do
	    if uj.storage[k] and uj.storage[k] > 0 then
	      invfilter[k] = nil
	    end
	  end
	end

  local numkey = tablelength(invfilter)



  local seasonnum = ""
	local raritytext = ""
  local multipleSeasons = filterSeasonsCount > 1
	local multipleRarities = filterRaritiesCount > 1

  for season,_ in pairs(filterSeasons) do
    if #seasonnum > 0 then seasonnum = seasonnum..", " end
    seasonnum = seasonnum .. tostring(season)
  end

  for rarity_short,_ in pairs(filterRarities) do
    if #raritytext > 0 then raritytext = raritytext..", " end
    raritytext = raritytext .. rarities[rarity_short]
  end

  local embedtitle = lang.embed_title
  if filterSeason then
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

	embedtitle = formatstring(lang.embed_title_season, {filtertitle})
  end

	if filterRarity then embedtitle = embedtitle .. formatstring(lang.rarity, {raritytext}) end
	if filterUnstored then embedtitle = embedtitle .. " (unstored)" end

  local contentstring = (uj.id == author.id and lang.embed_your or formatstring(lang.embed_s, {"<@" .. uj.id .. ">"})) .. lang.embed_contains
  local previnvstring = ''
	for k,v in pairs(invfilter) do
		table.insert(invtable,
			"**" .. (cdb[k] and cdb[k].name or placeholder.card) .. "** x" .. v ..
			(enableShortNames and (" `"..k.."` ") or "") ..
			(enableSeason and formatstring(lang.season, {cdb[k] and cdb[k].season or -1}) or "")
			.."\n"
		)
	end
  table.sort(invtable)
  for i = 1, numkey do
    invstring = invstring .. invtable[i]
    if #invstring > 4096 then
      author:send{
        content = contentstring,
        embed = {
          color = uj.embedc,
          title = embedtitle,
          description = previnvstring
        },
      }
      invstring = invtable[i]
      contentstring = ''
      embedtitle = embedtitle .. lang.embed_cont
    end
    previnvstring = invstring
  end
  message:addReaction("✅")
  message.author:send{
    content = contentstring,
    embed = {
      color = uj.embedc,
      title = embedtitle,
      description = previnvstring
    },
  }
end
return command
