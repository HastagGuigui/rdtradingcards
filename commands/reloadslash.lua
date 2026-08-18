local command = {}

_G["formatslash"] = function(slash, guild)
	-- find corresponding slash command
	local commandid = ""
	local global_commands = client:getGlobalApplicationCommands()
	for cmd_id, cmd_obj in pairs(global_commands) do
		if cmd_obj.name == slash then
			commandid = cmd_id
			break
		end
	end
	if commandid == "" then
		local local_commands = client:getGuildApplicationCommands(guild)
		for cmd_id, cmd_obj in pairs(local_commands) do
			if cmd_obj.name == slash then
				commandid = cmd_id
				break
			end
		end
	end
	if commandid ~= "" then
		return "</" .. slash .. ":" .. commandid .. ">"
	end
	return "/" .. slash
end

function command.create_option(option)
	local opt = slash_tools.option()
	opt = opt:setType(option.type):setName(option.name):setDescription(option
		.description)
	if option.required ~= nil then opt = opt:setRequired(option.required) end
	if option.choices then
		for _, choice in ipairs(option.choices) do
			opt = opt:addChoice(slash_tools.choice(choice.name, choice.value))
		end
	end
	if option.options then
		for _, subopt in ipairs(option.options) do
			local newopt = command.create_option(subopt)
			opt:addOption(newopt)
		end
	end
	if option.min_value ~= nil then opt = opt:setMinValue(option.min_value) end
	if option.max_value ~= nil then opt = opt:setMaxValue(option.max_value) end
	if option.min_length ~= nil then opt = opt:setMinLength(option.min_length) end
	if option.max_length ~= nil then opt = opt:setMaxLength(option.max_length) end
	if option.autocomplete then opt = opt:setAutocomplete(option.autocomplete) end
	return opt
end

function command.setup()
	for _, cmd_command in pairs(cmd) do
		if cmd_command.name then
			cmdslash[cmd_command.name] = cmd_command
		end
	end
end

function command.run(message, mt)
	local is_interaction = message.author == nil
	if is_interaction then
		message:replyDeferred()
	end
	if mt[1] == "delete_existing" then
		-- gets a list of registered application commands from discord bot
		local commands = client:getGuildApplicationCommands(message.guild.id)
		-- deletes any existing application command from the bot's commands list
		for commandId in pairs(commands) do
			client:deleteGuildApplicationCommand(message.guild.id, commandId)
		end
	end

	local command_list = cmd
	if cmd[mt[1]] then
		command_list = { [mt[1]] = cmd[mt[1]] }
	end

	for _, cmd_command in pairs(command_list) do
		if cmd_command.name then
			print(cmd_command.name)
			local slash_object = slash_tools.slashCommand(cmd_command.name, cmd_command.description)
			if cmd_command.options then
				for i, option in ipairs(cmd_command.options) do
					local opt = command.create_option(option)
					slash_object:addOption(opt)
				end
			end
			-- print("object: " .. inspect(slash_object))
			client:createGuildApplicationCommand(message.guild.id, slash_object)
		end
	end
	print("/c isn't real hold on")
	local c_slash = slash_tools.slashCommand("c", "Run a regular text command as a slash command.")
	local c_slash_cmd = slash_tools.string("command", "The actual command"):setRequired(true)
	local c_slash_data = slash_tools.string("args", "Arguments (usually separated with /)")
	c_slash:addOption(c_slash_cmd)
	c_slash:addOption(c_slash_data)
	client:createGlobalApplicationCommand(c_slash)
	if not is_interaction then
		message:addReaction("✅")
	else
		message:reply("All slash commands reloaded.")
	end
end

return command
