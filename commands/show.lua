local command = {}
function command.run(message, mt)
  print(message.author.name .. " did !show")
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json",defaultjson)
  local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/show.json","")
  if #mt ~= 1 then
    message:reply(lang.no_arguments)
    return
  end

  local curfilename = texttofn(mt[1])

  if not curfilename then
    if nopeeking then
      message:reply(formatstring(lang.error_nopeeking, {mt[1]}))
    else
      message:reply(formatstring(lang.no_item, {mt[1]}))
    end
    return
  end

  if not ((uj.inventory[curfilename] or uj.storage[curfilename])) and not (shophas(curfilename) and not (uj.lastrob + 3 > sj.stocknum and uj.lastrob ~= 0)) then
    print("user doesnt have card")
    if nopeeking then
      message:reply(formatstring(lang.error_nopeeking, {mt[1]}))
    else
      message:reply(formatstring(lang.dont_have, {cdb[curfilename].name}))
    end
    return
  end

  print("user has card")
  local card_data = cdb[curfilename]
  if not card_data then
    local placeholder = dpf.loadjson("langs/" .. uj.lang .. "/look/missingcard.json", "")
    card_data = {
      name = placeholder.name,
      description = placeholder.description,
      embed = "https://media.discordapp.net/attachments/1030420309947469904/1410325951287394438/guiguidc.png"
    }
  end

  if not card_data.spoiler then
    local embeddescription = ""
    if card_data.description then
      embeddescription = "\n\n*" .. lang.embeddescription .. "*\n> " .. card_data.description
    end
    message:reply{embed = {
      color = uj.embedc,
      title = lang.showing_card,
      description = formatstring(lang.show_card, {card_data.name, curfilename, embeddescription}),
      image = {
        url = type(card_data.embed) == "table" and card_data.embed[math.random(#card_data.embed)] or card_data.embed
      },
      footer = {text = "Season "..card_data.season}
    }}
  else
    print("spiderrrrrrr")
    message:reply{
      content = formatstring(lang.show_card, {card_data.name, curfilename, ""}),
      file = "card_images/SPOILER_" .. curfilename .. ".png"
    }
    if card_data.description then
      message:reply(lang.embeddescription .. "\n> " .. card_data.description .. "\n-# Season " .. card_data.season)
    end
  end
end
return command
