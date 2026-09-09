local reaction = {}
function reaction.run(message, interaction, data, response)
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/lab/lab.json")
	print("Loaded uj")

	if response == "yes" then
		print('user1 has accepted')
		uj.items.brokenmouse = nil
		uj.items.fixedmouse = true
		uj.equipped = "fixedmouse"

		interaction:reply(lang.used_hole)
		db.save_user(message._author.id)
	end

	if response == "no" then
		print('user1 has denied')
		interaction:reply(lang.denied_hole)
	end
	db.uncache_user(message._author.id)
end

return reaction
