local command = {}
function command.run(message, mt, asdf, content)
	print("c!runlua!!!!!")
	print(mt[1])
	if isauthoradmin(message) and (not content) then
		message:reply('Ok, running!')
		local request = table.concat(mt, "/")

		local status, err = pcall(function()
			_G["message"] = message
			_G["mt"] = mt
			_G["content"] = content
			local rfunc = assert(load(request))
			rfunc()
		end)

		_G["message"] = nil
		_G["mt"] = nil
		_G["content"] = nil

		if not status then
			message:reply('Oops! An error has occured. Error message: ```' .. err .. '```')
		else
			message:reply('Success!')
		end
	else
		message:reply('Sorry, but only moderators can use this command!')
	end
end

return command
