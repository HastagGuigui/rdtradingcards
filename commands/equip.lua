local command = {
	name = "equip",
	description = "Equip an item in your inventory.",
	options = {
		{
			name = "item",
			description = "The item to equip.",
			required = true,
			type = 4, -- STRING
			autocomplete = true
		}
	}
}
function command.autocomplete(ia, comm, focused, args)
	local out = {}
	local uj = db.get_user(ia.user.id)
	local itemlist = uj.items
	for k, _ in pairs(itemlist) do
		local name = itemdb[k] and itemdb[k].name or "UNKNOWN ITEM"
		if (string.find(name, args.item) or string.find(k, args.item)) and #out < 25 then
			out[#out + 1] = { name = string.format("%s [%s]", name, k), value = k }
		end
	end
	ia:autocomplete(out)
end

function command.run(message, mt)
	local author = message.author ~= nil and message.author or message.user
	local time = sw:getTime()
	local uj = db.get_user(author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/equip.json", "")

	local request = mt[1] or mt.item

	if request == nil then
		message:reply(lang.no_arguments)
		return
	end
	print(author.name .. " did !equip")

	if not uj.equipped then
		uj.equipped = "nothing"
	end
	if not uj.items then
		uj.items = { nothing = true }
		uj.equipped = "nothing"
	end

	if not uj.lastequip then
		uj.lastequip = -24
	end

	if uj.lastequip + config.cooldowns.equip > time:toHours() then
		--extremely jank implementation, please make this cleaner if possible
		local minutesleft = math.ceil(uj.lastequip * 60 - time:toMinutes() + 360.00)
		local durationtext = formattime(minutesleft, uj.lang)
		message:reply(formatstring(lang.wait_message, { durationtext }))
		return
	end

	local curfilename = itemtexttofn(request)

	if not curfilename then
		if nopeeking then
			message:reply(formatstring(lang.nopeeking, { request }))
		else
			message:reply(formatstring(lang.nodatabase, { request }))
		end
		return
	end

	if not uj.items[curfilename] then
		if nopeeking then
			message:reply(formatstring(lang.nopeeking, { request }))
		else
			message:reply(formatstring(lang.donthave, { itemdb[curfilename].name }))
		end
		return
	end

	if uj.equipped == curfilename then
		message:reply(formatstring(lang.already_equipped, { itemdb[curfilename].name }))
		return
	end

	--woo hoo
	print(uj.equipped)
	if not uj.skipprompts then
		ynbuttons(message, formatstring(lang.prompt, { itemdb[uj.equipped].name, itemdb[curfilename].name }),
			command.reaction,
			{ newequip = curfilename }, uj.id, uj.lang)
	else
		if uj.equipped == 'aceofhearts' then
			if uj.acepulls ~= 0 then
				message:reply('The pulls stored in your **Ace of Hearts** disappear...')
				uj.acepulls = 0
			end
		end
		uj.equipped = curfilename
		message:reply(formatstring(lang.equipped, { uj.id, itemdb[curfilename].name, uj.pronouns["their"] }))
		uj.lastequip = time:toHours()

		if uj.sodapt and uj.sodapt.equip then
			uj.lastequip = uj.lastequip + uj.sodapt.equip
			uj.sodapt.equip = nil
			if uj.sodapt == {} then uj.sodapt = nil end
		end

		print('saved equipped as ' .. curfilename)
	end
end

function command.reaction(message, interaction, data, response, base_message)
	local function editBaseReply(text)
		if base_message.editReply then
			base_message:editReply({
				components = { {
					type = 10,
					content = text
				} }
			})
		else
			base_message:update({
				components = { {
					type = 10,
					content = text
				} }
			})
		end
	end
	local newequip = data.newequip
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/equip.json", "")
	local time = sw:getTime()
	print("Loaded uj")

	if response == "yes" then
		print('user1 has accepted')
		if uj.lastequip + config.cooldowns.equip > time:toHours() then
			interaction:reply(lang.reaction_not_cooldown)
			return
		end

		if uj.equipped == 'aceofhearts' then
			if uj.acepulls ~= 0 then
				interaction:reply('The pulls stored in your **Ace of Hearts** disappear...')
				uj.acepulls = 0
			end
		end

		uj.equipped = newequip
		editBaseReply(formatstring(lang.equipped, { "<@" .. uj.id .. "> ", itemdb[newequip].name, uj.pronouns["their"] }))

		uj.lastequip = time:toHours()

		if uj.sodapt and uj.sodapt.equip then
			uj.lastequip = uj.lastequip + uj.sodapt.equip
			uj.sodapt.equip = nil
			if uj.sodapt == {} then uj.sodapt = nil end
		end

		db.save_user(uj)
		db.uncache_user(uj)
	end

	if response == "no" then
		print('user1 has denied')
		editBaseReply(formatstring(lang.stopped, { "<@" .. uj.id .. "> ", uj.pronouns["their"] }))
	end
end

return command
