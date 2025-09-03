local command = {}
function command.run(message, mt)
  local cmember = message.guild:getMember(message.author)
  if cmember:hasRole(privatestuff.modroleid) then
    local newmessage = nil
    if message.attachment then
      local res, body = http.request("GET", message.attachment.url)
      newmessage = client:getChannel(mt[1]):send{
        content = table.concat(mt, "/", 2),
        file = {message.attachment.filename, body}
      }
    else
      newmessage = client:getChannel(mt[1]):send(table.concat(mt, "/", 2))
    end
    handlemessage(newmessage, table.concat(mt, "/", 2))
  else
    message.channel:send("haha no, nice try")
  end
end
return command
  