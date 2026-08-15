local command = {
	name = "nickname",
	description = "Sets your trading nickname!",
	options = {
		{
			name = "show",
			description = "Show all your registered nicknames",
			type = 1,
        },
        {
            name = "check_user",
            description = "Check a user's registered nicknames",
            type = 1,
            options = {
                name = "user",
                description = "User to check",
                type = 6,
                required = true
            }
		}
	}
}
function command.run(message, mt)
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/nickname.json", "")
	print(message._author.name .. " did !nickname")
	local maxnicknames = 4

	if not uj.names then
		uj.names = {}
		uj.names[message.author.name .. "#" .. message.author.discriminator] = true
	end

    local request = mt[1]
    if mt.show then
    	request = "check"
    end
	local name = mt[2] or mt.name

	local numnames = 0
	for k in pairs(uj.names) do
		numnames = numnames + 1
	end

	if request == "" then
		request = "check"
		name = uj.id
	end

	if request == "add" then
		if not name then
			message:reply(lang.add_nothing)
			return
		end

		if name == uj.id then
			message:reply(lang.add_id)
			return
		end

		if usernametojson(name) then
			if string.find(usernametojson(name), uj.id, 10) then
				message:reply(formatstring(lang.add_already, { name }))
			else
				message:reply(lang.add_other_user)
			end
			return
		end

		if string.sub(name, 1, 1) == "<" and string.sub(name, #name, #name) == ">" then
			message:reply(lang.add_invalid)
			return
		end

		if numnames >= maxnicknames then
			message:reply(formatstring(lang.add_too_many, { maxnicknames }))
			return
		end

		uj.names[name] = true
		message:reply(formatstring(lang.add_success, { name }))
	elseif mt[1] == "remove" then
		if not mt[2] then
			message:reply(lang.remove_nothing)
			return
		end

		if numnames == 1 then
			message:reply(lang.remove_least_one)
			return
		end

		if not uj.names[mt[2]] then
			message:reply(formatstring(lang.remove_no_such, { mt[2] }))
			return
		end

		uj.names[mt[2]] = nil
		message:reply(formatstring(lang.remove_success, { mt[2] }))
	elseif mt[1] == "reset" then
		uj.names = {}
		uj.names[message.author.name .. "#" .. message.author.discriminator] = true
		message:reply(formatstring(lang.reset_success, { message.author.name .. "#" .. message.author.discriminator }))
	elseif mt[1] == "check" then
		local nicknamestring = ""
		if not mt[2] then
			mt[2] = uj.id
		end

		local uj2f = usernametojson(mt[2])
		if not uj2f then
			message:reply(formatstring(lang.check_no_user, { mt[2] }))
			return
		end

		local uj2 = dpf.loadjson(uj2f, defaultjson)
		for k in pairs(uj2.names) do
			nicknamestring = nicknamestring .. k .. "/"
		end
		nicknamestring = nicknamestring:sub(1, -2)

		if string.find(uj2f, uj.id, 10) then
			if numnames == 1 then
				message:reply(lang.check_yourself_singular .. nicknamestring)
			else
				message:reply(lang.check_yourself_plural .. nicknamestring)
			end
		else
			local numnames2 = 0
			for k in pairs(uj2.names) do numnames2 = numnames2 + 1 end
			if numnames2 == 1 then
				message:reply(formatstring(lang.check_other_singular,
					{ nicknamestring, (uj.lang ~= "ko" and uj2.pronouns["their"]) }))
			else
				message:reply(formatstring(lang.check_other_plural, { mt[2], nicknamestring }))
			end
		end
	else
		message:reply(formatstring(lang.invalid_command, { mt[1] }))
	end

	dpf.savejson("savedata/" .. message.author.id .. ".json", uj)
end

return command
