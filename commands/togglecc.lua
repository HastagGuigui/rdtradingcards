local command = {}
function command.run(message, mt)
  print(message.author.name .. " did !togglecc")
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json",defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/togglecc.json","")

	uj.disablecommunity = not uj.disablecommunity
	if uj.disablecommunity then
	  message:reply(lang.disabled_message)
	else
	  message:reply(lang.enabled_message)
	end

  dpf.savejson("savedata/" .. message.author.id .. ".json",uj)
end
return command
