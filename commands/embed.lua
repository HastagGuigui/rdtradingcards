local command = {}

local embedcolors = { -- easy to add more: just put a new line!
  default =  {colorcode = 0x85c5ff, shortname = "default", fullname = "RDCards Blue"},
  green =    {colorcode = 0x00ff00, shortname = "green", fullname = "Healion Green"},
  red =      {colorcode = 0xff0000, shortname = "red", fullname = "Stylish Red"},
  blue =     {colorcode = 0x33ccff, shortname = "blue", fullname = "Nice Blue"},
  orange =   {colorcode = 0xff8000, shortname = "orange", fullname = "Pretty Orange"},
  brown =    {colorcode = 0x481b1d, shortname = "brown", fullname = "Beans Brown"},
  yellow =   {colorcode = 0xfcd68d, shortname = "yellow", fullname = "Light Yellow"},
  purple =   {colorcode = 0x7c00bf, shortname = "purple", fullname = "Fun Purple"},
  pink =     {colorcode = 0xff00dc, shortname = "pink", fullname = "Hot Pink"},
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
  for k, v in pairs(embedcolors) do
    colorDescText = colorDescText.."**"..lang[k.."2"].."** ("..lang[k]..")\n" -- for the description

    if mt[1] == v.shortname or mt[1] == v.fullname or mt[1] == lang[k] or mt[1] == lang[k.."2"] then
      uj.embedc = v.colorcode
      message.channel:send("Successfully changed color to **"..v.fullname.."**!")
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

