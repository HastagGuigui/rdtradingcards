local command = {}
function command.run(message, mt)
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/togglecc.json", "")

	uj.disablecommunity = not uj.disablecommunity
	if uj.disablecommunity then
		message:reply(lang.disabled_message)
	else
		message:reply(lang.enabled_message)
	end
end

return command
