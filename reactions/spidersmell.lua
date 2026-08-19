local reaction = {}
function reaction.run(message, interaction, data, response)
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/smell.json")
	print("Loaded uj")


	if response == "yes" then
		print('user1 has accepted')
		interaction:reply(lang.smell_spider)
	end

	if response == "no" then
		print('user1 has denied')
		interaction:reply(lang.smell_hand)
	end
end

return reaction
