local item = {}

function item.run(uj, message, mt, interaction)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/cons.json")
	local replying = interaction or message
	if uj.conspt == "none" then
		uj.consumables["decaf"] = uj.consumables["decaf"] - 1
		if uj.consumables["decaf"] == 0 then uj.consumables["decaf"] = nil end
		uj.timesitemused = uj.timesitemused and uj.timesitemused + 1 or 1

		uj.conspt = "cafemixtape"
		local msg = replying:reply(lang.decaf_message)
		local randtime = math.random(4, 8)
		uj.lastpull = uj.lastpull - randtime
		msg:update(lang.decaf_message .. "\n" .. formatstring(lang.cooldown_decrease, { randtime }, lang.plural_s))
	else
		replying:reply(lang.decaf_conspt)
	end
end

return item
