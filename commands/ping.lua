local command = {
  name = "ping",
  description = "Ping the bot just to check if it's alive."
}
function command.run(message, mt)
  local author = message.author and message.author or message.user
  local uj = db.get_user(author.id)
  if uj.lang == "ko" then
    local pingmessage = { "퐁!", "뿅!", "뿡!", "팡!", "팝!", "삐용!", "삐슝!", "빠슝!", "파닥!" }
    local cping = math.random(1, #pingmessage)
    message:reply(pingmessage[cping])
  else
    message:reply(trf('ping')) -- ???
  end
  print(author.name .. " did !ping")
end

return command
