local reaction = {}
function reaction.run(message, interaction, data, response)
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/lab/lab.json")
	print("Loaded uj")

	uj.timesused = uj.timesused and uj.timesused + 1 or 1
	db.save_user(message._author.id)

	if response == "yes" then
		print('user1 has accepted')
		interaction:reply { embed = {
			color = uj.embedc,
			title = lang.using_spider,
			description = lang.use_spider,
			image = {
				url = 'https://cdn.discordapp.com/attachments/829197797789532181/831930184482422824/spiderwave.png'
			}
		} }
	end

	if response == "no" then
		print('user1 has denied')
		interaction:reply { embed = {
			color = uj.embedc,
			title = lang.using_spiderweb,
			description = lang.use_spiderweb,
			image = {
				url = 'https://cdn.discordapp.com/attachments/829197797789532181/831930243249864704/hand.png'
			}
		} }
	end
end

return reaction
