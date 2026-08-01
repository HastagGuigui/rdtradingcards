local command = {
  name = "pray",
  description = "Pray to the card gods. Gives one token."
}
function command.run(message, mt)
  local time = sw:getTime()
  local author = message.author and message.author or message.user
  print(author.name .. " did !pray")
  local uj = db.get_user(author.id)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/pray.json", "")

  if not message.guild then
    message:reply(lang.dm_message)
    return
  end

  local cooldown = config.cooldowns.pray
  if uj.equipped == "faithfulnecklace" then
    cooldown = config.cooldowns.pray_necklace
  end

  if not uj.lastprayer then
    uj.lastprayer = -30
  end

  if uj.lastprayer + cooldown > time:toHours() then
    --extremely jank implementation, please make this cleaner if possible
    local minutesleft = math.ceil(uj.lastprayer * 60 - time:toMinutes() + cooldown * 60)
    local durationtext = formattime(minutesleft, uj.lang)
    message:reply(formatstring(lang.wait_message, { durationtext }))
    return
  end

  uj.tokens = uj.tokens and uj.tokens + 1 or 1
  uj.timesprayed = uj.timesprayed and uj.timesprayed + 1 or 1
  uj.lastprayer = time:toHours()

  if uj.sodapt then
    if uj.sodapt.pray then
      uj.lastprayer = uj.lastprayer + uj.sodapt.pray
      uj.sodapt.pray = nil
      if uj.sodapt == {} then
        uj.sodapt = nil
      end
    end
  end

  local show_tutorial_message = true
  if uj.has_seen_tutorials.pray then
    show_tutorial_message = false
  else
    uj.has_seen_tutorials["pray"] = true
  end

  message:reply(lang.prayed_message)
  if not uj.togglechecktoken then
    message:reply(formatstring(lang.checktoken, { uj.tokens }, lang.time_plural_s))
  end
  if show_tutorial_message then
    message:reply(formatstring(lang.tutorial, { prefix }))
  end
end

return command
