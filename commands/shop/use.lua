local command = {}
function command.run(message, mt, uj, wj)
	local time = sw:getTime()
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/shop/pet.json", "") -- fallback when request is not shop
	local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
	if uj.lastrob + 4 > sj.stocknum and uj.lastrob ~= 0 then
		lang = dpf.loadjson("langs/" .. uj.lang .. "/rob.json")
		local stocksleft = uj.lastrob + 4 - sj.stocknum
		local stockstring = formatstring(lang.more_restock, { stocksleft }, lang.plural_s)
		local minutesleft = math.ceil((26 / 24 - time:toDays() + sj.lastrefresh) * 24 * 60)

		local durationtext = formattime(minutesleft, uj.lang)
		if uj.lastrob + 3 == sj.stocknum then
			message.channel:send(formatstring(lang.blacklist_next, { durationtext }))
		else
			message.channel:send(formatstring(lang.blacklist, { stockstring, durationtext }))
		end
		return true, uj, wj
	end
	if request == "shop" or (uj.lang ~= "en" and request == lang.request_shop_1 or request == lang.request_shop_2 or request == lang.request_shop_3 or request == lang.request_shop_4) then
		local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/shop/buy.json", "")
		checkforreload(time:toDays())
		local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
		local sprice
		local srequest
		local sname
		local stock
		local sindex
		local numrequest = 1
		if tonumber(mt[3]) then
			if tonumber(mt[3]) > 1 then
				numrequest = math.floor(mt[3])
			end
		end

		if (not mt[2]) or (mt[2] == "") then
			cmd.look.run(message, mt)
			mt[2] = ""
			return true, uj, wj
		end

		--error handling
		local sendshoperror = {
			notenough = function()
				message.channel:send(formatstring(lang.no_tokens, { sprice, sname }))
			end,

			outofstock = function()
				message.channel:send(formatstring(lang.out_of_stock, { sname }))
			end,

			toomanyrequested = function()
				message.channel:send(formatstring(lang.too_many_requested, { stock, sname }))
			end,

			donthave = function()
				if nopeeking then
					message.channel:send(formatstring(lang.nopeeking_error, { mt[2] }))
				else
					message.channel:send(formatstring(lang.donthave_1, { sname }))
				end
			end,

			alreadyhave = function()
				message.channel:send(formatstring(lang.alreadyhave, { sname }))
			end,

			hasfixedmouse = function()
				message.channel:send(lang.hasfixedmouse)
			end,

			oneitemonly = function()
				message.channel:send(lang.oneitemonly)
			end,

			unknownrequest = function()
				if nopeeking then
					message.channel:send(formatstring(lang.nopeeking_error, { mt[2] }))
				else
					message.channel:send(formatstring(lang.unknownrequest, { mt[2] }))
				end
			end
		}

		if constexttofn(mt[2]) then
			srequest = constexttofn(mt[2])
			sname = consdb[srequest].name

			for i, v in ipairs(sj.consumables) do
				if v.name == srequest then
					sindex = i
					break
				end
			end

			if not sindex then
				sendshoperror["donthave"]()
				return true, uj, wj
			end

			stock = sj.consumables[sindex].stock
			if stock <= 0 then
				sendshoperror["outofstock"]()
				return true, uj, wj
			end

			if numrequest > stock then
				sendshoperror["toomanyrequested"]()
				return true, uj, wj
			end

			sprice = sj.consumables[sindex].price * numrequest
			if uj.tokens < sprice then
				sendshoperror["notenough"]()
				return true, uj, wj
			end

			--can buy consumable
			ynbuttons(message, {
				color = uj.embedc,
				title = formatstring(lang.buying_item, { sname }),
				description = lang.consumable_desc .. "\n`" .. consdb[srequest].description .. "`\n" .. formatstring(
					lang.consumable_buy, { message.author.id, numrequest, sprice }, lang.plural_s
				),
			}, "buy",
				{ itemtype = "consumable", sname = sname, sprice = sprice, sindex = sindex, srequest = srequest, numrequest =
				numrequest }, message.author.id, uj.lang)
			return true, uj, wj
		end

		if itemtexttofn(mt[2]) then
			srequest = itemtexttofn(mt[2])
			sname = itemdb[srequest].name
			sprice = sj.itemprice

			if srequest ~= sj.item then
				sendshoperror["donthave"]()
				return true, uj, wj
			end

			if uj.items[srequest] then
				sendshoperror["alreadyhave"]()
				return true, uj, wj
			end

			if sj.item == "brokenmouse" and uj.items["fixedmouse"] then
				sendshoperror["hasfixedmouse"]()
				return true, uj, wj
			end

			if sj.itemstock <= 0 then
				sendshoperror["outofstock"]()
				return true, uj, wj
			end

			if numrequest > 1 then
				sendshoperror["oneitemonly"]()
				return true, uj, wj
			end

			if uj.tokens < sprice then
				sendshoperror["notenough"]()
				return true, uj, wj
			end

			--can buy item
			ynbuttons(message, {
				color = uj.embedc,
				title = formatstring(lang.buying_item, { sname }),
				description = lang.item_desc ..
				"\n`" .. itemdb[srequest].description ..
				"`\n" .. formatstring(lang.item_buy, { message.author.id, sprice }),
			}, "buy", { itemtype = "item", sname = sname, sprice = sprice, sindex = sindex, srequest = srequest, numrequest = 1 },
				message.author.id, uj.lang)
			return true, uj, wj
		end

		if texttofn(mt[2]) then
			print("card!")
			srequest = texttofn(mt[2])
			sname = cdb[srequest].name

			for i, v in ipairs(sj.cards) do
				if v.name == srequest then
					sindex = i
					break
				end
			end

			if not sindex then
				sendshoperror["donthave"]()
				return true, uj, wj
			end

			stock = sj.cards[sindex].stock
			if stock <= 0 then
				sendshoperror["outofstock"]()
				return true, uj, wj
			end

			if numrequest > stock then
				sendshoperror["toomanyrequested"]()
				return true, uj, wj
			end

			sprice = sj.cards[sindex].price * numrequest
			if uj.tokens < sprice then
				sendshoperror["notenough"]()
				return true, uj, wj
			end

			--can buy card
			ynbuttons(message, {
				color = uj.embedc,
				title = formatstring(lang.buying_card, { sname }),
				description = lang.card_desc .. "\n`" .. cdb[srequest].description .. "`\n" .. formatstring(
					lang.card_buy, { message.author.id, numrequest, sprice }, lang.plural_s
				),
			}, "buy", { itemtype = "card", sname = sname, sprice = sprice, sindex = sindex, srequest = srequest, numrequest =
			numrequest }, message.author.id, uj.lang)
			return true, uj, wj
		end

		-- for c!shop -s
		if mt[2] == "-s" then
			cmd.look.run(message, { "shop -s" })
		elseif mt[2] == "-season" then
			cmd.look.run(message, { "shop -season" })
		else
			sendshoperror["unknownrequest"]()
		end
		return true, uj, wj
	elseif request == "wolf" or (uj.lang ~= "en" and request == lang.request_wolf) then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.petting_wolf,
			description = lang.petted_wolf,
			image = { url = "https://cdn.discordapp.com/attachments/829197797789532181/882289357128618034/petwolf.gif" }
		} }
	elseif request == "ghost" or (uj.lang ~= "en" and request == lang.request_ghost) then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.petting_ghost,
			description = lang.petted_ghost
		} }
	elseif request == "photo" or request == "dog" or (uj.lang ~= "en" and request == lang.request_photo or request == lang.request_dog) then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.petting_dog,
			description = lang.petted_dog,
			image = { url = "https://cdn.discordapp.com/attachments/829197797789532181/882287705638203443/okamii_triangle_frame_4.png" }
		} }
	else
		return false, uj, wj
	end
	return true, uj, wj
end
return command