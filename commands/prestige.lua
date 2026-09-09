local command = {
	name = "prestige",
	description = "If you have enough cards for it, you can become a card maestro!"
}
function command.run(message)
	local author = message.author or message.user
	print(author.name .. " did !prestige")
	local uj = db.get_user(author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/prestige.json", "")

	cmd.checkcollectors.run(message, nil)
	cmd.checkmedals.run(message, nil)

	if not message.guild then
		message:reply(lang.dm_message) -- You could probably add some flair to these error messages lol
		return
	end

	if not uj.medals["cardmaestro"] then
		local excludedcards = { "rdcards", "key" }
		local missingcount = 0

		for k, v in pairs(cdb) do
			if not table.search(excludedcards, k) and not uj.storage[k] and v.season <= 8 then
				missingcount = missingcount + 1
			end
		end
		message:reply(formatstring(lang.missingcards, { missingcount }))
		return
	end

	ynbuttons(message, author.mentionString .. lang.prestige_confirm, command.reaction, {}, uj.id, uj.lang)
end

function command.reaction(message, interaction, data, response)
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/prestige.json", "")
	print("Loaded uj")

	if response == "yes" then
		print('user1 has accepted')

		for k, v in pairs(uj.storage) do
			if k ~= "rdcards" and cdb[k].season <= 8 then
				uj.storage[k] = uj.storage[k] - 1
				if uj.storage[k] == 0 then uj.storage[k] = nil end
			end
		end

		for k, v in pairs(uj.medals) do
			uj.medals[k] = false
		end

		uj.storage["rdcards"] = uj.storage["rdcards"] and uj.storage["rdcards"] + 1 or 1
		uj.timesprestiged = uj.timesprestiged and uj.timesprestiged + 1 or 1

		db.save_user(message._author.id)

		interaction:updateDeferred()

		cmd.checkcollectors.run(message, nil, message.channel)
		cmd.checkmedals.run(message, nil, message.channel)

		message:reply(lang.prestiged_message)
	end

	if response == "no" then
		print('user1 has denied')
		interaction:reply(lang.denied_message)
	end
end

return command
