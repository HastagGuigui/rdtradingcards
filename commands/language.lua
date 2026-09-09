local command = {
	name = "language",
	description = "Set the language used for commands.",
	options = {
		{
			name = "lang",
			description = "Language you want to use",
			required = false,
			type = 3,
			choices = {
				{
					name = "English",
					value = "en"
				},
				{
					name = "한국어 (Korean)",
					value = "ko"
				}
			}
		}
	}
}
function command.run(message, mt)
	local author = message.author or message.user
	print(author.name .. " did !language")
	local uj = db.get_user(author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/lang.json", "")

	if not uj.lang then
		uj.lang = "en"
	end

	local request = string.lower(mt[1] or mt.lang or "")
	local change_successful = false
	if request == "english" or request == "en" or request == "eng" or request == "영어" or request == "anglais" then
		change_successful = true
		uj.lang = "en"
	elseif request == "한국어" or request == "korean" or request == "ko" or request == "kr" or request == "kor" or request == "coréen" then
		change_successful = true
		uj.lang = "ko"

		-- @wolfplay uncomment this when you're ready to unleash hell upon this world
		-- elseif uj.hasengwish and (request == "engwish" or request == "owo") then
		--   change_successful = true
		--   uj.lang = "owo"

		-- elseif request == "français" or request == "french" or request == "fr" or request == "fra" then -- NOT YET!!
		--   change_successful = true
		--   uj.lang = "fr"
	elseif request == "" then
		local langname = "English"
		if uj.lang == "ko" then
			langname = "한국어"
		end
		-- if uj.lang == "fr" then
		--   langname = "Français"
		-- end
		message:reply(formatstring(lang.no_value, { langname }))
	else
		message:reply(formatstring(lang.no_database, { mt[1] }))
	end
	if change_successful then
		local lang = dpf.loadjson("langs/" .. uj.lang .. "/lang.json", "")
		local lang_p = dpf.loadjson("langs/" .. uj.lang .. "/pronoun.json", "")
		-- i love huge optimizations
		cmd.pronoun.set_pronoun(uj, lang_p[uj.pronouns.selection])
		message:reply(lang.lang_changed)
	end
end

return command
