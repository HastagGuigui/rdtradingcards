local item = {}

function item.run(uj, message, mt, interaction)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/cons.json")
	if #mt ~= 1 or message.attachment then
		uj.consumables["ddd"] = uj.consumables["ddd"] - 1
		if uj.consumables["ddd"] == 0 then uj.consumables["ddd"] = nil end
		uj.timesitemused = uj.timesitemused and uj.timesitemused + 1 or 1

		local item1 = texttofn(table.concat(mt, "/", 2):gsub("[<>]", ""))

		if interaction then interaction:updateDeferred() end
		if not item1 then
			message:reply(formatstring(lang.ddd_no_item, { mt[2] }))
			return
		end

		if not uj.storage[item1] then
			message:reply(formatstring(lang.ddd_dont_have, { cdb[item1].name }))
			return
		end

		print("success!!!!!")
		local numcards = 1
		uj.storage[item1] = uj.storage[item1] - numcards
		if uj.storage[item1] == 0 then uj.storage[item1] = nil end
		uj.inventory[item1] = uj.inventory[item1] and uj.inventory[item1] + numcards or numcards

		if uj.equipped == 'aceofhearts' then
			if uj.acepulls ~= 0 then
				message:reply('The pulls stored in your **Ace of Hearts** disappear...')
				uj.acepulls = 0
			end
		end

		message:reply(formatstring(lang.ddd_use, { uj.id, cdb[item1].name, uj.pronouns["their"] }))
		cmd.checkcollectors.run(message, mt)
		cmd.checkmedals.run(message, mt)
	else
		local replying = interaction or message
		replying:reply(lang.ddd_unused)
	end
end

return item
