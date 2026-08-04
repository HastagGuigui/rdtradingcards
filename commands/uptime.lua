local command = {
    name = "uptime",
description = "Tells you how long this bot has been up for."
}
function command.run(message, mt)
local author = message.author or message.user
  local uj = db.get_user(author.id)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/uptime.json", "")
  local time = sw:getTime()
  message:reply(formatstring(lang.uptime_message, {math.floor(time:toMinutes())}))
  print(author.name .. " did !uptime")
end
return command
