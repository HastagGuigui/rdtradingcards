local command = {
	name = "showmedal",
	description = "Shows info about a medal you've collected",
	options = {
        {
            name = "medal",
            description = "Name of the medal",
            type = 3,
            required = true
		}
	}
}
function command.run(message, mt)
    print(message.author.name .. " did !showmedal")
	local author = message.author or message.user
	local uj = db.get_user(author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/showmedal.json", "")
	if #mt ~= 1 and not mt.medal then
		message:reply(lang.no_arguments)
		return
	end

	local query = mt[1] or mt.medal
	local curfilename = medaltexttofn(query)

	if not curfilename then
		if nopeeking then
			message:reply(formatstring(lang.error_nopeeking, { query }))
		else
			message:reply(formatstring(lang.no_medal, { query }))
		end
		return
	end

	if not uj.medals[curfilename] then
		print("user doesnt have medal")
		if nopeeking then
			message:reply(formatstring(lang.error_nopeeking, { query }))
		else
			message:reply(formatstring(lang.dont_have, { medaldb[curfilename].name }))
		end
		return
	end

	print("user has medal")
	message:reply { embed = {
		color = uj.embedc,
		title = lang.showing_medal,
		description = formatstring(lang.show_medal, { medaldb[curfilename].name, curfilename, medaldb[curfilename].description }),
		image = {
			url = medaldb[curfilename].embed
		}
	} }
end

return command
