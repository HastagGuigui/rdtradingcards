local command = {}
function command.run(message, mt)
  if not isauthoradmin(message) then
    message:reply("haha no, nice try")
    return
  end

  if not mt[1] or not usernametojson(mt[1]) then
    message:reply("Sorry, but I could not find a user named " .. (mt[1] or "[NO NAME]") .. " in the database. Make sure that you have spelled it right, and that they have at least pulled a card to register!")
    return
  end

  local uj = dpf.loadjson(usernametojson(mt[1]), defaultjson)

  local numtokens = 1
  if tonumber(mt[2]) then
    if tonumber(mt[2]) > 1 then numtokens = math.floor(tonumber(mt[2])) end
  end

  uj.tokens = uj.tokens and uj.tokens + numtokens or numtokens
  dpf.savejson(usernametojson(mt[1]), uj)

  message:reply(numtokens .. (numtokens == 1 and " token has" or " tokens have") .. " been given to <@" .. uj.id .. ">.")
end
return command
