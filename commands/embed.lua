local command = {}

local colororder = {"default", "red", "orange", "yellow", "green", "blue", "purple", "pink", "brown"}
local embedcolors = { -- easy to add more: just put a new line!
  default =  {colorcode = 0x85c5ff, shortname = "default", fullname = "RDCards Blue"},
  red =      {colorcode = 0xff0000, shortname = "red", fullname = "Stylish Red"},
  orange =   {colorcode = 0xff8000, shortname = "orange", fullname = "Pretty Orange"},
  yellow =   {colorcode = 0xfcd68d, shortname = "yellow", fullname = "Light Yellow"},
  green =    {colorcode = 0x00ff88, shortname = "green", fullname = "Jade Green"},
  blue =     {colorcode = 0x33ccff, shortname = "blue", fullname = "Nice Blue"},
  purple =   {colorcode = 0x7c00bf, shortname = "purple", fullname = "Fun Purple"},
  pink =     {colorcode = 0xff00dc, shortname = "pink", fullname = "Hot Pink"},
  brown =    {colorcode = 0x481b1d, shortname = "brown", fullname = "Beans Brown"},
}

function command.run(message, mt)
  print(message.author.name .. " did !embed")
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json", defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/embed.json", "")
  
  if not uj.embedc then
  uj.embedc = 0x85c5ff
  end
  
  if mt[1] == "" then
  mt[1] = "list"
  end

  local colorDescText = ""

  -- sincerely apologizing for optimising your code
  for _, k in ipairs(colororder) do
    local v = embedcolors[k]
    colorDescText = colorDescText.."**"..lang[k.."2"].."** ("..lang[k]..")\n" -- for the description

    if mt[1] == v.shortname or mt[1] == v.fullname or mt[1] == lang[k] or mt[1] == lang[k.."2"] then
      uj.embedc = v.colorcode
      message.channel:send("Successfully changed color to **"..v.fullname.."**!")
    end
  end
  if string.sub(mt[1],1,1) == "#" then
    local new_value = tonumber(string.sub(mt[1],2,7), 16)
    if new_value and #mt[1] == 7 then
      uj.embedc = new_value
      message.channel:send("Successfully changed color to RGB color **#"..string.sub(mt[1],2,7).."**!")
    else
      message.channel:send("Invalid RGB color: **#"..string.sub(mt[1],2,7).."**")
    end
  end

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

