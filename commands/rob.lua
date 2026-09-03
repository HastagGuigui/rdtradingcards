local command = {
	name = "rob",
	description = "Robs the shop",
}

function command.run(message, mt)
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/look/shop.json")
	if (uj.unlocked_commands and uj.unlocked_commands.shop) or uj.room == 3 then
		if uj.room ~= 3 then
			cmd.move.run(message, {room_definitions[3].name}, false)
		end
		command.rob(message, mt, uj, lang)
	else
		message:reply(formatstring("You haven't discovered this yet! Try using {1} and {2} to find it.", {
			formatslash("look", message.guild.id), formatslash("move", message.guild.id),
		}))
	end
end

function command.rob(message, args, uj, lang)
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/look/shop.json")
	local time = sw:getTime()
	checkforreload(time:toDays())
	local author = message._author
	print(author.name .. " did !rob")
	local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
	local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/rob.json", "")

	if not message.guild then
		message:reply(lang.dm_message)
		return
	end

	local srequest
	local sname
	local stock
	local sindex
	local numrequest = 1

	if tonumber(args[2]) then
		if tonumber(args[2]) > 1 then
			numrequest = math.floor(args[2])
		end
	end

	if not uj.lastrob then
		uj.lastrob = 0
	end

	if not uj.robheat then
		uj.robheat = 0
	end

	if not wj.skiprob then
		wj.skiprob = false
		dpf.savejson("savedata/worldsave.json", wj)
	end

	if uj.lastrob + 4 > sj.stocknum and uj.lastrob ~= 0 then
		local stocksleft = uj.lastrob + 4 - sj.stocknum
		local stockstring = formatstring(lang.more_restock, { stocksleft })
		if lang.needs_plural_s == true then
			if stocksleft > 1 then
				stockstring = stockstring .. lang.plural_s
			end
		end
		local minutesleft = math.ceil((26 / 24 - time:toDays() + sj.lastrefresh) * 24 * 60)

		local durationtext = formattime(minutesleft, uj.lang)
		if uj.lastrob + 3 == sj.stocknum then
			message:reply(formatstring(lang.blacklist_next, { durationtext }))
		else
			message:reply(formatstring(lang.blacklist, { stockstring, durationtext }))
		end
		return
	end

	local newuj = automove(uj.room, "rob", message)
	if newuj then
		uj = newuj
	end

	--error handling
	local sendshoperror = {
		outofstock = function()
			message:reply(formatstring(lang.out_of_stock, { sname }))
		end,

		toomanyrequested = function()
			message:reply(formatstring(lang.too_many_requested, { stock, sname }))
		end,

		donthave = function()
			if nopeeking then
				message:reply(formatstring(lang.nopeeking_error, { args[1] }))
			else
				message:reply(formatstring(lang.donthave, { sname }))
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
				message:reply(formatstring(lang.nopeeking_error, { args[1] }))
			else
				message:reply(formatstring(lang.unknownrequest, { args[1] }))
			end
		end
	}

	if not args[1] or args[1] == "" then
		local uj = db.get_user(message._author.id)
		local itemtypes = {}
		if sj.itemstock > 0 then
			if not uj.items[sj.item] then
				itemtypes[1] = "item"
			end
		end
		for i, v in ipairs(sj.cards) do
			if v.stock > 0 then
				itemtypes[#itemtypes + 1] = "card"
				break
			end
		end
		for i, v in ipairs(sj.consumables) do
			if v.stock > 0 then
				itemtypes[#itemtypes + 1] = "consumable"
				break
			end
		end

		if #itemtypes == 0 then
			message:reply(lang.rob_random_nothing)
			return
		end
		if uj.skipprompts and wj.skiprob then
			cmdre["rob"].run(message, nil, { random = true }, "yes")
		else
				ynbuttons(message, lang.rob_shop_random, cmdre.rob.run, { random = true }, uj.id, uj.lang)
		end
		return
	else
		if constexttofn(args[1]) then
			srequest = constexttofn(args[1])
			sname = consdb[srequest].name

			for i, v in ipairs(sj.consumables) do
				if v.name == srequest then
					sindex = i
					break
				end
			end

			if not sindex then
				sendshoperror["donthave"]()
				return
			end

			sprice = sj.consumables[sindex].price
			stock = sj.consumables[sindex].stock
			if stock <= 0 then
				sendshoperror["outofstock"]()
				return
			end

			if numrequest > stock then
				sendshoperror["toomanyrequested"]()
				return
			end

			-- can rob consumable
			if uj.skipprompts and wj.skiprob then
				cmdre["rob"].run(message, nil,
					{ itemtype = "consumable", sname = sname, sindex = sindex, srequest = srequest, sprice = sprice, numrequest =
					numrequest, random = false }, "yes")
			else
				ynbuttons(message, lang.rob_shop, cmdre.rob.run,
					{ itemtype = "consumable", sname = sname, sindex = sindex, srequest = srequest, sprice = sprice, numrequest =
					numrequest, random = false }, uj.id, uj.lang)
			end
			return
		end

		if itemtexttofn(args[1]) then
			srequest = itemtexttofn(args[1])
			sname = itemdb[srequest].name
			sprice = sj.itemprice

			if srequest ~= sj.item then
				sendshoperror["donthave"]()
				return
			end

			if uj.items[srequest] then
				sendshoperror["alreadyhave"]()
				return
			end

			if sj.item == "brokenmouse" and uj.items["fixedmouse"] then
				sendshoperror["hasfixedmouse"]()
				return
			end

			if sj.itemstock <= 0 then
				sendshoperror["outofstock"]()
				return
			end

			if numrequest > 1 then
				sendshoperror["oneitemonly"]()
				return
			end

			--can buy item
			if uj.skipprompts and wj.skiprob then
				cmdre.rob.run(message, nil,
					{ itemtype = "item", sname = sname, srequest = srequest, sprice = sprice, random = false }, "yes")
			else
				ynbuttons(message, lang.rob_shop_item, cmdre.rob.run, { itemtype = "item", sname = sname, srequest = srequest, sprice = sprice, random = false },
					uj.id, uj.lang)
			end
			return
		end

		if texttofn(args[1]) then
			print("card!")
			srequest = texttofn(args[1])
			sname = cdb[srequest].name

			for i, v in ipairs(sj.cards) do
				if v.name == srequest then
					sindex = i
					break
				end
			end

			if not sindex then
				sendshoperror["donthave"]()
				return
			end

			stock = sj.cards[sindex].stock
			if stock <= 0 then
				sendshoperror["outofstock"]()
				return
			end

			if numrequest > stock then
				sendshoperror["toomanyrequested"]()
				return
			end

			--can buy card
			if uj.skipprompts and wj.skiprob then
				cmdre.rob.run(message, nil,
					{ itemtype = "card", sname = sname, sindex = sindex, srequest = srequest, numrequest = numrequest, random = false },
					"yes")
			else
				ynbuttons(message, lang.rob_shop, cmdre.rob.run,
					{ itemtype = "card", sname = sname, sindex = sindex, srequest = srequest, numrequest = numrequest, random = false },
					uj.id, uj.lang)
			end
			return
		end
		sendshoperror["unknownrequest"]()
	end
end

return command
