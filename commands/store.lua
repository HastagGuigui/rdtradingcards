local command = {}
function command.run(message, mt)
  print(message.author.name .. " did !store")
  local ujf = ("savedata/" .. message.author.id .. ".json")
  local uj = dpf.loadjson(ujf, defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/store.json", "")
  if not (#mt == 1 or #mt == 2) then
    message.channel:send(lang.no_arguments)
    return
  end

  print(string.sub(message.content, 0, 8))
  
  local item1 = texttofn(mt[1])
  if not item1 then
    if nopeeking then
      message.channel:send(formatstring(lang.no_item_nopeeking, {mt[1]}))
    else
      message.channel:send(formatstring(lang.no_item, {mt[1]}))
    end
    return
  end

  if not uj.inventory[item1] then
    if nopeeking then
      message.channel:send(formatstring(lang.no_item_nopeeking, {mt[1]}))
    else
      message.channel:send(formatstring(lang.dont_have, {cdb[item1].name}))
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
    message.channel:send(formatstring(lang.not_enough, {cdb[item1].name}))
      return
  end

  if not uj.skipprompts then
    ynbuttons(message,formatstring(lang.confirm_message, {uj.id, numcards, cdb[item1].name}, lang.plural_s), "store", {numcards = numcards, item1 = item1}, uj.id, uj.lang)
  else
    uj.inventory[item1] = uj.inventory[item1] - numcards
    if uj.inventory[item1] == 0 then uj.inventory[item1] = nil end

    uj.storage[item1] = uj.storage[item1] and uj.storage[item1] + numcards or numcards
    uj.timesstored = uj.timesstored and uj.timesstored + numcards or numcards
	
    message.channel:send(formatstring(lang.stored_message, {uj.id, uj.pronouns["their"], numcards, cdb[item1].name}, lang.plural_s))

    dpf.savejson(ujf, uj)
    cmd.checkcollectors.run(message, mt)
    cmd.checkmedals.run(message, mt)
  end
end
return command