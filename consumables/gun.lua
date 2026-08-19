local item = {}

function item.run(uj, message, mt, interaction)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/cons.json")
	uj.timesitemused = uj.timesitemused and uj.timesitemused + 1 or 1
	local replying = interaction or message
	if uj.robconspt == "none" or not uj.robconspt then
		uj.consumables["gun"] = uj.consumables["gun"] - 1
		if uj.consumables["gun"] == 0 then uj.consumables["gun"] = nil end
		uj.timesitemused = uj.timesitemused and uj.timesitemused + 1 or 1
		uj.robconspt = "gun"
		replying:reply(lang.gun_message)
	else
		replying:reply(lang.gun_robconspt)
	end
end

return item
