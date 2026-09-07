local command = {
	name = "rob",
	description = "Robs the shop. You can get an item for free, but at a risk...",
	options = {
		{
			type = 3,
			name = "item",
			description = "The item/card to steal.",
			required = true
		},
		{
			type = 4,
			name = "amount",
			description = "The number of copies of that item to get.",
		}
	}
}

function command.run(message, mt)
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/rob.json")
	if (uj.unlocked_commands and uj.unlocked_commands.shop) or uj.room == 3 then
		if uj.room ~= 3 then
			cmd.move.run(message, { room_definitions[3].name }, false)
		end
		command.rob(message, mt, uj, lang)
	else
		message:reply(formatstring("You haven't discovered this yet! Try using {1} and {2} to find it.", {
			formatslash("look", message.guild.id), formatslash("move", message.guild.id),
		}))
	end
end

function command.rob(message, args, uj, lang)
	local time = sw:getTime()
	checkforreload(time:toDays())
	local author = message._author
	print(author.name .. " did !rob")
	local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
	local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)

	if not message.guild then
		message:reply(lang.dm_message)
		return
	end

	local itemarg = args[1] or args.item
	local amountarg = args[2] or args.amount

	local srequest
	local sname
	local stock
    local sindex
	local sprice
	local numrequest = 1

	if tonumber(amountarg) then
		if tonumber(amountarg) > 1 then
			numrequest = math.floor(amountarg)
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
		local stockstring = formatstring(lang.more_restock, { stocksleft }, lang.plural_s)
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
	print(newuj)

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
				message:reply(formatstring(lang.nopeeking_error, { itemarg }))
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
				message:reply(formatstring(lang.nopeeking_error, { itemarg }))
			else
				message:reply(formatstring(lang.unknownrequest, { itemarg }))
			end
		end
	}

	if not itemarg or itemarg == "" then
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
		if constexttofn(itemarg) then
			srequest = constexttofn(itemarg)
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
				command.reaction(message, nil,
					{
						itemtype = "consumable",
						sname = sname,
						sindex = sindex,
						srequest = srequest,
						sprice = sprice,
						numrequest =
							numrequest,
						random = false
					}, "yes")
			else
				ynbuttons(message, lang.rob_shop, command.reaction,
					{
						itemtype = "consumable",
						sname = sname,
						sindex = sindex,
						srequest = srequest,
						sprice = sprice,
						numrequest =
							numrequest,
						random = false
					}, uj.id, uj.lang)
			end
			return
		end

		if itemtexttofn(itemarg) then
			srequest = itemtexttofn(itemarg)
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
				command.reaction(message, nil,
					{ itemtype = "item", sname = sname, srequest = srequest, sprice = sprice, random = false }, "yes")
			else
				ynbuttons(message, lang.rob_shop_item, command.reaction,
					{ itemtype = "item", sname = sname, srequest = srequest, sprice = sprice, random = false },
					uj.id, uj.lang)
			end
			return
		end

		if texttofn(itemarg) then
			print("card!")
			srequest = texttofn(itemarg)
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
				command.reaction(message, nil,
					{ itemtype = "card", sname = sname, sindex = sindex, srequest = srequest, numrequest = numrequest, random = false },
					"yes")
			else
				ynbuttons(message, lang.rob_shop, command.reaction,
					{ itemtype = "card", sname = sname, sindex = sindex, srequest = srequest, numrequest = numrequest, random = false },
					uj.id, uj.lang)
			end
			return
		end
		sendshoperror["unknownrequest"]()
	end
end


function command.rob_calc(robchance, uj, rob_weight)
	local robmustache = 0
	local robdoubleedge = 0
	if uj.equipped == "mustache" then
		robmustache = 1
	else
		robmustache = 0
	end

	if uj.equipped == "doubleedge" then
		robdoubleedge = 1
	else
		robdoubleedge = 0
	end
    return robchance >= math.max((7.5 * (rob_weight * 1.5) * (uj.robheat + 1) * (1 + robmustache * 0.25) * (1 - robdoubleedge * 0.15)) * 100, 90)
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
            local _, err = message:reply({ components = { { type = 10, content = text } } })
			if err then
				print(err)
			end
		end
	end
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/rob.json", "")
	local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
	print("Loaded uj")

	if response == "yes" then
		print('user1 has accepted')
		if uj.lastrob + 3 > sj.stocknum and uj.lastrob ~= 0 then
			send(lang.error_already_robbed)
			return
		end

		if not uj.timesrobbed then uj.timesrobbed = 1 else uj.timesrobbed = uj.timesrobbed + 1 end

		if data.random == true then
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
				if v.stock then
					if v.stock > 0 then
						itemtypes[#itemtypes + 1] = "consumable"
						break
					end
				end
			end

			if #itemtypes ~= 0 then -- and math.random(1,100) ~= 1
				data.itemtype = itemtypes[math.random(1, #itemtypes)]

				if data.itemtype == "item" then
					data.srequest = sj.item
					data.sname = itemdb[data.srequest].name
					data.sprice = sj.itemprice
				end

				if data.itemtype == "consumable" then
					local conslist = {}
					for i, v in ipairs(sj.consumables) do
						if v.stock > 0 then
							conslist[#conslist + 1] = v.name
						end
					end
					data.srequest = conslist[math.random(1, #conslist)]
					data.sname = consdb[data.srequest].name
					data.numrequest = 1
					for i, v in ipairs(sj.consumables) do
						if v.name == data.srequest then
							data.sindex = i
							break
						end
					end
					data.sprice = sj.consumables[data.sindex].price
				end

				if data.itemtype == "card" then
					local cardlist = {}
					for i, v in ipairs(sj.cards) do
						if v.stock > 0 then
							cardlist[#cardlist + 1] = v.name
						end
					end
					data.srequest = cardlist[math.random(1, #cardlist)]
					data.sname = cdb[data.srequest].name
					data.numrequest = 1
					for i, v in ipairs(sj.cards) do
						if v.name == data.srequest then
							data.sindex = i
							break
						end
					end
					data.sprice = sj.cards[data.sindex].price
				end
				--else
				--print("shoprobtime")
			end
		end



		if data.itemtype == "consumable" then
			local robchance = math.random(0, 10000)
			local robsucceed = false
			local rob_weight = 3
			robsucceed = command.rob_calc(robchance, uj, rob_weight)

			-- if (not robsucceed) and data.random then
			--   if math.random(1,3) == 1 then
			--     robsucceed = true
			--   end
			-- end

			if robsucceed then
				print("rob succeeded")
				sj.consumables[data.sindex].stock = sj.consumables[data.sindex].stock - data.numrequest
				if not uj.consumables then uj.consumables = {} end
				local adding = (consdb[data.srequest].quantity or 1) * data.numrequest
				if not uj.consumables[data.srequest] then
					uj.consumables[data.srequest] = adding
				else
					uj.consumables[data.srequest] = uj.consumables[data.srequest] + adding
				end
				send(formatstring(lang.rob_succeeded, {data.numrequest, data.sname}))
				if not uj.timesrobsucceeded then uj.timesrobsucceeded = 1 else uj.timesrobsucceeded = uj
					.timesrobsucceeded + 1 end
			else
				print("rob failed")

				local finalpm = 0
				if data.sprice <= 2 then
					finalpm = -2
				elseif data.sprice <= 5 then
					finalpm = -1
				else
					finalpm = 0
				end

				send(formatstring(lang.rob_failed, {data.numrequest, data.sname, 3 + finalpm}))
				uj.lastrob = sj.stocknum + finalpm
				uj.room = 2
				if not uj.timesrobfailed then uj.timesrobfailed = 1 else uj.timesrobfailed = uj.timesrobfailed + 1 end
			end
		end
		if data.itemtype == "card" then
			local robsucceed = false
			local blackpm
			local randompm = false
            local robchance = math.random(0, 10000)
			local rob_weight = 3.5
			if cdb[data.srequest].type == "Rare" then
				blackpm = -2
				rob_weight = 3.5 / 3
			elseif cdb[data.srequest].type == "Super Rare" or cdb[data.srequest].type == "PICO-8" then
				blackpm = -1
				rob_weight = 3.5 / 2
			elseif cdb[data.srequest].type == "Ultra Rare" then
				blackpm = -1
				rob_weight = 3.5 / 1
			elseif cdb[data.srequest].type == "Alternate" or cdb[data.srequest].type == "Discontinued" then
				rob_weight = 3.5 / 1
			elseif cdb[data.srequest].type == "Discontinued Rare" or cdb[data.srequest].type == "Alternative Rare" then
				rob_weight = 3.5 / 0.75
			elseif cdb[data.srequest].type == "Discontinued Super Rare" or cdb[data.srequest].type == "Alternative Super Rare" or cdb[data.srequest].type == "Discontinued Alternate" or cdb[data.srequest].type == "Alternate Alternate" then
				rob_weight = 3.5 / 0.5
			elseif cdb[data.srequest].type == "Discontinued Ultra Rare" or cdb[data.srequest].type == "Alternative Ultra Rare" then
				rob_weight = 3.5 / 0.25
			end
			robsucceed = command.rob_calc(robchance, uj, rob_weight)

			-- if (not robsucceed) and data.random then
			--   if uj.equipped == "mustache" then
			--     if math.random(1,4) == 1 then
			--       robsucceed = true
			--     end
			--   elseif uj.equipped == "doubleedge" then
			--     if math.random(1,5) == 1 or 2 then
			--       robsucceed = true
			--     end
			--   else
			--     if math.random(1,3) == 1 then
			--       robsucceed = true
			--     end
			--   end
			-- end

			if robsucceed == true then
				print("rob succeeded")
				sj.cards[data.sindex].stock = sj.cards[data.sindex].stock - data.numrequest
				if not uj.inventory then uj.inventory = {} end
                if not uj.inventory[data.srequest] then
                    uj.inventory[data.srequest] = data.numrequest
                else
                    uj.inventory[data.srequest] = uj.inventory[data.srequest] + data.numrequest
                end
				send(formatstring(lang.rob_succeeded, {data.numrequest, data.sname}))
				if not uj.timesrobsucceeded then uj.timesrobsucceeded = 1 else uj.timesrobsucceeded = uj
					.timesrobsucceeded + 1 end
			else
				print("rob failed")

				local finalpm = 0
				if data.random then
					if blackpm ~= nil then
						finalpm = blackpm
					else
						finalpm = -1
					end
				elseif blackpm ~= nil then
					finalpm = blackpm
				else
					finalpm = 0
				end

				send(formatstring(lang.rob_failed, {data.numrequest, data.sname, 3 + finalpm}))
				if uj.equipped == "mustache" then
					if finalpm == -1 then
						uj.lastrob = sj.stocknum + finalpm
					else
						uj.lastrob = sj.stocknum + finalpm - 1
					end
				elseif uj.equipped == "doubleedge" then
					uj.lastrob = sj.stocknum + finalpm + 1
				else
					uj.lastrob = sj.stocknum + finalpm
				end
				uj.room = 2
				if not uj.timesrobfailed then uj.timesrobfailed = 1 else uj.timesrobfailed = uj.timesrobfailed + 1 end
			end
		end
		if data.itemtype == "item" then
			local robchance = math.random(0, 10000)
			local robsucceed = false
			local rob_weight = 6
			robsucceed = command.rob_calc(robchance, uj, rob_weight)

			-- if (not robsucceed) and data.random then
			--   if math.random(1,3) == 1 then
			--     robsucceed = true
			--   end
			-- end

			if robsucceed then
				print("rob succeeded")
				sj.itemstock = sj.itemstock - 1
				uj.items[data.srequest] = true
				send(formatstring(lang.rob_succeeded_item, {"", data.sname}))
				if not uj.timesrobsucceeded then uj.timesrobsucceeded = 1 else uj.timesrobsucceeded = uj
					.timesrobsucceeded + 1 end
			else
				print("rob failed")

				local finalpm = 0
				if data.sprice <= 2 then
					finalpm = -2
				elseif data.sprice <= 5 then
					finalpm = -1
				else
					finalpm = 0
				end

				send(formatstring(lang.rob_failed, {"", data.sname, 3 + finalpm}))
				uj.lastrob = sj.stocknum + finalpm
				uj.room = 2
				if not uj.timesrobfailed then uj.timesrobfailed = 1 else uj.timesrobfailed = uj.timesrobfailed + 1 end
			end
		end

		db.save_user(message._author.id)
		dpf.savejson("savedata/shop.json", sj)
	end

	if response == "no" then
		print('user1 has denied')
		interaction:reply(formatstring(lang.rob_cancelled, {uj.id}))
	end
end



return command
