local item = {}

function item.run(uj, message, mt, interaction)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/cons.json")
	local replying = interaction or message
	if uj.conspt == "none" then
		uj.consumables["spicymintgum"] = uj.consumables["spicymintgum"] - 1
		if uj.consumables["spicymintgum"] == 0 then uj.consumables["spicymintgum"] = nil end
		uj.timesitemused = uj.timesitemused and uj.timesitemused + 1 or 1

		uj.conspt = "swirlymarbles"
		local msg = replying:reply(lang.spicymintgum_message)
		local randtime = math.random(4, 8)
		uj.lastpull = uj.lastpull - randtime
		msg:update(lang.spicymintgum_message ..
		"\n" .. formatstring(lang.cooldown_decrease, { randtime }, lang.plural_s))
	else
		replying:reply(lang.spicymintgum_conspt)
	end
end

return item
