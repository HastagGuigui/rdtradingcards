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
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/shop/buy.json", "")
	if uj.unlocked_commands.shop or uj.room == 3 then
		command.buy(message, mt, uj, lang)
	else
		message:reply(formatstring("You haven't discovered this yet! Try using {1} and {2} to find it.", {
			formatslash("look", message.guild.id), formatslash("move", message.guild.id),
		}))
	end
end

function command.buy(message, mt, uj, lang)
	local author = message._author
	local time = sw:getTime()
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
		ynbuttons(message, command.buy_embed(
				uj.embedc,
				formatstring(lang.buying_item, { sname }),
				lang.consumable_desc .. "\n```" .. consdb[srequest].description .. "```\n" .. formatstring(
					lang.consumable_buy, { author.id, numrequest, sprice }, lang.plural_s
				)
			), command.reaction,
			{
				itemtype = "consumable",
				sname = sname,
				sprice = sprice,
				sindex = sindex,
				srequest = srequest,
				numrequest =
					numrequest
			}, author.id, uj.lang)
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
		ynbuttons(message, command.buy_embed(
				uj.embedc,
				formatstring(lang.buying_item, { sname }),
				lang.item_desc .. "\n`" .. itemdb[srequest].description ..
				"`\n" .. formatstring(lang.item_buy, { author.id, sprice })
			), command.reaction,
			{ itemtype = "item", sname = sname, sprice = sprice, sindex = sindex, srequest = srequest, numrequest = 1 },
			author.id, uj.lang)
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
		ynbuttons(message,
			command.buy_embed(uj.embedc, formatstring(lang.buying_card, { sname }),
				lang.card_desc .. "\n`" .. cdb[srequest].description .. "`\n" .. formatstring(
					lang.card_buy, { author.id, numrequest, sprice }, lang.plural_s
				)
			), command.reaction, {
				itemtype = "card",
				sname = sname,
				sprice = sprice,
				sindex = sindex,
				srequest = srequest,
				numrequest =
					numrequest
			}, author.id, uj.lang)
		return true
	end

	sendshoperror["unknownrequest"]()
	return true
end

function command.buy_embed(color, title, description)
	return {
		type = 17,
		accent_color = color,
		components = {
			{
				type = 10,
				content = "## " .. title
			}, {
			type = 10,
			content = description
		}
		}
	}
end

function command.reaction(message, interaction, data, response)
	local uj = db.get_user(interaction.user.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/shop/buy.json", "")
	local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
	print("Loaded uj: it has " .. uj.tokens .. " tokens")

	if response == "yes" then
		print('user1 has accepted')
		--sanity check
		local checked = false
		if data.itemtype == "consumable" then
			checked = (sj.consumables[data.sindex].name == data.srequest) and
				(sj.consumables[data.sindex].stock >= data.numrequest)
		end --other types also go up here

		if data.itemtype == "card" then
			checked = (sj.cards[data.sindex].name == data.srequest) and (sj.cards[data.sindex].stock >= data.numrequest)
		end

		if data.itemtype == "item" then
			checked = (sj.item == data.srequest) and (sj.itemstock ~= 0)
		end

		if not checked then
			interaction:reply(lang.error_not_in_stock)
			return
		end


		if uj.tokens < data.sprice then
			interaction:reply(lang.error_not_enough_tokens)
			return
		end

		--do the fucking thing here

		if data.itemtype == "consumable" then
			sj.consumables[data.sindex].stock = sj.consumables[data.sindex].stock - data.numrequest
			if not uj.consumables then uj.consumables = {} end
			local adding = (consdb[data.srequest].quantity or 1) * data.numrequest
			if not uj.consumables[data.srequest] then
				uj.consumables[data.srequest] = adding
			else
				uj.consumables[data.srequest] = uj.consumables[data.srequest] + adding
			end
		end
		if data.itemtype == "card" then
			sj.cards[data.sindex].stock = sj.cards[data.sindex].stock - data.numrequest
			if not uj.inventory then uj.inventory = {} end
			if not uj.inventory[data.srequest] then
				uj.inventory[data.srequest] = data.numrequest
			else
				uj.inventory[data.srequest] = uj.inventory[data.srequest] + data.numrequest
			end
			print("state:" .. uj.inventory[data.srequest])
		end
		if data.itemtype == "item" then
			sj.itemstock = sj.itemstock - 1
			uj.items[data.srequest] = true
		end
		uj.tokens = uj.tokens - data.sprice
		print("tokens now :" .. uj.tokens)

		interaction:reply(formatstring(lang.bought_message, { uj.id, data.sname }))
		if not uj.unlocked_commands.shop then
			interaction:reply(formatstring(lang.shorthand_unlocked, {
				formatslash("shop", message.guild.id),
				formatslash("buy", message.guild.id),
			}))
			uj.unlocked_commands.shop = true
		end

		db.save_user(interaction.user.id)
		dpf.savejson("savedata/shop.json", sj)
	end

	if response == "no" then
		print('user1 has denied')
		interaction:reply(formatstring(lang.denied_message, { data.sname }))
	end
end

return command
