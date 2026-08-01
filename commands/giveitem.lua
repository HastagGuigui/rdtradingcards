local command = {
  name = "giveitem",
  description = "Give a consumable to another player!",
  options = {
    {
      name = "user",
      description = "User to give the consumable to",
      type = 6,       -- USER
      required = true
    },
    {
      name = "item",
      description = "The item to give",
      type = 3,       -- STRING
      required = true
    },
    {
      name = "amount",
      description = "Amount of copies of this item to give out",
      type = 4,       -- INT
      min_value = 1
    }
  },
}
function command.run(message, mt)
  local author = message.author ~= nil and message.author or message.user
  print(author.name .. " did !giveitem")
  local uj = db.get_user(author.id)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/giveitem.json", "")

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

  local uj2f = usernametojson(user_argument)

  if not uj.consumables then uj.consumables = {} end

  if mt[3] == "all" then
    numitems = uj.consumables[thing_argument]
  end

  if not user_argument then
    message:reply(formatstring(lang.no_user, {user_argument}))
    return
  end

  local uj2 = db.get_user(user_argument)

  if not uj2.lang then
    uj2.lang = "en"
  end

  local lang2 = dpf.loadjson("langs/" .. uj2.lang .. "/giveitem.json", "")

  if not uj2.consumables then uj2.consumables = {} end

  if uj2.id == message.author.id then
    message:reply(lang.same_user)
    return
  end

  local curfilename = constexttofn(thing_argument)

  if not curfilename then
    if itemtexttofn(thing_argument) then
      message:reply(lang.equippable_item)
    elseif nopeeking then
      message:reply(formatstring(lang.no_item_nopeeking, {thing_argument}))
    else
      message:reply(formatstring(lang.no_item, {thing_argument}))
    end
    return
  end

  if not uj.consumables[curfilename] then
    print("user doesnt have item")
    if nopeeking then
      message:reply(formatstring(lang.no_item_nopeeking, {thing_argument}))
    else
      message:reply(formatstring(lang.dont_have, {consdb[curfilename].name}))
    end
    return
  end

  if not (uj.consumables[curfilename] >= numitems) then
    print("user doesn't have enough items")
    message:reply(formatstring(lang.not_enough, {consdb[curfilename].name}))
    return
  end


  print(uj.consumables[curfilename] .. "before")
  uj.consumables[curfilename] = uj.consumables[curfilename] - numitems
  print(uj.consumables[curfilename] .. "after")

  if uj.consumables[curfilename] == 0 then
    uj.consumables[curfilename] = nil
  end

  uj.timesitemgiven = (uj.timesitemgiven == nil) and numitems or (uj.timesitemgiven + numitems)
  uj2.timesitemreceived = (uj2.timesitemreceived == nil) and numitems or (uj2.timesitemreceived + numitems)


  uj2.consumables[curfilename] = (uj2.consumables[curfilename] == nil) and numitems or (uj2.consumables[curfilename] + numitems)

    db.save_user(user_argument)
  db.uncache_user(user_argument)
  print("saved user2 json with new item")

  _G['giftedmessage'] = formatstring(lang.gifted_message, {numitems, cdb[curfilename].name, uj2.id}, lang.plural_s)
  _G['recievedmessage'] = formatstring(lang2.recieved_message, {uj.id, numitems, cdb[curfilename].name}, lang.plural_s)
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
