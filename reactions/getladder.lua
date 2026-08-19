local reaction = {}
function reaction.run(message, interaction, data, response)
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/pyrowmid/machine.json")
	print("Loaded uj")
	local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)

	if response == "yes" then
		print('user1 has accepted')

		if uj.tokens < 4 then
			interaction:reply(lang.error_no_tokens)
			return
		end

		uj.tokens = uj.tokens - 4
		wj.ws = 507 -- see setworldstate.lua
		interaction:reply(lang.used_machine_ladder)
		db.save_user(message._author.id)
		dpf.savejson("savedata/worldsave.json", wj)
	end

	if response == "no" then
		print('user1 has denied')
		interaction:reply(lang.denied_message)
	end
	db.uncache_user(message._author.id)
end

return reaction
