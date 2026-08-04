local command = {}
function command.run(message)
  local author = message.author or message.user
  print(author.name .. " did !langlist")
  local uj = db.get_user(author)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/lang.json", "")

  message:reply(lang.langlist_message)
end
return command
