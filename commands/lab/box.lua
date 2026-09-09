local command = {
	name = "box",
	description = "Use the box. There's a box somewhere."
}

function command.run(message, mt)
	local uj = db.get_user(message._author.id)
	local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)
	if (uj.unlocked_commands and uj.unlocked_commands.lab) or uj.room == 1 then
		if uj.room ~= 1 then
			cmd.move.run(message, {room_definitions[1].name}, false)
		end
		command.use(message, mt, uj, wj)
	else
		message:reply(formatstring("You haven't discovered this yet! Try using {1} and {2} to find it.", {
			formatslash("look", message.guild.id), formatslash("move", message.guild.id),
		}))
	end
end

function command.use(message, mt, uj, wj)
	local time = sw:getTime()
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/lab/box.json", "")
	if not uj.lastbox then
		uj.lastbox = -24
	end
	local cooldown = (uj.equipped == "stainedgloves") and config.cooldowns.box_gloves or config.cooldowns.box
	if uj.lastbox + cooldown > time:toHours() then
		local minutesleft = math.ceil(uj.lastbox * 60 - time:toMinutes() + cooldown * 60)
		local durationtext = formattime(minutesleft, uj.lang)
		message:reply(formatstring(lang.wait_message, { durationtext }))
		return true
	end

	if not next(uj.inventory) then
		message:reply { embed = {
			color = uj.embedc,
			title = lang.embed_title,
			description = lang.embed_no_card,
		} }
		return true
	end

	if not uj.skipprompts then
		ynbuttons(message, {
			color = uj.embedc,
			title = lang.embed_title,
			description = message.author.mentionString .. lang.confirm_message,
		}, cmd.lab_box.reaction, {}, uj.id, uj.lang)
		return true
	else
		command.reaction(message, nil, nil, "yes")
		return true
	end
end

function command.reaction(message, interaction, data, response)
	local function send(text)
		if interaction then interaction:reply(text) else message:reply(text) end
	end
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/lab/box.json", "")
	local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)
	local time = sw:getTime()
	print("Loaded uj")

	if response == "yes" then
		print('user1 has accepted')
		local cooldown = (uj.equipped == "stainedgloves") and config.cooldowns.box_gloves or config.cooldowns.box
		if uj.lastbox + cooldown > time:toHours() then
			send(lang.reaction_not_cooldown)
			return
		end

		if not next(uj.inventory) then
			send(lang.reaction_no_card)
			return
		end

		local iptable = {}
		for k, v in pairs(uj.inventory) do
			for i = 1, v do
				table.insert(iptable, k)
			end
		end

		local givecard = iptable[math.random(#iptable)]
		local boxpoolindex = math.random(#wj.boxpool)
		local getcard = wj.boxpool[boxpoolindex]
		print("user giving " .. givecard .. " and getting " .. getcard)

		uj.inventory[getcard] = uj.inventory[getcard] and uj.inventory[getcard] + 1 or 1
		uj.inventory[givecard] = uj.inventory[givecard] - 1
		if uj.inventory[givecard] == 0 then uj.inventory[givecard] = nil end

		wj.boxpool[boxpoolindex] = givecard

		print(interaction)
		send(formatstring(lang.boxed_message,
			{ uj.id, cdb[givecard].name, uj.pronouns["their"], cdb[getcard].name, getcard }))

		if not uj.togglecheckcard then
			if not uj.storage[getcard] then
				message:reply(formatstring(lang.not_in_storage, { cdb[getcard].name }))
			end
		end
		uj.timesusedbox = uj.timesusedbox and uj.timesusedbox + 1 or 1
		uj.lastbox = time:toHours()

		if uj.sodapt then
			if uj.sodapt.box then
				uj.lastbox = uj.lastbox + uj.sodapt.box
				uj.sodapt.box = nil
				if uj.sodapt == {} then
					uj.sodapt = nil
				end
			end
		end
		if not uj.unlocked_commands then
			uj.unlocked_commands = {}
		end
		uj.unlocked_commands.lab = true
		db.save_user(message._author.id)
		dpf.savejson("savedata/worldsave.json", wj)
	end

	if response == "no" then
		print('user1 has denied')
		send(lang.reaction_stopped)
	end
end

return command
