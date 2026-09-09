local item = {}

function item.run(uj, message, mt, interaction)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/cons.json")
	local replying = interaction or message
	if uj.conspt == "none" then
		uj.consumables["oldfiles"] = uj.consumables["oldfiles"] - 1
		if uj.consumables["oldfiles"] == 0 then uj.consumables["oldfiles"] = nil end
		uj.timesitemused = uj.timesitemused and uj.timesitemused + 1 or 1

		uj.conspt = "oldfiles"
		local msg = replying:reply(lang.oldfiles_message)
		local randtime = math.random(4, 8)
		uj.lastpull = uj.lastpull - randtime
		msg:update(lang.oldfiles_message .. "\n" .. formatstring(lang.cooldown_decrease, { randtime }, lang.plural_s))
	else
		replying:reply(lang.oldfiles_conspt)
	end
end

return item
