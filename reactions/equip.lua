local reaction = {}
function reaction.run(message, interaction, data, response)
  local newequip = data.newequip
  local ujf = "savedata/" .. message.author.id .. ".json"
  local uj = dpf.loadjson(ujf, defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/equip.json", "")
  local time = sw:getTime()
  print("Loaded uj")

  if response == "yes" then
    print('user1 has accepted')
    if uj.lastequip + 6 > time:toHours() then
      interaction:reply(lang.reaction_not_cooldown)
      return
    end
	
	if uj.equipped == 'aceofhearts' then
		if uj.acepulls ~= 0 then
			message.channel:send('The pulls stored in your **Ace of Hearts** disappear...')
			uj.acepulls = 0
		end
	end
	
    uj.equipped = newequip
    message.channel:send(formatstring(lang.equipped, {"<@" .. uj.id .. "> ", itemdb[newequip].name, uj.pronouns["their"]}))
    
	uj.lastequip = time:toHours()

    if uj.sodapt and uj.sodapt.equip then
      uj.lastequip = uj.lastequip + uj.sodapt.equip
      uj.sodapt.equip = nil
      if uj.sodapt == {} then uj.sodapt = nil end
    end
    
    dpf.savejson(ujf, uj)
  end

  if response == "no" then
    print('user1 has denied')
    interaction:reply(formatstring(lang.stopped, {"<@" .. uj.id .. "> ", uj.pronouns["their"]}))
  end
end
return reaction
