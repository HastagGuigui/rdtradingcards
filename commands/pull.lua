local command = {}
function command.run(message, mt)
local time = sw:getTime()
  print(message.author.name .. " did !pull")
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json",defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/pull.json", "")
  
  if not message.guild then
    message.channel:send(lang.dm_message)
    return
  end

  local cooldown = 11.5

  if not uj.equipped then
    uj.equipped = "nothing"
  end

  if uj.equipped == "stoppedwatch" then
    cooldown = 10
  end

  if not uj.storedpulls then
    uj.storedpulls = 0
  end
  
  if not uj.acepulls then
	uj.acepulls = 0
  end

  local maxcryopodstorage = 3
  
  
  if uj.equipped == "sparecryopod" then
    local missedpulls = math.floor((time:toHours() - math.max(uj.lastpull, uj.lastequip))/cooldown)-1
    if missedpulls > 0 then
      local resultmessage = formatstring(lang.cryopod_miss, {missedpulls})
      if uj.storedpulls == maxcryopodstorage then
        resultmessage = resultmessage..formatstring(lang.cryopod_full, {maxcryopodstorage}) -- full!
      elseif missedpulls + uj.storedpulls > maxcryopodstorage then
        resultmessage = resultmessage..formatstring(lang.cryopod_filled, {
          (math.min(uj.storedpulls + missedpulls, maxcryopodstorage)-uj.storedpulls) -- formula for extra pulls
        })
      else
        resultmessage = resultmessage..formatstring(lang.cryopod_partly, {missedpulls, uj.storedpulls+missedpulls})
      end
      message.channel:send(resultmessage)
      uj.storedpulls = math.min(uj.storedpulls + missedpulls, maxcryopodstorage)
    end
  elseif uj.storedpulls > 0 then
    uj.storedpulls = 0
  end

  if uj.lastpull + cooldown > time:toHours() then
    if uj.storedpulls > 0 then -- use a pull stored in the freezer (the spare cryopod)
      uj.storedpulls = uj.storedpulls - 1
      message.channel:send(formatstring(lang.cryopod_pull, {uj.storedpulls}, "s"))
    else
      local minutesleft = math.ceil(uj.lastpull * 60 - time:toMinutes() + cooldown * 60)
      local durationtext = formattime(minutesleft, uj.lang)

      message.channel:send(formatstring(lang.wait_message, {durationtext}))
      return
    end
  end
  
  if not uj.names then
    uj.names = {}
    uj.names[message.author.name .. "#" .. message.author.discriminator] = true
  end
  uj.id = message.author.id
  uj.lastpull = time:toHours()
  print(inspect(uj.names) .. " is/are the nickname/s")
  
  if uj.sodapt and uj.sodapt.pull then
    uj.lastpull = uj.lastpull + uj.sodapt.pull
    uj.sodapt.pull = nil
    if uj.sodapt == {} then uj.sodapt = nil end
  end
  
  dpf.savejson("savedata/" .. message.author.id .. ".json", uj)

  message.channel:send(lang.pulling_card)

  uj = dpf.loadjson("savedata/" .. message.author.id .. ".json",defaultjson)

  local pulledcards = {}
  if uj.disablecommunity then
    pulledcards = {ptablenc[uj.equipped][math.random(#ptablenc[uj.equipped])]}
  else
    pulledcards = {ptable[uj.equipped][math.random(#ptable[uj.equipped])]}
  end
  
  if not uj.conspt then
    uj.conspt = "none"
  end
  if uj.conspt == "none" then
    if uj.equipped == "fixedmouse" and math.random(6) == 1 then
	
      if uj.disablecommunity then
        table.insert(pulledcards, ptablenc[uj.equipped][math.random(#ptablenc[uj.equipped])])
      else
        table.insert(pulledcards, ptable[uj.equipped][math.random(#ptable[uj.equipped])])
      end
      uj.timesdoubleclicked = uj.timesdoubleclicked and uj.timesdoubleclicked + 1 or 1
    end
  else
    if uj.conspt == "sbubby" then
      pulledcards = { "sandwich" }
    elseif uj.conspt:sub(1, 6) == "season" then
      pulledcards = {}
      table.insert(pulledcards, constable[uj.conspt][math.random(#constable[uj.conspt])])
      table.insert(pulledcards, constable[uj.conspt][math.random(#constable[uj.conspt])])
      table.insert(pulledcards, constable[uj.conspt][math.random(#constable[uj.conspt])])
    else
      pulledcards = { constable[uj.conspt][math.random(#constable[uj.conspt])] }
    end
    if uj.conspt == "quantummouse" then
	    if uj.disablecommunity then
        table.insert(pulledcards, constablenc["quantummouse"][math.random(#constablenc["quantummouse"])])
	    else
	      table.insert(pulledcards, constable["quantummouse"][math.random(#constable["quantummouse"])])
	    end
	  
      if uj.equipped == "fixedmouse" and math.random(6) == 1 then
        if uj.disablecommunity then
			    table.insert(pulledcards, constablenc["quantummouse"][math.random(#constablenc["quantummouse"])])
		    else
			    table.insert(pulledcards, constable["quantummouse"][math.random(#constable["quantummouse"])])
		    end
        uj.timesdoubleclicked = uj.timesdoubleclicked and uj.timesdoubleclicked + 1 or 1
      end
    end
    uj.conspt = "none"
  end
	if forcepull ~= nil then
		pulledcards = { forcepull }
		forcepull = nil
	end
  for i, v in ipairs(pulledcards) do
    uj.inventory[v] = uj.inventory[v] and uj.inventory[v] + 1 or 1
    uj.timespulled = uj.timespulled and uj.timespulled + 1 or 1
	if uj.equipped == 'aceofhearts' then
		uj.acepulls = uj.acepulls + 1
	else
		uj.acepulls = 0
	end
  end
  
  local showacemessage = false
  
  if uj.acepulls >= 21 and uj.equipped == 'aceofhearts' then
	uj.acepulls = 0
	uj.tokens = uj.tokens + 10 or 10
	showacemessage = true
  end

  dpf.savejson("savedata/" .. message.author.id .. ".json",uj)

	if doinfodeskpull then
		pulledcards = {'rdcards'}
	end

  for i, v in ipairs(pulledcards) do
    local cardname = cdb[v].name

    local title = lang.pulled_woah
    if uj.equipped == "okamiiscollar" then title = lang.pulled_woof end
    if v == "yor" or v == "yosr" or v == "your" then title = lang.pulled_yo end
    if i == 2 then title = lang.pulled_doubleclick end
    if i == 3 then title = lang.pulled_tripleclick end
    if v == "samarrrai" then title = "Ahoy Matey!" end

    if v == "rdnot" then
      message.channel:send("```" .. title .. "\n@" .. formatstring(lang.rdnot_message, {message.author.name, uj.pronouns["their"]}) .. [[
_________________
| SR            |
|               |
|    \____/     |
|    / TT \  /  |
|   /|____|\/   |
|     l  l      |
|             𝅘𝅥𝅯 |
_________________```]])
    elseif not cdb[v].spoiler then
      local msg = formatstring(lang.pulled_message, {message.author.mentionString, cardname, uj.pronouns["their"], v})
      message.channel:send{embed = {
        color = uj.embedc,
        title = title,
        description = msg,
        image = {url = type(cdb[v].embed) == "table" and cdb[v].embed[math.random(#cdb[v].embed)] or cdb[v].embed}
      }}
    else
      print("spider moments")
      local msg = formatstring(lang.pulled_message, {message.author.mentionString, cardname, uj.pronouns["their"], v})
        message.channel:send{
          content = "**" .. title .. "**\n" .. msg,
          file = "card_images/SPOILER_" .. v .. ".png"
        }
    end
    if not uj.togglecheckcard then
      if not uj.storage[v] then
        message.channel:send(formatstring(lang.not_in_storage, {cardname}))
      end
    end
  end
  if showacemessage then
    message.channel:send(formatstring(lang.ace_of_hearts, {uj.pronouns['their'], uj.pronouns['they']}))
  end
end
return command
