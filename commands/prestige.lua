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

	ynbuttons(message, author.mentionString .. lang.prestige_confirm, "prestige", {}, uj.id, uj.lang)
end

return command
