local command = {
	name = "store",
	description = "Transfer a card from your inventory into your storage.",
	options = {
		{
			name = "card",
			description = "The card to store",
			required = true,
			type = 3,
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
function command.run(message, mt)
	local author = message.author or message.user
	print(author.name .. " did !store")
	local uj = db.get_user(author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/store.json", "")
	if not (#mt == 1 or #mt == 2) and not mt.card then
		message:reply(formatstring(lang.no_arguments, { prefix }))
		return
	end

	print(string.sub(message.content, 0, 8))

	local card_name = mt[1] or mt.card

	local item1 = texttofn(card_name)
	if not item1 then
		if nopeeking then
			message:reply(formatstring(lang.no_item_nopeeking, { card_name }))
		else
			message:reply(formatstring(lang.no_item, { card_name }))
		end
		return
	end

	if not uj.inventory[item1] then
		if nopeeking then
			message:reply(formatstring(lang.no_item_nopeeking, { card_name }))
		else
			message:reply(formatstring(lang.dont_have, { cdb[item1].name }))
		end
		return
	end

	print("success!!!!!")
	local numcards = 1
	if tonumber(mt[2]) then
		if tonumber(mt[2]) > 1 then
			numcards = math.floor(mt[2])
		end
	end

	if mt[2] == "all" then
		numcards = uj.inventory[item1]
	end
	if mt.amount then
		numcards = math.floor(mt.amount)
	end

	if uj.inventory[item1] < numcards then
		message:reply(formatstring(lang.not_enough, { cdb[item1].name }))
		return
	end

	if not uj.skipprompts then
		ynbuttons(message, formatstring(lang.confirm_message, { uj.id, numcards, cdb[item1].name }, lang.plural_s),
			"store", { numcards = numcards, item1 = item1 }, uj.id, uj.lang)
	else
		cmdre.store.run(message, nil, { numcards = numcards, item1 = item1 }, "yes")
	end
end

return command
