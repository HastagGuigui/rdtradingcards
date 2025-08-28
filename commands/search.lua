local command = {}
function command.run(message, mt)
  print(message.author.name .. " did !search")
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json",defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/search.json","")
  if #mt ~= 1 then
    message.channel:send(lang.no_arguments)
    return
  end

  local request = mt[1]
  local curfilename = texttofn(request)

  if not curfilename then
    if nopeeking then
      message.channel:send(formatstring(lang.error_nopeeking, {request}))
    else
      message.channel:send(formatstring(lang.no_item, {request}))
    end
    return
  end

  local invnum = uj.inventory[curfilename] or 0
  local stornum = uj.storage[curfilename] or 0
  if nopeeking and invnum + stornum == 0 then
    message.channel:send(formatstring(lang.error_nopeeking, {request}))
  else
    message.channel:send(formatstring(lang.search_message, {cdb[curfilename].name, invnum, stornum}))
  end
end
return command
