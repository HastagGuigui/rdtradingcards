local command = {}
function command.run(message, mt)
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/skipprompts.json", "")
	uj.skipprompts = not uj.skipprompts
	if uj.skipprompts then
		message:reply(lang.enabled_message)
	else
		message:reply(lang.disabled_message)
	end
end

return command
