local command = {
  name = "givetoken",
  description = "Give tokens to another player!",
  options = {
    {
      name = "user",
      description = "User to give the tokens to",
      type = 6,       -- USER
      required = true
    },
    {
      name = "amount",
      description = "Amount of tokens to give out",
      type = 4,       -- INT
      min_value = 1
    }
  }
}
function command.run(message, mt)
  local author = message.author ~= nil and message.author or message.user
  print(author.name .. " did !givetoken")
  local uj = db.get_user(author.id)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/givetoken.json", "")
  if not message.guild then
    message:reply(lang.dm_message)
    return
  end

    if not (#mt == 1 or #mt == 2) then
        message:reply(lang.no_arguments)
        return
    end

    local uj2f = ""
  local numtokens = 1
  if mt[1] then
    uj2f = usernametoid(mt[1])
    if not uj2f then
      message:reply(formatstring(lang.no_user, {mt[1]}))
      return
    end

    if tonumber(mt[2]) then
      if tonumber(mt[2]) > 1 then numtokens = math.floor(tonumber(mt[2])) end
    end
  elseif mt.user then
    uj2f = mt.user.id
    if mt.amount then
      numtokens = mt.amount
    end
  end


  local uj2 = db.get_user(uj2f)

  if not uj2.lang then
    uj2.lang = "en"
  end

  local lang2 = dpf.loadjson("langs/" .. uj2.lang .. "/givetoken.json")
  if uj2.id == uj.id then
    message:reply(lang.same_user)
    return
  end


  if not uj.tokens then uj.tokens = 0 end

  if mt[2] == "all" then
    numtokens = uj.tokens
  end

  if uj.tokens < numtokens then
    message:reply(lang.not_enough)
    return
  end

  uj.tokens = uj.tokens - numtokens
  if not uj2.tokens then uj2.tokens = 0 end
  uj2.tokens = uj2.tokens + numtokens

  uj.timestokengiven = uj.timestokengiven and uj.timestokengiven + numtokens or numtokens
  uj2.timestokenreceived = uj2.timestokenreceived and uj2.timestokenreceived + numtokens or numtokens
  db.save_user(uj2f)


  _G['giftedmessage'] = formatstring(lang.gifted_message, { numtokens, uj2.id }, lang.plural_s)
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
  _G['recievedmessage'] = formatstring(lang2.recieved_message, {uj.id, numtokens}, lang2.plural_s)
  if samelang ~= true then
    if not uj2.togglechecktoken then
      _G['recievedmessage'] = recievedmessage .. "\n" .. formatstring(lang2.checktoken2r, {uj2.tokens}, lang2.plural_s)
    end
  end

  if samelang == true then
    message:reply { content = giftedmessage }
  else
    message:reply { content = giftedmessage .. "\n" .. recievedmessage }
  end
end

return command
