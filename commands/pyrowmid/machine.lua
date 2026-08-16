local command = {
    name = "machine",
	description = "Use the Strange Machine in the Pyrowmid."
}
function command.run(message, mt)
	local uj = db.get_user(message._author.id)
	local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)
	command.use(message, uj, wj)
end
function command.use(message, uj, wj)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/pyrowmid/machine.json", "")
	if not uj.tokens then
		uj.tokens = 0
	end
	if not uj.items then
		uj.items = { nothing = true }
	end
	if wj.ws ~= 506 then
		if not uj.skipprompts then
			ynbuttons(message, {
				color = uj.embedc,
				title = lang.using_machine,
				description = formatstring(lang.use_machine, { uj.tokens }),
			}, command.reaction, {}, uj.id, uj.lang)
		else
			command.reaction(message, nil, nil, "yes")
		end
		return true
	else
		if uj.tokens >= 4 then
			ynbuttons(message, {
				color = uj.embedc,
				title = lang.using_machine,
				description = formatstring(lang.use_machine_four, { uj.tokens }),
			}, "getladder", {}, uj.id, uj.lang)
			return true
		else
			message:reply(lang.notokens_four)
		end
	end
end

function command.reaction(message, interaction, data, response)
	local function send(text)
		if interaction then interaction:reply(text) else message:reply(text) end
	end
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/pyrowmid/machine.json", "")
	print("Loaded uj")

	if response == "yes" then
		print('user1 has accepted')

		if uj.tokens < 3 then
			send(lang.error_no_tokens)
			return
		end

		local itempt = {}
		for k in pairs(itemdb) do
			if uj.items["fixedmouse"] then
				if not uj.items[k] and k ~= "brokenmouse" then table.insert(itempt, k) end
			else
				if not uj.items[k] and k ~= "fixedmouse" then table.insert(itempt, k) end
			end
		end
		print(inspect(itempt))

		if #itempt == 0 then
			send(lang.error_allitems)
			return
		end

		local newitem = itempt[math.random(#itempt)]
		uj.items[newitem] = true
		uj.tokens = uj.tokens - 3
		local dep = lang.dep
		local cdep = math.random(1, #dep)
		local speen = lang.speen
		local cspeen = math.random(1, #speen)
		local action = lang.action
		local caction = math.random(1, #action)
		local truaction = formatstring(action[caction], { speen[cspeen] })
		local size = lang.size
		local csize = math.random(1, #size)
		local action2 = lang.action2
		local caction2 = math.random(1, #action2)
		print("alright let's see: action2: n°" .. caction2 .. " : " .. action2[caction2])
		send(formatstring(lang.used_machine,
			{ dep[cdep], truaction, size[csize], action2[caction2], itemdb[newitem].name, speen[cspeen] }))
		print("hang on a sec")
		db.save_user(message._author.id)
	end

	if response == "no" then
		print('user1 has denied')
		send(lang.denied_message)
	end
	db.uncache_user(message._author.id)
end

return command
