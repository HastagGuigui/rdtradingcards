local command = {}
function command.run(message, mt)
	print("loading the resetclock command!")
	local cmember = message.guild:getMember(message._author)
	if cmember:hasRole(privatestuff.modroleid) then
		resetclocks()
		message:reply('All user cooldowns have been reset.')
	else
		message:reply('Sorry, but only moderators can use this command!')
	end
end

_G['resetclocks'] = function()
	for i, v in ipairs(scandir("savedata")) do
		local cuj = dpf.loadjson("savedata/" .. v, defaultjson)
		if cuj.id and db.cache[cuj.id] then
			db.save_user(cuj.id)
			db.uncache_user(cuj.id)
		end
		if cuj.lastpull then
			cuj.lastpull = -24
			cuj.lastprayer = -24
			cuj.lastequip = -24
			cuj.lastbox = -24
		end
		if cuj.lastrefresh then
			cuj.lastrefresh = 0
		end
		dpf.savejson("savedata/" .. v, cuj)
	end
end

return command
