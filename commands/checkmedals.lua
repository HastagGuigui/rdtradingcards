local command = {}
function command.run(message)
  local author = message.author ~= nil and message.author or message.user
  print("checking medals for " .. author.name)

  local uj = db.get_user(author.id)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/checkmedals.json")

  for i, v in ipairs(medalrequires) do
    print("checking " .. v.receive)

    if not v.require(uj) then
      print("user cannot have " .. v.receive)
      uj.medals[v.receive] = false
      goto continue
    end

    print("user can have " .. v.receive)

    if uj.medals[v.receive] then
      print("user already has " .. v.receive)
      goto continue
    end

    print("user does not have it yet!")

    uj.medals[v.receive] = true

    message:reply { embed = {
      color = uj.embedc,
      title = lang.congratulations,
      description = formatstring(lang.gotmedal, {author.mentionString, medaldb[v.receive].name}),
      image = { url = medaldb[v.receive].embed }
    } }

    if v.receive == 'cardmaestro' then
      message:reply(lang.gotmaestro)
    end

    ::continue::
  end

  dpf.savejson(ujf, uj)
end

return command
