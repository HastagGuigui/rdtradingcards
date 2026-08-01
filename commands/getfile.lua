local command = {}
function command.run(message, mt)
  print(message.author.name .. " did !getfile")
  local cmember = message.guild:getMember(message.author)
  if not cmember:hasRole(privatestuff.modroleid) then
    message:reply("haha no, nice try")
    return
  end

  message:reply({
    file = table.concat(mt, "/")
  })
end
return command
