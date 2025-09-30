local command = {}
function command.run(message, mt,bypass)
  print(message.author.name .. " did !use")
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json",defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/nonroom.json","")
  local request = string.lower(mt[1])

  if not (message.guild or bypass or constexttofn(request)) then
    message.channel:send(lang.dm_message)
    return
  end
  local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)
  if not uj.room then uj.room = 0 end
  
  if request == "shop" and uj.room == 2 then
  else
	  local newuj = automove(uj.room,request,message)
    if newuj then
      if newuj == "blacklisted" then
        return
      else
		    uj = newuj
      end
	  end
  end
  
  local found = true

  ----------------------------------------------------------PYROWMID
  if uj.room == 0 or bypass then
    found = cmd.pyrowmid_use.run(message, mt)
  end
  
  ----------------------------------------------------------LAB
  if (uj.room == 1 or bypass) and wj.labdiscovered then
    found = cmd.lab_use.run(message,mt)
  end
  
  ----------------------------------------------------------WINDY MOUNTAINS
  if uj.room == 2 then
    found = cmd.mountains_use.run(message,mt)
  end
  
  ----------------------------------------------------------SHOP
  if (uj.room == 3) then 
    found = cmd.shop_use.run(message,mt)
  end
  
  if found then return end
    
  if (not found) and (not bypass) then ----------------------------------NON-ROOM ITEMS GO HERE!-------------------------------------------------
    local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/nonroom.json","")
    if request == "token" or (uj.lang ~= "en" and request == lang.request_token) then
      if uj.tokens > 0 then
        message.channel:send(formatstring(lang.tokenflip, {math.random(2) == 1 and lang.token_heads or lang.token_tails}))
      else
        message.channel:send(lang.no_tokens)
      end
      uj.timesused = uj.timesused and uj.timesused + 1 or 1
    
    elseif constexttofn(request) then
      print("using consumable")
      if not uj.consumables then 
        uj.consumables = {}
      end
      request = constexttofn(request)
      if uj.consumables[request] then
		if not consdb[request].unusable then
			if not uj.skipprompts then
			  ynbuttons(message,{
				color = uj.embedc,
				title = formatstring(lang.using, {consdb[request].name}),
				description = formatstring(lang.use_confirm, {consdb[request].name}),
			  },"useconsumable",{crequest=request,mt=mt},uj.id,uj.lang)
			  return
			else
      if request == "..." then request = "ddd" end
        if request ~= "ddd" then
          if uj.equipped == 'aceofhearts' then
            if uj.acepulls ~= 0 then
                message.channel:send('The pulls stored in your **Ace of Hearts** disappear...')
                uj.acepulls = 0
            end    
        end
      end
			  local fn = request
			  if consdb[request].command then
				request = consdb[request].command
			  end
			  cmdcons[request].run(uj, "savedata/" .. message.author.id .. ".json", message, mt, nil , fn)
			  return
			end
		else
			message.channel:send('You cannot use this item!')
		end
      else
        message.channel:send(formatstring(lang.donthave, {consdb[request].name}))
      end
      
    else
      message.channel:send(formatstring(lang.unknown, {mt[1]}))
    end
  end
  dpf.savejson("savedata/worldsave.json", wj)
  dpf.savejson("savedata/" .. message.author.id .. ".json",uj)
end
return command
