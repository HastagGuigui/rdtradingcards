
local command = {
  name = "help",
  description = "Displays the bot's guide."
}
function command.run(message, mt)
  local author = message.author and message.author or message.user
  local uj = db.get_user(author.id)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/help.json", "")
  print(author.name .. " did !help")
  message:reply(lang.help_message)
end
return command
