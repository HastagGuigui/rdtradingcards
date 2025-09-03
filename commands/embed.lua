local command = {}

local colororder = {"default", "red", "orange", "yellow", "green", "blue", "purple", "pink", "brown"}

function command.run(message, mt)
  print(message.author.name .. " did !embed")
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json", defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/embed.json", "")

  if mt[1] == "" then
  mt[1] = "list"
  end

  local colorDescText = ""

  -- sincerely apologizing for optimising your code
  for _, k in ipairs(colororder) do
    local v = embed_colors[k]
    if uj.unlocked_colors[v.shortname] then
      colorDescText = colorDescText.."**"..lang[k.."2"].."** ("..lang[k]..")\n" -- for the description

      if (mt[1] == v.shortname or mt[1] == v.fullname or mt[1] == lang[k] or mt[1] == lang[k.."2"]) then
        uj.embedc = v.colorcode
        message.channel:send{embed = {
          color = uj.embedc,
          description = "Successfully changed color to **"..lang[k].."**!",
        }}
      end
    end
  end
  -- if string.sub(mt[1],1,1) == "#" then
  --   local new_value = tonumber(string.sub(mt[1],2,7), 16)
  --   if new_value and #mt[1] == 7 then
  --     uj.embedc = new_value
  --     message.channel:send("Successfully changed color to RGB color **#"..string.sub(mt[1],2,7).."**!")
  --   else
  --     message.channel:send("Invalid RGB color: **#"..string.sub(mt[1],2,7).."**")
  --   end
  -- end

  if mt[1] == "list" then
    message.channel:send{embed = {
          color = uj.embedc,
          title = lang.allcolors,
          description = colorDescText,
    }}
  end
  dpf.savejson("savedata/" .. message.author.id .. ".json",uj)
end
return command

