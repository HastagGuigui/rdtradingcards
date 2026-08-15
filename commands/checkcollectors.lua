local command = {}
function command.run(message, mt, mc)
    local author = message._author
  if not mc then
    mc = message.channel
  end
  print("checking collector's drops for ".. author.name)
  local uj = db.get_user(author.id)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/checkcollectors.json", "")
  for i,v in ipairs(coll) do
    print("checking for " .. v.receive)
    if not uj.storage[v.receive] then
      print("user does not have " .. v.receive)
      local allcards = true
      for w,x in ipairs(v.require) do
        if not uj.storage[x] then
          allcards = false
        end
      end
      if allcards then
        local newcard = v.receive
        if uj.storage[newcard] == nil then
          uj.storage[newcard] = 1
        else
          uj.storage[newcard] = uj.storage[newcard] + 1
        end
        local ncn = cdb[newcard].name
        if not cdb[newcard].spoiler then
          mc:send{embed = {
            color = uj.embedc,
            title = lang.congratulations,
            description = formatstring(lang.gotcard, {author.mentionString, ncn, uj.pronouns["their"]}),
            image = {
              url = cdb[newcard].embed
            }
          }}
        else
          mc:send{
            content = "**" .. lang.congratulations .. "**\n" .. formatstring(lang.gotcard, {author.mentionString, ncn, uj.pronouns["their"]}),
            file = "card_images/SPOILER_" .. newcard .. ".png"
          }
        end
      else
        print("no card for you lol")
      end
    else
      print("user already has " .. v.receive)
    end
  end
end
return command
