local command = {}
function command.run(message, mt)
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/togglecheck.json", "")
	if #mt ~= 1 then
		message:reply(lang.no_arguments)
		return
	end

	if (mt[1] == "card" or mt[1] == "cards" or mt[1] == "카드") then
		uj.togglecheckcard = not uj.togglecheckcard
		if uj.togglecheckcard then
			message:reply(lang.card_disabled_message)
		else
			message:reply(lang.card_enabled_message)
		end
	elseif (mt[1] == "token" or mt[1] == "tokens" or mt[1] == "토큰") then
		uj.togglechecktoken = not uj.togglechecktoken
		if uj.togglechecktoken then
			message:reply(lang.token_disabled_message)
		else
			message:reply(lang.token_enabled_message)
		end
	else
		if mt[1] == "" then
			message:reply(lang.no_arguments)
			return
		else
			message:reply(formatstring(lang.no_database, { mt[1] }))
		end
	end
end

return command
