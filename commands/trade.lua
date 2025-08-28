local command = {}
function command.run(message, mt)
  print(message.author.name .. " did !trade")
  local ujf = ("savedata/" .. message.author.id .. ".json")
  local uj = dpf.loadjson(ujf, defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/trade.json", "")
  if not message.guild then
    message.channel:send(lang.dm_message)
    return
  end

  if #mt ~= 3 then
    message.channel:send(lang.no_arguments)
    return
  end

  local uj2f = usernametojson(mt[2])

  print("checking if user 2 exists")
  if not uj2f then
    message.channel:send(formatstring(lang.no_user, {mt[2]}))
    return
  end

  print("checking if users are different people")
  if uj2f == ujf then
    message.channel:send(lang.same_user)
    return
  end

  print("checking if item 1 exists")
  local item1 = texttofn(mt[1])
  if not item1 then
    if nopeeking then
      message.channel:send(formatstring(lang.no_item_nopeeking, {mt[1]}) .. lang.no_item1_nopeeking)
    else
      message.channel:send(formatstring(lang.no_item, {mt[1]}))
    end
    return
  end

  print("checking if item 2 exists")
  local item2 = texttofn(mt[3])
  if not item2 then
    if nopeeking then
      message.channel:send(formatstring(lang.no_item_nopeeking, {mt[1]}) .. formatstring(lang.no_item1_nopeeking, {mt[2]}))
    else
      message.channel:send(formatstring(lang.no_item, {mt[1]}))
    end
    return
  end

  local uj2 = dpf.loadjson(uj2f, defaultjson)
  
  if not uj2.lang then
	uj2.lang = "en"
  end
  
  local lang2 = dpf.loadjson("langs/" .. uj2.lang .. "/trade.json", "")
  
  print("checking if u1 has i1")
  if not uj.inventory[item1] then
    if nopeeking then
      message.channel:send(formatstring(lang.no_item_nopeeking, {mt[1]}) .. lang.no_item1_nopeeking)
    else
      message.channel:send(formatstring(lang.dont_have_user1, {cdb[item1].name}))
    end
    return
  end

  print("checking if u2 has i2")
  if not uj2.inventory[item2] then
    if nopeeking then
      message.channel:send(formatstring(lang.no_item_nopeeking, {mt[1]}) .. formatstring(lang.no_item1_nopeeking, {mt[2]}))
    else
      message.channel:send(formatstring(lang.dont_have_user2, {mt[2], cdb[item2].name, prosel.getPronoun(uj.lang, uj2.pronouns["selection"], "their")}))
	end
    return
  end

  print("success!!!!!")
  ynbuttons(message, formatstring(lang2.confirm_message, {
    uj2.id, uj.id, prosel.getPronoun(uj2.lang, uj.pronouns["selection"], "their"), cdb[item1].name, cdb[item2].name}),
    "trade", {uj2f = uj2f, item1 = item1,item2 = item2}, uj2.id, uj2.lang)
end
return command
