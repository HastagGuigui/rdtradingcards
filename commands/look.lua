local command = {}
function command.run(message, mt)
  print(message.author.name .. " did !look")
  local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)
  if not wj.ws then
    wj.ws = 508
    dpf.savejson("savedata/worldsave.json", wj)
  end
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json",defaultjson)
  
  if uj.room == nil then
    uj.room = 0
  end
  
  if uj.timeslooked == nil then
    uj.timeslooked = 1
  else
    uj.timeslooked = uj.timeslooked + 1
  end
  
  if not mt[1] then
    mt[1] = ""
  end
  
  if texttofn(mt[1]) or itemtexttofn(mt[1]) or constexttofn(mt[1]) or medaltexttofn(mt[1]) then
    if (nopeeking and (uj.inventory[texttofn(mt[1])] or uj.storage[texttofn(mt[1])] or uj.items[itemtexttofn(mt[1])] or uj.medals[medaltexttofn(mt[1])])) or not nopeeking then
      if texttofn(mt[1]) then
        cmd.show.run(message, mt)
      elseif itemtexttofn(mt[1]) or constexttofn(mt[1]) then
        cmd.showitem.run(message, mt)
      elseif medaltexttofn(mt[1]) then
        cmd.showmedal.run(message, mt)
      end
      return
    end
  end

  local found = true
  if uj.room == 0 then     -- PYROWMID --
    found = cmd.pyrowmid_look.run(message,mt,uj,wj)
  end 
  
  if uj.room == 1 then     -- LAB --
    found = cmd.lab_look.run(message,mt,uj,wj)
  end
  
  if uj.room == 2 then     -- MOUNTAINS --
    found = cmd.mountains_look.run(message,mt,uj,wj)
  end
  
  if uj.room == 3 then     -- SHOP --
    found = cmd.shop_look.run(message,mt,uj,wj)
  end
  
  if not found then ----------------------------------NON-ROOM ITEMS GO HERE!--------------------------------------------------
    local lang = dpf.loadjson("langs/" .. uj.lang .. "/look/nonrooms.json","")
    if string.lower(mt[1]) == "card factory" or string.lower(mt[1]) == "factory" or string.lower(mt[1]) == "cardfactory" or string.lower(mt[1]) == "the card factory" or (uj.lang ~= "en" and mt[1] == lang.request_factory_1 or mt[1] == lang.request_factory_2 or mt[1] == lang.request_factory_3) then --TODO: move these to not found
      message.channel:send {
        content = lang.looking_factory
      }
      
    elseif string.lower(mt[1]) == "token" or (uj.lang ~= "en" and mt[1] == lang.request_token) then
      message.channel:send{embed = {
        color = uj.embedc,
        title = lang.looking_at_token,
        description = lang.looking_token,
        image = {
          url = 'https://cdn.discordapp.com/attachments/829197797789532181/829255830485598258/token.png'
        }
      }}
    
    else
      message.channel:send(lang.not_found_1 .. mt[1] .. lang.not_found_2)
      uj.timeslooked = uj.timeslooked - 1
    end
  end

  dpf.savejson("savedata/" .. message.author.id .. ".json",uj)
end
return command