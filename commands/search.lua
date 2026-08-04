local command = {
	name = "search",
	description = "Return the amount of copies of a card you have",
	options = {
		{
			name = "card",
			description = "Name of the card",
			required = true,
			type = 3,
			autocomplete = true
		}
	}
}
function command.autocomplete(ia, comm, focused, args)
	local out = {}
	local cardlist = {}
	if nopeeking then
		local uj = db.get_user(ia.user.id)
		for k, v in pairs(uj.inventory) do
			cardlist[k] = true
		end
		for k, v in pairs(uj.storage) do
			cardlist[k] = true
		end
	else
		cardlist = cdb
	end
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
	print(author.name .. " did !search")
	local uj = db.get_user(author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/search.json", "")
	if #mt ~= 1 and not mt.card then
		message:reply(lang.no_arguments)
		return
	end

	local request = mt[1] or mt.card
	local curfilename = texttofn(request)

	if not curfilename then
		if nopeeking then
			message:reply(formatstring(lang.error_nopeeking, { request }))
		else
			message:reply(formatstring(lang.no_item, { request }))
		end
		return
	end

	local invnum = uj.inventory[curfilename] or 0
	local stornum = uj.storage[curfilename] or 0
	if nopeeking and invnum + stornum == 0 then
		message:reply(formatstring(lang.error_nopeeking, { request }))
	else
		message:reply(formatstring(lang.search_message, { cdb[curfilename].name, invnum, stornum }))
	end
end

return command
