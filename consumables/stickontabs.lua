local item = {}

function item.run(uj, message, mt, interaction)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/cons.json")
	local replying = interaction or message
	if uj.conspt == "none" then
		uj.consumables["stickontabs"] = uj.consumables["stickontabs"] - 1
		if uj.consumables["stickontabs"] == 0 then uj.consumables["stickontabs"] = nil end
		uj.timesitemused = uj.timesitemused and uj.timesitemused + 1 or 1

		uj.conspt = "scribblednotepad"
		local msg = replying:reply(lang.stickontabs_message)
		local randtime = math.random(4, 8)
		uj.lastpull = uj.lastpull - randtime
		msg:update(lang.stickontabs_message ..
		"\n" .. formatstring(lang.cooldown_decrease, { randtime }, lang.plural_s))
	else
		replying:reply(lang.stickontabs_conspt)
	end
end

return item
