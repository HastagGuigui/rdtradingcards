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
function command.autocomplete(ia, comm, focused, args)
	local out = {}
	local uj = db.get_user(ia.user.id)
	local cardlist = uj.inventory
	for k, _ in pairs(cardlist) do
		local name = cdb[k] and cdb[k].name or "UNKNOWN CARD"
		if (string.find(name, args.card) or string.find(k, args.card)) and #out < 25 then
			out[#out + 1] = { name = string.format("%s [%s]", name, k), value = k }
		end
	end
	ia:autocomplete(out)
end

function command.run(message, mt)
	local author = message.author or message.user
	print(author.name .. " did !store")
	local uj = db.get_user(author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/store.json", "")
	if not (#mt == 1 or #mt == 2) and not mt.card then
		message:reply(formatstring(lang.no_arguments, { prefix }))
		return
	end

	local card_name = mt[1] or mt.card
	local card_amount = mt[2] or mt.amount

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
	if tonumber(card_amount) then
		if tonumber(card_amount) > 1 then
			numcards = math.floor(card_amount)
		end
	end

	if mt[2] == "all" then
		numcards = uj.inventory[item1]
	end

	if uj.inventory[item1] < numcards then
		message:reply(formatstring(lang.not_enough, { cdb[item1].name }))
		return
	end

	if not uj.skipprompts then
		ynbuttons(message, formatstring(lang.confirm_message, { uj.id, numcards, cdb[item1].name }, lang.plural_s),
			command.react, { numcards = numcards, item1 = item1 }, uj.id, uj.lang)
	else
		command.react(message, nil, { numcards = numcards, item1 = item1 }, "yes")
	end
end

function command.react(message, interaction, data, response, base_reply)
	local function send(text)
		if base_reply then
			if base_reply.editReply then
				base_reply:editReply({
					components = { {
						type = 10,
						content = text
					} }
				})
			else
				base_reply:update({
					components = { {
						type = 10,
						content = text
					} }
				})
			end
		else
			message:reply({
				flags = 32768,
				components = { {
					type = 10,
					content = text
				} }
			})
		end
	end
	local item1 = data.item1
	local numcards = data.numcards
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/store.json", "")
	print("Loaded uj")

	if response == "yes" then
		print('user1 has accepted')
		if not uj.inventory[item1] then
			send(lang.reaction_dont_have)
			return
		end

		if uj.inventory[item1] < numcards then
			send(formatstring(lang.reaction_not_enough, { cdb[item1].name }))
			return
		end

		print("Removing item1 from user1")
		uj.inventory[item1] = uj.inventory[item1] - numcards
		if uj.inventory[item1] == 0 then uj.inventory[item1] = nil end

		print("Giving item1 to user1 storage")
		uj.storage[item1] = uj.storage[item1] and uj.storage[item1] + numcards or numcards

		uj.timesstored = uj.timesstored and uj.timesstored + numcards or numcards

		send(formatstring(lang.stored_message, { uj.id, uj.pronouns["their"], numcards, cdb[item1].name }, lang.plural_s))

		db.save_user(message._author.id)
		cmd.checkcollectors.run(message, {}, message.channel)
		cmd.checkmedals.run(message, {}, message.channel)
	end

	if response == "no" then
		print('user1 has denied')
		send(formatstring(lang.reaction_stopped, { uj.id, uj.pronouns["their"], cdb[item1].name }, lang.plural_s))
	end
end

return command
