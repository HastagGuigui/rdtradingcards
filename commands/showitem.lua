local command = {}
function command.run(message, mt)
  print(message.author.name .. " did !showitem")
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json", defaultjson)
  local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/showitem.json","")
  if #mt ~= 1 then
    message.channel:send(lang.no_arguments)
    return
  end

  if not uj.consumables then uj.consumables = {} end
  local curfilename = itemtexttofn(mt[1]) or constexttofn(mt[1])

  if not curfilename then
    if nopeeking then
      message.channel:send(formatstring(lang.error_nopeeking, {mt[1]}))
    else
      message.channel:send(formatstring(lang.no_item, {mt[1]}))
    end
    return
  end

  local description = itemdb[curfilename] and itemdb[curfilename].description or consdb[curfilename].description
  local name = itemdb[curfilename] and itemdb[curfilename].name or consdb[curfilename].name
  local embedurl = itemdb[curfilename] and itemdb[curfilename].embed or consdb[curfilename].embed

  if not (uj.items[curfilename] or uj.consumables[curfilename] or (shophas(curfilename) and not (uj.lastrob + 3 > sj.stocknum and uj.lastrob ~= 0))) then
    print("user doesnt have item")
    if nopeeking then
      message.channel:send(formatstring(lang.error_nopeeking, {mt[1]}))
    else
      message.channel:send(formatstring(lang.dont_have, {name}))
    end
    return
  end

  print("user has item or consumable")

  message.channel:send{embed = {
    color = uj.embedc,
    title = lang.showing_item,
    description = formatstring(lang.show_item, {name, curfilename, description}),
    image = {
      url = embedurl
    }
  }}
end
return command
