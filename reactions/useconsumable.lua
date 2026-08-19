local reaction = {}
function reaction.run(message, interaction, data, response)
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/cons.json")
	local request = data.crequest
	print("Loaded uj")
	if not uj.conspt then uj.conspt = "none" end

	if response == "yes" then
		print('user has accepted')

		if not uj.consumables[request] then
			interaction:reply(lang.no_item)
			return
		end


		local fn = request
		if consdb[request].command then
			request = consdb[request].command
		end

		if request == "..." then request = "ddd" end
		if request ~= "ddd" then
			if uj.equipped == 'aceofhearts' then
				if uj.acepulls ~= 0 then
					message:reply('The pulls stored in your **Ace of Hearts** disappear...')
					uj.acepulls = 0
				end
			end
		end

		cmdcons[request].run(uj, message, data.mt, interaction, fn)
		db.save_user(message._author.id)
		db.uncache_user(message._author.id)
	end

	if response == "no" then
		print('user has denied')
		interaction:reply(formatstring(lang.denied_message, { consdb[data.crequest].name }))
	end
end

return reaction
