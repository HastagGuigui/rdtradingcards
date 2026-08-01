local command = {}
function command.run(message, mt)
  if mt[1] == "delete_existing" then
    -- gets a list of registered application commands from discord bot
    local commands = client:getGuildApplicationCommands(message.guild.id)
    -- deletes any existing application command from the bot's commands list
    for commandId in pairs(commands) do
      client:deleteGuildApplicationCommand(message.guild.id, commandId)
    end
  end

  for _, cmd_command in pairs(cmd) do
    if cmd_command.name then
      print(cmd_command.name)
      local slash_object = slash_tools.slashCommand(cmd_command.name, cmd_command.description)
      if cmd_command.options then
        for i, option in ipairs(cmd_command.options) do
          local opt = slash_tools.option()
          opt = opt:setType(option.type):setName(option.name):setDescription(option
            .description)
          if option.required ~= nil then opt = opt:setRequired(option.required) end
          if option.choices then
            for _, choice in option.choices do
              opt = opt:addChoice(slash_tools.choice(choice.name, choice.value))
            end
          end
          -- smth smth options
          if option.min_value ~= nil then opt = opt:setMinValue(option.min_value) end
          if option.max_value ~= nil then opt = opt:setMaxValue(option.max_value) end
          if option.min_length ~= nil then opt = opt:setMinLength(option.min_length) end
          if option.max_length ~= nil then opt = opt:setMaxLength(option.max_length) end
          if option.autocomplete then opt = opt:setAutocomplete(option.autocomplete) end
          slash_object:addOption(opt)
        end
      end
      client:createGuildApplicationCommand(message.guild.id, slash_object)
      cmdslash[cmd_command.name] = cmd_command
    end
  end
  print("/c isn't real hold on")
  local c_slash = slash_tools.slashCommand("c", "Run a regular text command as a slash command.")
  local c_slash_cmd = slash_tools.string("command", "The actual command"):setRequired(true)
  local c_slash_data = slash_tools.string("args", "Arguments (usually separated with /)")
  c_slash:addOption(c_slash_cmd)
  c_slash:addOption(c_slash_data)
  client:createGlobalApplicationCommand(c_slash)
  message:addReaction("✅")
end

return command
