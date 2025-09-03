local command = {}
function command.run(message, mt)
  print(message.author.name .. " did !language")
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json", defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/lang.json", "")
  
  if not uj.lang then
    uj.lang = "en"
  end
  
  local request = string.lower(mt[1])
  local change_successful = false
  if request == "english" or request == "en" or request == "eng" or request == "영어" or request == "anglais" then
    change_successful = true
    uj.lang = "en"
  elseif request == "한국어" or request == "korean" or request == "ko" or request == "kr" or request == "kor" or request =="coréen" then
    change_successful = true
    uj.lang = "ko"
  
    -- @wolfplay uncomment this when you're ready to unleash hell upon this world
  -- elseif uj.hasengwish and (request == "engwish" or request == "owo") then
  --   change_successful = true
  --   uj.lang = "owo"

  -- elseif request == "français" or request == "french" or request == "fr" or request == "fra" then -- NOT YET!!
  --   change_successful = true
  --   uj.lang = "fr"
  elseif request == "" then
    local langname = "English"
    if uj.lang == "ko" then
      langname = "한국어"
    end
    -- if uj.lang == "fr" then
    --   langname = "Français"
    -- end
    message.channel:send(formatstring(lang.no_value, {langname}))
  else
    message.channel:send(formatstring(lang.no_database, {mt[1]}))
  end
  if change_successful then
    local lang = dpf.loadjson("langs/" .. uj.lang .. "/lang.json", "")
    local lang_p = dpf.loadjson("langs/" .. uj.lang .. "/pronoun.json", "")
    -- i love huge optimizations
    uj.pronouns["they"] = lang_p[uj.pronouns["selection"].."_they"]
    uj.pronouns["them"] = lang_p[uj.pronouns["selection"].."_them"]
    uj.pronouns["their"] = lang_p[uj.pronouns["selection"].."_their"]
    uj.pronouns["theirs"] = lang_p[uj.pronouns["selection"].."_theirs"]
    uj.pronouns["theirself"] = lang_p[uj.pronouns["selection"].."_theirself"]
    message.channel:send(lang.lang_changed)
  end

  dpf.savejson("savedata/" .. message.author.id .. ".json", uj)
end
return command