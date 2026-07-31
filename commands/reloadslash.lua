local command = {}
function command.run(message, mt)
    -- gets a list of registered application commands from discord bot
    local commands = client:getGuildApplicationCommands(message.guild.id)
    -- deletes any existing application command from the bot's commands list
    for commandId in pairs(commands) do
        client:deleteGuildApplicationCommand(message.guild.id, commandId)
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
                        for _,choice in option.choices do
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
    message:addReaction("✅")

    _G["handleslash"] = function(interaction, command, args)
        if cmdslash[command.name] then
            if args == nil then args = {} end
            local status, err = xpcall(function()
                cmdslash[command.name].run(interaction, args)
            end, debug.traceback)
            if not status then
                print("uh oh")
                if errorping then
                    interaction:reply("Oops! An error has occured! Error message: ```" ..
                    err .. "``` (" .. config.errorping .. " please fix this thanks)")
                else
                    interaction:reply("Oops! An error has occured! Error message: ```" ..
                    err .. "``` (please fix this thanks)")
                end
            end
        else
            interaction:reply("Command doesn't exist! This is bad. please report. ")
        end
    end
end

return command
