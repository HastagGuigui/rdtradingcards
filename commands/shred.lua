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

    local req_card = mt[1] or mt.card
	local req_amount = mt[2] or mt.amount or 1
	local curfilename = texttofn(req_card)

	if not curfilename then
		if nopeeking then
			message:reply(formatstring(lang.error_nopeeking, { req_card }))
		else
			message:reply(formatstring(lang.no_item, { req_card }))
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
	if tonumber(req_amount) then
		numcards = math.max(1, tonumber(req_amount))
	end
	if mt[2] == "all" then
		numcards = uj.inventory[curfilename]
	end

	if uj.inventory[curfilename] >= numcards then
		ynbuttons(message, formatstring(lang.shred_confirm, { uj.id, numcards, cdb[curfilename].name }, lang.plural_s),
			"shred", { curfilename = curfilename, numcards = numcards }, uj.id, uj.lang)
	else
		message:reply(formatstring(lang.not_enough, { cdb[curfilename].name }))
	end
end

function command.reaction(message, interaction, data, response, base_reply)
	local function send(text)
		if base_reply then
			if base_reply.editReply then
				base_reply:editReply({ components = { { type = 10, content = text } } })
			else
				base_reply:update({ components = { { type = 10, content = text } } })
			end
		else
			message:update({ components = { { type = 10, content = text } } })
		end
	end
	local curfilename = data.curfilename
	local numcards = data.numcards
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/shred.json", "")

	if response == "yes" then
		print('user1 has accepted')

		if not uj.inventory[curfilename] then
			send(lang.reaction_dont_have)
			return
		end

		if uj.inventory[curfilename] < numcards then
			send(formatstring(lang.reaction_not_enough, { cdb[curfilename].name }))
			return
		end

		print("Removing item1 from user1")
		uj.inventory[curfilename] = uj.inventory[curfilename] - numcards
		if uj.inventory[curfilename] == 0 then uj.inventory[curfilename] = nil end

		uj.timesshredded = uj.timesshredded and uj.timesshredded + numcards or numcards

		send(formatstring(lang.shredded_message,
			{ uj.id, uj.pronouns["their"], numcards, cdb[curfilename].name }, lang.plural_s))
		db.save_user(message._author.id)
		cmd.checkmedals.run(message, {}, message.channel)
	end

	if response == "no" then
		print('user1 has denied')
		send(formatstring(lang.denied_message, { uj.id, uj.pronouns["their"], cdb[curfilename].name },
			lang.plural_s))
	end
end

return command
