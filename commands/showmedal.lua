local command = {}
function command.run(message, mt)
  print(message.author.name .. " did !showmedal")
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json", defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/showmedal.json", "")
  if #mt ~= 1 then
    message.channel:send(lang.no_arguments)
    return
  end

  local curfilename = medaltexttofn(mt[1])

  if not curfilename then
    if nopeeking then
      message.channel:send(formatstring(lang.error_nopeeking, {mt[1]}))
    else
      message.channel:send(formatstring(lang.no_medal, {mt[1]}))
    end
    return
  end

  if not uj.medals[curfilename] then
    print("user doesnt have medal")
    if nopeeking then
      message.channel:send(formatstring(lang.error_nopeeking, {mt[1]}))
    else
      message.channel:send(formatstring(lang.dont_have_1, {medaldb[curfilename].name}))
    end
    return
  end

  print("user has medal")
  message.channel:send{embed = {
    color = uj.embedc,
    title = lang.showing_medal,
    description = formatstring(lang.show_medal_1, {medaldb[curfilename].name, curfilename, medaldb[curfilename].description}),
    image = {
      url = medaldb[curfilename].embed
    }
  }}
end
return command
