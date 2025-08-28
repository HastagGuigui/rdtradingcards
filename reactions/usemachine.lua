local reaction = {}
function reaction.run(message, interaction, data, response)
  local ujf = "savedata/" .. message.author.id .. ".json"
  local uj = dpf.loadjson(ujf, defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/pyrowmid/machine.json","")
  print("Loaded uj")

  if response == "yes" then
    print('user1 has accepted')

    if uj.tokens < 3 then
      interaction:reply(lang.error_no_tokens)
      return
    end

    local itempt = {}
    for k in pairs(itemdb) do
      if uj.items["fixedmouse"] then
        if not uj.items[k] and k ~= "brokenmouse" then table.insert(itempt, k) end
      else
        if not uj.items[k] and k ~= "fixedmouse" then table.insert(itempt, k) end
      end
    end
    print(inspect(itempt))

    if #itempt == 0 then
      interaction:reply(lang.error_allitems)
      return
    end

    local newitem = itempt[math.random(#itempt)]
    uj.items[newitem] = true
    uj.tokens = uj.tokens - 3
    local dep = lang.dep
    local cdep = math.random(1, #dep)
    local speen = lang.speen
    local cspeen = math.random(1, #speen)
    local action = lang.action
    local caction = math.random(1, #action)
    local truaction = formatstring(action[caction], {speen[cspeen]})
    local size = lang.size
    local csize = math.random(1, #size)
    local action2 = lang.action2
    local caction2 = math.random(1, #action2)
    message.channel:send(formatstring(lang.used_machine, {dep[cdep], truaction, size[csize], action[caction2], itemdb[newitem].name, speen[cspeen]}))
    dpf.savejson(ujf,uj)
  end

  if response == "no" then
    print('user1 has denied')
    interaction:reply(lang.denied_message)
  end
end
return reaction
