local command = {}
function command.run(message, mt)
    if message.addReaction then
      print(message.author.name .. " did !beans")
      message:addReaction(client:getEmoji("340218056934686732"))
    else
      message:reply(client:getEmoji("340218056934686732"))
    end
end
return command
