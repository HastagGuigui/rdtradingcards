local command = {}
function command.run(message, mt)
  print(message.author.name .. " did !show")
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json",defaultjson)
  local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/show.json","")
  if #mt ~= 1 then
    message.channel:send(lang.no_arguments)
    return
  end

  local curfilename = texttofn(mt[1])

  if not curfilename then
    if nopeeking then
      message.channel:send(formatstring(lang.error_nopeeking, {mt[1]}))
    else
      message.channel:send(formatstring(lang.no_item, {mt[1]}))
    end
    return
  end

  if not ((uj.inventory[curfilename] or uj.storage[curfilename])) and not (shophas(curfilename) and not (uj.lastrob + 3 > sj.stocknum and uj.lastrob ~= 0)) then
    print("user doesnt have card")
    if nopeeking then
      message.channel:send(formatstring(lang.error_nopeeking, {mt[1]}))
    else
      message.channel:send(formatstring(lang.dont_have, {cdb[curfilename].name}))
    end
    return
  end

  print("user has card")
  if not cdb[curfilename].spoiler then
    local embeddescription = ""
    if cdb[curfilename].description then
      embeddescription = "\n\n*" .. lang.embeddescription .. "*\n> " .. cdb[curfilename].description
    end
    message.channel:send{embed = {
      color = uj.embedc,
      title = lang.showing_card,
      description = formatstring(lang.show_card, {cdb[curfilename].name, curfilename, embeddescription}),
      image = {
        url = type(cdb[curfilename].embed) == "table" and cdb[curfilename].embed[math.random(#cdb[curfilename].embed)] or cdb[curfilename].embed
      }
    }}
  else
    print("spiderrrrrrr")
    message.channel:send{
      content = formatstring(lang.show_card, {cdb[curfilename].name, curfilename}),
      file = "card_images/SPOILER_" .. curfilename .. ".png"
    }
    if cdb[curfilename].description then
      message.channel:send(lang.embeddescription .. "\n> " .. cdb[curfilename].description)
    end
  end
end
return command
  