local item = {}

function item.run(uj, message, mt, interaction)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/cons.json")
	local replying = interaction or message
	if uj.conspt == "none" then
		uj.consumables["subwayticket"] = uj.consumables["subwayticket"] - 1
		if uj.consumables["subwayticket"] == 0 then uj.consumables["subwayticket"] = nil end
		uj.timesitemused = uj.timesitemused and uj.timesitemused + 1 or 1

		uj.conspt = "sbubby"
		local msg = replying:reply(lang.subwayticket_message)
		local randtime = config.cooldowns.pull * (math.random(12, 24) / 11.5)
		uj.lastpull = uj.lastpull - randtime
		msg:update(lang.subwayticket_message .. "\n" .. formatstring(lang.cooldown_decrease, { randtime }, lang.plural_s))
	else
		replying:reply(lang.subwayticket_conspt)
	end
end

return item
