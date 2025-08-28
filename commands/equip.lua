local command = {}
function command.run(message, mt)
  local time = sw:getTime()
  local ujf = ("savedata/" .. message.author.id .. ".json")
  local uj = dpf.loadjson(ujf, defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/equip.json", "")
  if #mt == 1 then
    print(message.author.name .. " did !equip")
    print(string.sub(message.content, 0, 8))

    if not uj.equipped then
      uj.equipped = "nothing"
    end
    if not uj.items then
      uj.items = {nothing=true}
      uj.equipped = "nothing"
      
    end
    
    if not uj.lastequip then
      uj.lastequip = -24
    end
    
    dpf.savejson("savedata/" .. message.author.id .. ".json",uj)

    if uj.lastequip + 6 > time:toHours() then
      --extremely jank implementation, please make this cleaner if possible
      local minutesleft = math.ceil(uj.lastequip * 60 - time:toMinutes() + 360.00)
      local durationtext = ""
      if math.floor(minutesleft / 60) > 0 then
        durationtext = math.floor(minutesleft / 60) .. lang.time_hour
        if lang.needs_plural_s == true then
		  if math.floor(minutesleft / 60) ~= 1 then
            durationtext = durationtext .. lang.time_plural_s
          end
		end
      end
      if minutesleft % 60 > 0 then
        if durationtext ~= "" then
          durationtext = durationtext .. lang.time_and
        end
        durationtext = durationtext .. minutesleft % 60 .. lang.time_minute
        if lang.needs_plural_s == true then
		  if minutesleft % 60 ~= 1 then
            durationtext = durationtext .. lang.time_plural_s
          end
		end
      end
      message.channel:send(formatstring(lang.wait_message, {durationtext}))
      return
    end

    local request = mt[1]
    local curfilename = itemtexttofn(request)
    
    if not curfilename then
      if nopeeking then
        message.channel:send(formatstring(lang.nopeeking, {request}))
      else
        message.channel:send(formatstring(lang.nodatabase, {request}))
      end
      return
    end

    if not uj.items[curfilename] then
      if nopeeking then
        message.channel:send(formatstring(lang.nopeeking, {request}))
      else
        message.channel:send(formatstring(lang.donthave, {itemdb[curfilename].name}))
      end
      return
    end

    if uj.equipped == curfilename then
      message.channel:send(formatstring(lang.already_equipped, {itemdb[curfilename].name}))
      return
    end

    --woo hoo
    print(uj.equipped)
    if not uj.skipprompts then
      ynbuttons(message, formatstring(lang.prompt, {itemdb[uj.equipped].name, itemdb[curfilename].name}),"equip",{newequip = curfilename}, uj.id, uj.lang)
    else
		if uj.equipped == 'aceofhearts' then
			if uj.acepulls ~= 0 then
				message.channel:send('The pulls stored in your **Ace of Hearts** disappear...')
				uj.acepulls = 0
			end
		end
      uj.equipped = curfilename
      message.channel:send(formatstring(lang.equipped, {uj.id, itemdb[curfilename].name, uj.pronouns["their"]}))
	  uj.lastequip = time:toHours()
	  
	  if uj.sodapt and uj.sodapt.equip then
        uj.lastequip = uj.lastequip + uj.sodapt.equip
        uj.sodapt.equip = nil
        if uj.sodapt == {} then uj.sodapt = nil end
      end
	  
      dpf.savejson(ujf,uj)
      print('saved equipped as ' .. curfilename)
    end
          
  else
    message.channel:send(lang.no_arguments)
  end
end
return command
  
