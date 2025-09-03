local command = {}
function command.run(message, mt)
  print(message.author.name .. " did !shred")
  local ujf = ("savedata/" .. message.author.id .. ".json")
  local uj = dpf.loadjson(ujf, defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/shred.json", "")
  if not (#mt == 1 or #mt == 2) then
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

  if not uj.inventory[curfilename] then
    if nopeeking then
      message.channel:send(formatstring(lang.error_nopeeking, {cdb[curfilename].name}))
    else
      message.channel:send(formatstring(lang.dont_have, {cdb[curfilename].name}))
    end
    return
  end

  local numcards = 1
  if tonumber(mt[2]) then
    if tonumber(mt[2]) > 1 then numcards = math.floor(mt[2]) end
  end
  if mt[2] == "all" then
    numcards = uj.inventory[curfilename]
  end

  if uj.inventory[curfilename] >= numcards then
    ynbuttons(message, formatstring(lang.shred_confirm, {uj.id, numcards, cdb[curfilename].name}, lang.plural_s), "shred", {curfilename = curfilename,numcards = numcards}, uj.id, uj.lang)
  else
    message.channel:send(lang.not_enough_1 .. cdb[curfilename].name .. lang.not_enough_2)
  end
end
return command
  