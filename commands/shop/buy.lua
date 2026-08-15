local command = {
	name = "buy",
	description = "Buy an object from the shop",
	options = {
		{
			name = "name",
			description = "Object to buy",
			type = 3,
			required = true
		},
		{
			name = "amount",
			description = "Number of copies to get",
			type = 4,
			required = false,
			min_value = 1
		}
	}
}
function command.run(message, mt)
	local uj = db.get_user(message._author.id)
	if uj.unlocked_commands.shop or uj.room == 3 then
		command.buy(message, mt, uj)
	else
		message:reply("Uh, there doesn't seem to be a shop around here... How about moving around?")
	end
end

function command.buy(message, mt, uj)
	local time = sw:getTime()
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/shop/buy.json", "")
	checkforreload(time:toDays())
	local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
	local sprice
	local srequest
	local sname
	local stock
	local sindex
	local numrequest = 1
	local mt_name = mt[1] or mt.name
	local mt_amount = mt[2] or mt.amount

	if tonumber(mt_amount) then
		if tonumber(mt_amount) > 1 then
			numrequest = math.floor(mt_amount)
		end
	end

	if (not mt_name) or (mt_name == "") then
		cmd.look.run(message, mt)
		mt_name = ""
		return true
	end

	--error handling
	local sendshoperror = {
		notenough = function()
			message:reply(formatstring(lang.no_tokens, { sprice, sname }))
		end,

		outofstock = function()
			message:reply(formatstring(lang.out_of_stock, { sname }))
		end,

		toomanyrequested = function()
			message:reply(formatstring(lang.too_many_requested, { stock, sname }))
		end,

		donthave = function()
			if nopeeking then
				message:reply(formatstring(lang.nopeeking_error, { mt_name }))
			else
				message:reply(formatstring(lang.donthave_1, { sname }))
			end
		end,

		alreadyhave = function()
			message:reply(formatstring(lang.alreadyhave, { sname }))
		end,

		hasfixedmouse = function()
			message:reply(lang.hasfixedmouse)
		end,

		oneitemonly = function()
			message:reply(lang.oneitemonly)
		end,

		unknownrequest = function()
			if nopeeking then
				message:reply(formatstring(lang.nopeeking_error, { mt_name }))
			else
				message:reply(formatstring(lang.unknownrequest, { mt_name }))
			end
		end
	}

	if constexttofn(mt_name) then
		srequest = constexttofn(mt_name)
		sname = consdb[srequest].name

		for i, v in ipairs(sj.consumables) do
			if v.name == srequest then
				sindex = i
				break
			end
		end

		if not sindex then
			sendshoperror["donthave"]()
			return true
		end

		stock = sj.consumables[sindex].stock
		if stock <= 0 then
			sendshoperror["outofstock"]()
			return true
		end

		if numrequest > stock then
			sendshoperror["toomanyrequested"]()
			return true
		end

		sprice = sj.consumables[sindex].price * numrequest
		if uj.tokens < sprice then
			sendshoperror["notenough"]()
			return true
		end

		--can buy consumable
		ynbuttons(message, {
				color = uj.embedc,
				title = formatstring(lang.buying_item, { sname }),
				description = lang.consumable_desc .. "\n`" .. consdb[srequest].description .. "`\n" .. formatstring(
					lang.consumable_buy, { message.author.id, numrequest, sprice }, lang.plural_s
				),
			}, "buy",
			{
				itemtype = "consumable",
				sname = sname,
				sprice = sprice,
				sindex = sindex,
				srequest = srequest,
				numrequest =
					numrequest
			}, message.author.id, uj.lang)
		return true
	end

	if itemtexttofn(mt_name) then
		srequest = itemtexttofn(mt_name)
		sname = itemdb[srequest].name
		sprice = sj.itemprice

		if srequest ~= sj.item then
			sendshoperror["donthave"]()
			return true
		end

		if uj.items[srequest] then
			sendshoperror["alreadyhave"]()
			return true
		end

		if sj.item == "brokenmouse" and uj.items["fixedmouse"] then
			sendshoperror["hasfixedmouse"]()
			return true
		end

		if sj.itemstock <= 0 then
			sendshoperror["outofstock"]()
			return true
		end

		if numrequest > 1 then
			sendshoperror["oneitemonly"]()
			return true
		end

		if uj.tokens < sprice then
			sendshoperror["notenough"]()
			return true
		end

		--can buy item
		ynbuttons(message, {
				color = uj.embedc,
				title = formatstring(lang.buying_item, { sname }),
				description = lang.item_desc ..
					"\n`" .. itemdb[srequest].description ..
					"`\n" .. formatstring(lang.item_buy, { message.author.id, sprice }),
			}, "buy",
			{ itemtype = "item", sname = sname, sprice = sprice, sindex = sindex, srequest = srequest, numrequest = 1 },
			message.author.id, uj.lang)
		return true
	end

	if texttofn(mt_name) then
		print("card!")
		srequest = texttofn(mt_name)
		sname = cdb[srequest].name

		for i, v in ipairs(sj.cards) do
			if v.name == srequest then
				sindex = i
				break
			end
		end

		if not sindex then
			sendshoperror["donthave"]()
			return true
		end

		stock = sj.cards[sindex].stock
		if stock <= 0 then
			sendshoperror["outofstock"]()
			return true
		end

		if numrequest > stock then
			sendshoperror["toomanyrequested"]()
			return true
		end

		sprice = sj.cards[sindex].price * numrequest
		if uj.tokens < sprice then
			sendshoperror["notenough"]()
			return true
		end

		--can buy card
		ynbuttons(message, {
			color = uj.embedc,
			title = formatstring(lang.buying_card, { sname }),
			description = lang.card_desc .. "\n`" .. cdb[srequest].description .. "`\n" .. formatstring(
				lang.card_buy, { message.author.id, numrequest, sprice }, lang.plural_s
			),
		}, "buy", {
			itemtype = "card",
			sname = sname,
			sprice = sprice,
			sindex = sindex,
			srequest = srequest,
			numrequest =
				numrequest
		}, message.author.id, uj.lang)
		return true
	end

	sendshoperror["unknownrequest"]()
	return true
end

return command
