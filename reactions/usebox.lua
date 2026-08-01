local reaction = {}
function reaction.run(message, interaction, data, response)
  local function send(text)
    if interaction then interaction:reply(text) else message:reply(text) end
  end
  local ujf = "savedata/" .. message.author.id .. ".json"
  local uj = dpf.loadjson(ujf, defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/lab/box.json", "")
  local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)
  local time = sw:getTime()
  print("Loaded uj")

  if response == "yes" then
    print('user1 has accepted')
    local cooldown = (uj.equipped == "stainedgloves") and config.cooldowns.box_gloves or config.cooldowns.box
    if uj.lastbox + cooldown > time:toHours() then
      send(lang.reaction_not_cooldown)
      return
    end

    if not next(uj.inventory) then
      send(lang.reaction_no_card)
      return
    end

    local iptable = {}
    for k, v in pairs(uj.inventory) do
      for i = 1, v do
        table.insert(iptable, k)
      end
    end

    local givecard = iptable[math.random(#iptable)]
    local boxpoolindex = math.random(#wj.boxpool)
    local getcard = wj.boxpool[boxpoolindex]
    print("user giving " .. givecard.." and getting ".. getcard)

    uj.inventory[getcard] = uj.inventory[getcard] and uj.inventory[getcard] + 1 or 1
    uj.inventory[givecard] = uj.inventory[givecard] - 1
    if uj.inventory[givecard] == 0 then uj.inventory[givecard] = nil end

    wj.boxpool[boxpoolindex] = givecard

    print(interaction)
    send(formatstring(lang.boxed_message, {uj.id, cdb[givecard].name, uj.pronouns["their"], cdb[getcard].name, getcard}))

	if not uj.togglecheckcard then
            if not uj.storage[getcard] then
                message:reply(formatstring(lang.not_in_storage, {cdb[getcard].name}))
            end
        end
    uj.timesusedbox = uj.timesusedbox and uj.timesusedbox + 1 or 1
    uj.lastbox = time:toHours()

    if uj.sodapt then
      if uj.sodapt.box then
        uj.lastbox = uj.lastbox + uj.sodapt.box
        uj.sodapt.box = nil
        if uj.sodapt == {} then
          uj.sodapt = nil
        end
      end
    end
    dpf.savejson(ujf,uj)
    dpf.savejson("savedata/worldsave.json", wj)
  end

  if response == "no" then
    print('user1 has denied')
    send(lang.reaction_stopped)
  end
end
return reaction
