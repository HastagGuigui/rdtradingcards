local command = {}
function command.run(message, mt)
  print(message.author.name .. " did !givetoken")
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json", defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/givetoken.json", "")
  if not message.guild then
    message.channel:send(lang.dm_message)
    return
  end

  if not (#mt == 1 or #mt == 2) then
    message.channel:send(lang.no_arguments)
    return
  end

  local uj2f = usernametojson(mt[1])

  if not uj2f then
    message.channel:send(lang.no_user_1 .. mt[1] .. lang.no_user_2)
    return
  end

  local uj2 = dpf.loadjson(uj2f, defaultjson)

  if not uj2.lang then
    uj2.lang = "en"
  end

  local lang2 = dpf.loadjson("langs/" .. uj2.lang .. "/givetoken.json")
  if uj2.id == uj.id then
    message.channel:send(lang.same_user)
    return
  end

  local numtokens = 1
  if tonumber(mt[2]) then
    if tonumber(mt[2]) > 1 then numtokens = math.floor(tonumber(mt[2])) end
  end

  if not uj.tokens then uj.tokens = 0 end

  if mt[2] == "all" then
    numtokens = uj.tokens
  end

  if uj.tokens < numtokens then
    message.channel:send(lang.not_enough)
    return
  end

  uj.tokens = uj.tokens - numtokens
  if not uj2.tokens then uj2.tokens = 0 end
  uj2.tokens = uj2.tokens + numtokens

  uj.timestokengiven = uj.timestokengiven and uj.timestokengiven + numtokens or numtokens
  uj2.timestokenreceived = uj2.timestokenreceived and uj2.timestokenreceived + numtokens or numtokens
  dpf.savejson("savedata/" .. message.author.id .. ".json", uj)
  dpf.savejson(uj2f, uj2)

  local isplural = numtokens ~= 1 and lang.needs_plural_s == true and lang.plural_s or ""
  local isplural2 = numtokens ~= 1 and lang2.needs_plural_s == true and lang2.plural_s or ""


  _G['giftedmessage'] = formatstring(lang.gifted_message, { numtokens, uj2.id }, isplural)
  if uj.lang == uj2.lang then
    if not uj2.togglechecktoken then
      _G['giftedmessage'] = giftedmessage .. "\n" .. formatstring(lang.checktoken2g, { uj2.tokens, uj2.pronouns["their"] }, lang.plural_s)
    end
    _G['samelang'] = true
  else
    _G['samelang'] = false
  end
  if not uj.togglechecktoken then
    _G['giftedmessage'] = giftedmessage ..
        "\n" .. formatstring(lang.checktoken, {uj.tokens}, lang.plural_s)
  end
  _G['recievedmessage'] = formatstring(lang2.recieved_message, {uj.id, numtokens}, isplural2)
  if samelang ~= true then
    if not uj2.togglechecktoken then
      _G['recievedmessage'] = recievedmessage .. "\n" .. formatstring(lang2.checktoken2r, {uj2.tokens}, lang2.plural_s)
    end
  end

  if samelang == true then
    message.channel:send { content = giftedmessage }
  else
    message.channel:send { content = giftedmessage .. "\n" .. recievedmessage }
  end
end

return command