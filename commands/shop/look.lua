local command = {}
function command.run(message, mt, uj, wj)
    local lang = dpf.loadjson("langs/" .. uj.lang .. "/look/shop.json")
    local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
    if uj.lastrob + 4 > sj.stocknum and uj.lastrob ~= 0 then
      lang = dpf.loadjson("langs/" .. uj.lang .. "/rob.json")
      local time = sw:getTime()
      local stocksleft = uj.lastrob + 4 - sj.stocknum
      local stockstring = lang.more_restock_1 .. stocksleft .. lang.more_restock_2
      if lang.needs_plural_s == true then
        if stocksleft > 1 then
          stockstring = stockstring .. lang.plural_s
        end
      end
      local minutesleft = math.ceil((26/24 - time:toDays() + sj.lastrefresh) * 24 * 60)
      
      local durationtext = formattime(minutesleft, uj.lang)
      if uj.lastrob + 3 == sj.stocknum then
        message.channel:send(formatstring(lang.blacklist_next, {durationtext}))
      else
        message.channel:send(formatstring(lang.blacklist, {stockstring, durationtext}))
      end
      return
    end
    local args = {}
    for substring in mt[1]:gmatch("%S+") do
      table.insert(args, substring)
    end
      
    if args[1] == nil or args[1] == "-s" or args[1] == "-season" then
	  _G["request"] = ""
    else
	  _G["request"] = string.lower(args[1]) --why tf didint i do this for all the other ones?????????????????
    end
    
    if (request == "shop" or request == "quaintshop" or request == "quaint shop" or request == "" or (uj.lang ~= "en" and request == lang.request_shop_1 or request == lang.request_shop_2 or mt[1] == lang.request_shop_3 or mt[1] == lang.request_shop_4))  then
      local time = sw:getTime()
      checkforreload(time:toDays())
      local showShortHandForm = false
      local showSeasons = false

      if args[#args] == "-s" then
        showShortHandForm = true
        table.remove(args, #args)
      elseif args[#args] == "-season" then
        showSeasons = true
        table.remove(args, #args)
      end

      local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
      local shopstr = ""
      for i,v in ipairs(sj.cards) do
        if uj.lang == "ko" then
        _G['tokentext'] = lang.shop_token_1 .. v.price .. lang.shop_token_2
        else
        _G['tokentext'] = v.price .. lang.shop_token_1 .. (v.price ~= 1 and lang.needs_plural_s == true and lang.plural_s or "")
        end
        shopstr = shopstr .. "\n**"..cdb[v.name].name.."** (".. tokentext .. ") x"..v.stock
        if showShortHandForm == true then
          shopstr = shopstr .. " | ("..v.name..")"
        end
        if showSeasons == true then
          shopstr = shopstr .. " | (Season "..cdb[v.name].season..")"
        end
      end
      for i,v in ipairs(sj.consumables) do
        if uj.lang == "ko" then
        _G['tokentext'] = lang.shop_token_1 .. v.price .. lang.shop_token_2
        else
        _G['tokentext'] = v.price .. lang.shop_token_1 .. (v.price ~= 1 and lang.needs_plural_s == true and lang.plural_s or "")
        end
        if showShortHandForm == true then
          shopstr = shopstr .. "\n**"..consdb[v.name].name.."** (".. tokentext .. ") x"..v.stock .. " | ("..v.name..")"
        else
          shopstr = shopstr .. "\n**"..consdb[v.name].name.."** (".. tokentext .. ") x"..v.stock
        end
      end

      if showShortHandForm == true then
        if uj.lang == "ko" then
        _G['tokentext'] = lang.shop_token_1 .. sj.itemprice .. lang.shop_token_2
        else
        _G['tokentext'] = sj.itemprice .. lang.shop_token_1 .. (sj.itemprice ~= 1 and lang.needs_plural_s == true and lang.plural_s or "")
        end
        shopstr = shopstr .. "\n**"..itemdb[sj.item].name.."** (" .. tokentext ..") x"..sj.itemstock.." | ("..sj.item..")"
      else
        if uj.lang == "ko" then
        _G['tokentext'] = lang.shop_token_1 .. sj.itemprice .. lang.shop_token_2
        else
        _G['tokentext'] = sj.itemprice .. lang.shop_token_1 .. (sj.itemprice ~= 1 and lang.needs_plural_s == true and lang.plural_s or "")
        end
        shopstr = shopstr .. "\n**"..itemdb[sj.item].name.."** (" .. tokentext ..") x"..sj.itemstock
      end

      message.channel:send{embed = {
        color = uj.embedc,
        title = lang.looking_at_shop,
        description = lang.looking_shop,
        fields = {{
          name = lang.shop_selling,
          value = shopstr,
          inline = true
        }},
        image = {url = "attachment://shop.png"}},
        files = {getshopimage()}}
      if not uj.togglechecktoken then
        message.channel:send(lang.checktoken_1 .. uj.tokens .. lang.checktoken_2 .. (uj.tokens ~= 1 and lang.needs_plural_s == true and lang.plural_s or "") .. lang.checktoken_3)
      end
      
    elseif (request == "wolf" or (uj.lang ~= "en" and request == lang.request_wolf))  then
      local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
      local time = sw:getTime()
      checkforreload(time:toDays())
      --extremely jank implementation, please make this cleaner if possible
      local minutesleft = math.ceil((26/24 - time:toDays() + sj.lastrefresh) * 24 * 60)
      local durationtext = formattime(minutesleft, uj.lang)
      message.channel:send{embed = {
        color = uj.embedc,
        title = lang.looking_at_wolf,
        description = lang.looking_wolf_1 .. durationtext .. lang.looking_wolf_2,
      }}
      
    elseif (request == "ghost" or (uj.lang ~= "en" and request == lang.request_ghost))  then 
      message.channel:send{embed = {
        color = uj.embedc,
        title = lang.looking_at_ghost,
        description = lang.looking_ghost,
      }}
      
    elseif (request == "photo" or request == "framed photo" or (uj.lang ~= "en" and request == lang.request_photo)) then
      local randomimages = {
        "https://cdn.discordapp.com/attachments/829197797789532181/880110700989673472/okamii_triangle_frame.png",
        "https://cdn.discordapp.com/attachments/829197797789532181/880302232338333747/okamii_triangle_frame_2.png",
        "https://cdn.discordapp.com/attachments/829197797789532181/880302252278034442/okamii_triangle_frame_3.png"
      }
      local imageindex = (uj.equipped == "okamiiscollar" and math.random(#randomimages) or 1)
      message.channel:send{embed = {
        color = uj.embedc,
        title = lang.looking_at_photo,
        description = lang.looking_photo .. (imageindex ~= 1 and lang.looking_photo_ookami or ""),
        image = {url = randomimages[imageindex]}
      }}
      
    else
      return false
    end
    return true
end
return command