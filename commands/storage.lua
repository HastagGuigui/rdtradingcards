local command = {}
function command.run(message, mt)
  print(message.author.name .. " did !storage")
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json",defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/storage.json", "")
  local placeholder = dpf.loadjson("langs/" .. uj.lang .. "/look/missingcard.json", "")

  local enableShortNames = true
  local enableSeason = false

  local filterSeasons = {}
  local filterSeasonsCount = 0
  local filterRarities = {}
  local filterRaritiesCount = 0

  local pagenumber = 1

  args = {}
  for substring in mt[1]:gmatch("%S+") do
    table.insert(args, substring)
  end

  for index, value in ipairs(args) do
    if tonumber(value) then
      pagenumber = math.floor(tonumber(value))
    end
    if value == "-s" then -- wolfplay's suggestion
      enableShortNames = true
--      print("-s enabled")
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
    else
      local filename = usernametojson(value)
      if filename then
        uj = dpf.loadjson(filename, defaultjson)
      end
    end
  end

  local invtable = {}
  local storagestring = ''
  local invfilter = uj.storage

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


  pagenumber = math.max(1, pagenumber)

  local numcards = tablelength(invfilter)

  local maxpn = math.ceil(numcards / 10)
  pagenumber = math.min(pagenumber, maxpn)
  print("Page number is " .. pagenumber)

	for k,v in pairs(invfilter) do
		table.insert(invtable,
			"**" .. (cdb[k] and cdb[k].name or placeholder.card) .. "** x" .. v ..
			(enableShortNames and (" ("..k..") ") or "") ..
			(enableSeason and formatstring(lang.season, {cdb[k] and cdb[k].season or -1}) or "")
			.."\n"
		)
	end
  table.sort(invtable)

  for i = (pagenumber - 1) * 10 + 1, (pagenumber) * 10 do
    print(i)
    if invtable[i] then storagestring = storagestring .. invtable[i] end
  end

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

  local name = {next(uj.names)}
  local embedtitle = formatstring(lang.embed_title, {uj.id == message.author.id and message.author.name or name[1]})
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
    embedtitle = embedtitle .. formatstring(lang.season, {filtertitle})
  end

  if filterRaritiesCount > 0 then
    embedtitle = embedtitle .. formatstring(lang.rarity, {raritytext})
  end


  message:reply{
    content = formatstring(lang.embed_contains, {uj.id == message.author.id and message.author.mentionString or name[1]}),
    embed = {
      color = uj.embedc,
      title = embedtitle,
      description = storagestring,
      footer = {
        text = formatstring(lang.embed_page, {pagenumber, maxpn}),
        icon_url = message.author.avatarURL
      }
    }
  }
end
return command
