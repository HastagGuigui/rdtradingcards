local command = {}
function command.run(message, mt)
  print(message.author.name .. " did !give")
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json", defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/give.json", "")
  
  if not message.guild then
    message.channel:send(lang.dm_message)
    return
  end
  
  if not (#mt == 2 or #mt == 3) then
    message.channel:send(lang.no_arguments)
    return
  end
  
  local user_argument = mt[1]
  local thing_argument = string.lower(mt[2])
  local numcards = 1
  
  if tonumber(mt[3]) then
    if tonumber(mt[3]) > 1 then
      numcards = math.floor(mt[3])
    end
  end
  
  if thing_argument == "token" then
    cmd.givetoken.run(message, {user_argument, numcards})
    return
  end

  if constexttofn(thing_argument) or itemtexttofn(thing_argument) then
    cmd.giveitem.run(message, {user_argument, thing_argument, numcards})
    return
  end
    
  local uj2f = usernametojson(user_argument)

  if mt[3] == "all" then
    numcards = uj.inventory[thing_argument]
  end
  
  if not uj2f then
    message.channel:send(formatstring(lang.no_user, {user_argument}))
    return
  end

  local uj2 = dpf.loadjson(uj2f, defaultjson)
  
  if not uj2.lang then
	uj2.lang = "en"
  end
  
  local lang2 = dpf.loadjson("langs/" .. uj2.lang .. "/give.json","")
  
  if uj2.id == message.author.id then
    message.channel:send(lang.same_user)
    return
  end
  
  local curfilename = texttofn(thing_argument)
  
  if not curfilename then
    if nopeeking then
      message.channel:send(formatstring(lang.no_item_nopeeking, {thing_argument}))
    else
      message.channel:send(formatstring(lang.no_item, {thing_argument}))
    end
    return
  end
  
  if not uj.inventory[curfilename] then
    print("user doesnt have card")
    if nopeeking then
      message.channel:send(formatstring(lang.no_item_nopeeking, {thing_argument}))
    else
      message.channel:send(formatstring(lang.dont_have, {cdb[curfilename].name}))
    end
    return
  end
  
  if not (uj.inventory[curfilename] >= numcards) then
    print("user doesn't have enough cards")
    message.channel:send(formatstring( lang.not_enough, { cdb[curfilename].name}) )
    return
  end


  print(uj.inventory[curfilename] .. "before")
  uj.inventory[curfilename] = uj.inventory[curfilename] - numcards
  print(uj.inventory[curfilename] .. "after")
  
  if uj.inventory[curfilename] == 0 then
    uj.inventory[curfilename] = nil
  end
  
  uj.timescardgiven = (uj.timescardgiven == nil) and numcards or (uj.timescardgiven + numcards)
  uj2.timescardreceived = (uj2.timescardreceived == nil) and numcards or (uj2.timescardreceived + numcards)
  
  dpf.savejson("savedata/" .. message.author.id .. ".json",uj)
  print("user had card, removed from original user")
  
  uj2.inventory[curfilename] = (uj2.inventory[curfilename] == nil) and numcards or (uj2.inventory[curfilename] + numcards)
  
  dpf.savejson(uj2f,uj2)
  print("saved user2 json with new card")
  
  local isplural = numcards ~= 1 and lang.needs_plural_s == true and lang.plural_s or ""
  local isplural2 = numcards ~= 1 and lang2.needs_plural_s == true and lang2.plural_s or ""

  _G['giftedmessage'] = formatstring(lang.giftedmessage, {numcards, cdb[curfilename].name, uj2.id}, lang.plural_s)

  _G['recievedmessage'] = formatstring(lang2.recieved_message, {uj.id, numcards, cdb[curfilename].name}, lang2.plural_s)
  if uj.lang == uj2.lang then
    message.channel:send {
      content = giftedmessage
	}
  else
    message.channel:send {
      content = giftedmessage .. "\n" .. recievedmessage
    }
  end


end
return command