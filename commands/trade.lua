local command = {
	name = "trade",
	description = "Trade cards with another user!",
	options = {
		{
			name = "my_card",
			description = "The card I want to give this user",
			type = 3,
			required = true
		},
		{
			name = "their_card",
			description = "The card I want from that user in return",
			type = 3,
			required = true
		},
		{
			name = "trader_nick",
			description = "Trade with someone by trading nickname",
			type = 3
		},
		{
			name = "trader_user",
			description = "Trade with someone by username",
			type = 6 -- TODO: check that??? is user type 6
		}
	}
}
function command.run(message, mt)
	local author = message._author
	print(author.name .. " did !trade")
	local uj = db.get_user(author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/trade.json", "")
    if not message.guild then
        message:reply(lang.dm_message)
        return
    end

	local my_item_req = mt[1] or mt.my_card
    local trade_user = mt[2] or mt.trader_nick or mt.trader_user.id
	local their_item_req = mt[3] or mt.their_card

	if trade_user == nil or my_item_req == nil or their_item_req == nil then
		message:reply(lang.no_arguments)
		return
	end

	local uj2i = usernametoid(trade_user)

	print("checking if user 2 exists")
	if not uj2i then
		message:reply(formatstring(lang.no_user, { trade_user }))
		return
	end

	print("checking if users are different people")
	if uj2i == author.id then
		message:reply(lang.same_user)
		return
	end

	print("checking if item 1 exists")
	local item1 = texttofn(my_item_req)
	if not item1 then
		if nopeeking then
			message:reply(formatstring(lang.no_item_nopeeking, { my_item_req }) .. lang.no_item1_nopeeking)
		else
			message:reply(formatstring(lang.no_item, { my_item_req }))
		end
		return
	end

    local uj2 = db.get_user(uj2i)

	print("checking if item 2 exists")
	local item2 = texttofn(their_item_req)
	if not item2 then
		if nopeeking then
			message:reply(formatstring(lang.no_item_nopeeking, { their_item_req }) ..
			formatstring(lang.no_item2_nopeeking, { client:getUser(uj2i).name }))
		else
			message:reply(formatstring(lang.no_item, { their_item_req }))
		end
		return
	end


	if not uj2.lang then
		uj2.lang = "en"
	end

	local lang2 = dpf.loadjson("langs/" .. uj2.lang .. "/trade.json", "")

	print("checking if u1 has i1")
	if not uj.inventory[item1] then
		if nopeeking then
			message:reply(formatstring(lang.no_item_nopeeking, { my_item_req }) .. lang.no_item1_nopeeking)
		else
			message:reply(formatstring(lang.dont_have_user1, { cdb[item1].name }))
		end
		return
	end

	print("checking if u2 has i2")
	if not uj2.inventory[item2] then
		if nopeeking then
			message:reply(formatstring(lang.no_item_nopeeking, { their_item_req }) ..
			formatstring(lang.no_item1_nopeeking, { client:getUser(uj2i).name }))
		else
			message:reply(formatstring(lang.dont_have_user2,
				{ client:getUser(uj2i).name, cdb[item2].name, prosel.getPronoun(uj.lang, uj2.pronouns["selection"], "their") }))
		end
		return
	end

	print("success!!!!!")
	ynbuttons(message, formatstring(lang2.confirm_message, {
			uj2.id, uj.id, prosel.getPronoun(uj2.lang, uj.pronouns["selection"], "their"), cdb[item1].name, cdb[item2]
			.name }),
		command.reaction, { uj2i = uj2i, item1 = item1, item2 = item2 }, uj2.id, uj2.lang)
end

function command.reaction(message, interaction, data, response, base_reply)
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
			message:update({
				components = { {
					type = 10,
					content = text
				} }
			})
		end
	end
	print('It is a trade message being reacted to')
	local item1 = data.item1
	local item2 = data.item2
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/trade.json", "")
	print("Loaded uj")
	local uj2 = db.get_user(data.uj2i)
	local lang2 = dpf.loadjson("langs/" .. uj2.lang .. "/trade.json", "")
	print("Loaded uj2")

	if response == "yes" then
		print('user2 has accepted')
		if not (uj.inventory[item1] and uj2.inventory[item2]) then
			if uj.lang == uj2.lang then
				send(lang.reaction_no_card)
			else
				send(lang.reaction_no_card .. "\n" .. lang2.reaction_no_card)
			end
			return
		end

		print("Removing item1 from user1")
		uj.inventory[item1] = uj.inventory[item1] - 1
		if uj.inventory[item1] == 0 then uj.inventory[item1] = nil end
		print("Removing item2 from user2")
		uj2.inventory[item2] = uj2.inventory[item2] - 1
		if uj2.inventory[item2] == 0 then uj2.inventory[item2] = nil end

		print("Giving item1 to user2")
		uj2.inventory[item1] = uj2.inventory[item1] and uj2.inventory[item1] + 1 or 1
		print("Giving item2 to user1")
		uj.inventory[item2] = uj.inventory[item2] and uj.inventory[item2] + 1 or 1

		uj.timestraded = uj.timestraded and uj.timestraded + 1 or 1
		uj2.timestraded = uj2.timestraded and uj2.timestraded + 1 or 1

		if uj.lang == uj2.lang then
			interaction:reply(formatstring(lang.reaction_trade_done, { uj2.id, uj.id }))
		else
			interaction:reply(formatstring(lang.reaction_trade_done, { uj2.id, uj.id }) ..
			"\n" .. formatstring(lang2.reaction_trade_done, { uj2.id, uj.id }))
		end
		db.save_user(data.uj2i)
		db.save_user(message._author.id)
		db.uncache_user(data.uj2i)
		db.uncache_user(message._author.id)
	end

	if response == "no" then
		print('user2 has denied')
		if uj.lang == uj2.lang then
			send(formatstring(lang.reaction_trade_denied, { uj2.id, uj.id }))
		else
			send(formatstring(lang.reaction_trade_denied, { uj2.id, uj.id }) ..
			"\n" .. formatstring(lang2.reaction_trade_denied, { uj2.id, uj.id }))
		end
	end
end


return command
