local command = {
	name = "showitem",
	description = "Shows info about an item/consumable you own",
	options = {
		{
			name = "item",
			description = "Name of the item",
			type = 3,
			required = true
		}
	}
}
function command.run(message, mt)
	local author = message._author
	print(author.name .. " did !showitem")
	local uj = db.get_user(author.id)
	local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/showitem.json", "")
	if #mt ~= 1 and not mt.item then
		message:reply(lang.no_arguments)
		return
	end

	if not uj.consumables then uj.consumables = {} end
	local query = mt[1] or mt.item
	local curfilename = itemtexttofn(query) or constexttofn(query)

	if not curfilename then
		if nopeeking then
			message:reply(formatstring(lang.error_nopeeking, { query }))
		else
			message:reply(formatstring(lang.no_item, { query }))
		end
		return
	end

	local description = itemdb[curfilename] and itemdb[curfilename].description or consdb[curfilename].description
	local name = itemdb[curfilename] and itemdb[curfilename].name or consdb[curfilename].name
	local embedurl = itemdb[curfilename] and itemdb[curfilename].embed or consdb[curfilename].embed

	if not (uj.items[curfilename] or uj.consumables[curfilename] or (shophas(curfilename) and not (uj.lastrob + 3 > sj.stocknum and uj.lastrob ~= 0))) then
		print("user doesnt have item")
		if nopeeking then
			message:reply(formatstring(lang.error_nopeeking, { query }))
		else
			message:reply(formatstring(lang.dont_have, { name }))
		end
		return
	end

	print("user has item or consumable")

	message:reply { embed = {
		color = uj.embedc,
		title = lang.showing_item,
		description = formatstring(lang.show_item, { name, curfilename, description }),
		image = {
			url = embedurl
		}
	} }
end

return command
