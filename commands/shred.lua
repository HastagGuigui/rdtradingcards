local command = {
	name = "shred",
	description = "Shred a card in your inventory, removing it.",
	options = {
		{
			name = "card",
			description = "The card that you want gone",
			type = 3,
			required = true,
			autocomplete = true
        },
		{
			name = "amount",
			description = "Number of cards to store",
			type = 4,
			min_value = 1
		}
	}
}
function command.autocomplete(ia, comm, focused, args)
	local out = {}
	local uj = db.get_user(ia.user.id)
	for k, _ in pairs(uj.inventory) do
		local name = cdb[k] and cdb[k].name or "UNKNOWN CARD"
		if (string.find(name, args.card) or string.find(k, args.card)) and #out < 25 then
			out[#out + 1] = { name = string.format("%s [%s]", name, k), value = k }
		end
	end
	ia:autocomplete(out)
end
function command.run(message, mt)
	local author = message.author or message.user
	print(author.name .. " did !shred")
	local uj = db.get_user(author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/shred.json", "")
	if not (#mt == 1 or #mt == 2) and not mt.card then
		message:reply(lang.no_arguments)
		return
	end

	local curfilename = texttofn(mt[1])

	if not curfilename then
		if nopeeking then
			message:reply(formatstring(lang.error_nopeeking, { mt[1] }))
		else
			message:reply(formatstring(lang.no_item, { mt[1] }))
		end
		return
	end

	if not uj.inventory[curfilename] then
		if nopeeking then
			message:reply(formatstring(lang.error_nopeeking, { cdb[curfilename].name }))
		else
			message:reply(formatstring(lang.dont_have, { cdb[curfilename].name }))
		end
		return
	end

	local numcards = 1
	if tonumber(mt[2]) then
		if tonumber(mt[2]) > 1 then numcards = math.floor(mt[2]) end
	end
    if mt[2] == "all" then
        numcards = uj.inventory[curfilename]
    end
	if mt.amount then
		numcards = math.floor(mt.amount)
	end

	if uj.inventory[curfilename] >= numcards then
		ynbuttons(message, formatstring(lang.shred_confirm, { uj.id, numcards, cdb[curfilename].name }, lang.plural_s),
			"shred", { curfilename = curfilename, numcards = numcards }, uj.id, uj.lang)
	else
		message:reply(formatstring(lang.not_enough, {cdb[curfilename].name}))
	end
end

return command
