local command = {}
function command.run(message, mt)
  print(message.author.name .. " did !store")
  local ujf = ("savedata/" .. message.author.id .. ".json")
  local uj = dpf.loadjson(ujf, defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/store.json", "")
  if not (#mt == 1 or #mt == 2) then
    message:reply(formatstring(lang.no_arguments, {prefix}))
    return
  end

  print(string.sub(message.content, 0, 8))

  local item1 = texttofn(mt[1])
  if not item1 then
    if nopeeking then
      message:reply(formatstring(lang.no_item_nopeeking, {mt[1]}))
    else
      message:reply(formatstring(lang.no_item, {mt[1]}))
    end
    return
  end

  if not uj.inventory[item1] then
    if nopeeking then
      message:reply(formatstring(lang.no_item_nopeeking, {mt[1]}))
    else
      message:reply(formatstring(lang.dont_have, {cdb[item1].name}))
    end
    return
  end

  print("success!!!!!")
  local numcards = 1
  if tonumber(mt[2]) then
    if tonumber(mt[2]) > 1 then
      numcards = math.floor(mt[2])
    end
  end

  if mt[2] == "all" then
    numcards = uj.inventory[item1]
  end

  if uj.inventory[item1] < numcards then
    message:reply(formatstring(lang.not_enough, {cdb[item1].name}))
      return
  end

  if not uj.skipprompts then
    ynbuttons(message,formatstring(lang.confirm_message, {uj.id, numcards, cdb[item1].name}, lang.plural_s), "store", {numcards = numcards, item1 = item1}, uj.id, uj.lang)
  else
    cmdre.store.run(message, nil,{numcards = numcards, item1 = item1}, "yes")
  end
end
return command
