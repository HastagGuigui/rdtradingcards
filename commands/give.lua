local command = {
  name = "give",
  description = "Give a card to another player!",
  options = {
    {
      name = "user",
      description = "User to give the card to",
      type = 6, -- USER
      required = true
    },
    {
      name = "card",
      description = "The card to give",
      type = 3, -- STRING
      required = true
    },
    {
      name = "amount",
      description = "Amount of copies of this card to give out",
      type = 4, -- INT
      min_value = 1
    }
  }
}
function command.run(message, mt)
  local author = message.author ~= nil and message.author or message.user
  print(author.name .. " did !give")
  local uj = db.get_user(author.id)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/give.json", "")

  if not message.guild then
    message:reply(lang.dm_message)
    return
  end

  if not (#mt == 2 or #mt == 3) or not (mt.user ~= nil and mt.card ~= nil) then
    message:reply(lang.no_arguments)
    return
  end

  local user_argument = nil
  local thing_argument = nil
  local numcards = 1
  if mt[1] then
    user_argument = usernametoid(mt[1])
    thing_argument = string.lower(mt[2])
    if tonumber(mt[3]) then
      if tonumber(mt[3]) > 1 then
        numcards = math.floor(mt[3])
      end
    elseif mt[3] == "all" then
      numcards = uj.inventory[thing_argument]
    end
  elseif mt.user then
    user_argument = mt.user.id
    thing_argument = string.lower(mt.card)
    numcards = mt.amount or numcards
  end


  if thing_argument == "token" then
    cmd.givetoken.run(message, { user_argument, numcards })
    return
  end

  if constexttofn(thing_argument) or itemtexttofn(thing_argument) then
    cmd.giveitem.run(message, { user_argument, thing_argument, numcards })
    return
  end

  if not user_argument then
    message:reply(formatstring(lang.no_user, { user_argument }))
    return
  end

  local uj2 = db.get_user(user_argument)

  if not uj2.lang then
    uj2.lang = "en"
  end

  local lang2 = dpf.loadjson("langs/" .. uj2.lang .. "/give.json", "")

  if uj2.id == author.id then
    message:reply(lang.same_user)
    return
  end

  local curfilename = texttofn(thing_argument)

  if not curfilename then
    if nopeeking then
      message:reply(formatstring(lang.no_item_nopeeking, { thing_argument }))
    else
      message:reply(formatstring(lang.no_item, { thing_argument }))
    end
    return
  end

  if not uj.inventory[curfilename] then
    print("user doesnt have card")
    if nopeeking then
      message:reply(formatstring(lang.no_item_nopeeking, { thing_argument }))
    else
      message:reply(formatstring(lang.dont_have, { cdb[curfilename].name }))
    end
    return
  end

  if not (uj.inventory[curfilename] >= numcards) then
    print("user doesn't have enough cards")
    message.reply(formatstring(lang.not_enough, { cdb[curfilename].name }))
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

  print("user had card, removed from original user")

  uj2.inventory[curfilename] = (uj2.inventory[curfilename] == nil) and numcards or
      (uj2.inventory[curfilename] + numcards)

  db.save_user(user_argument)
  db.uncache_user(user_argument)
  print("saved user2 json with new card")

  _G['giftedmessage'] = formatstring(lang.gifted_message, { numcards, cdb[curfilename].name, uj2.id }, lang.plural_s)

  _G['recievedmessage'] = formatstring(lang2.recieved_message, { uj.id, numcards, cdb[curfilename].name }, lang2
    .plural_s)
  if uj.lang == uj2.lang then
    message:reply {
      content = giftedmessage
    }
  else
    message:reply {
      content = giftedmessage .. "\n" .. recievedmessage
    }
  end
end

return command
