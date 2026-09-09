local command = {
	name = "settings",
	description = "Change your settings!"
}

function command.changed_toggle_cc(message, uj, component, newmessage, interaction)
	uj.disablecommunity = interaction.data.values[1] == "maestro"
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/togglecc.json", "")
	if uj.disablecommunity then
		interaction:reply(lang.disabled_message, true)
	else
		interaction:reply(lang.enabled_message, true)
	end
	for i, option in ipairs(component.options) do
		option.default = i == (uj.disablecommunity and 1 or 2)
	end
end

function command.changed_toggle_check(message, uj, component, newmessage, interaction)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/togglecheck.json", "")
	uj.togglecheckcard = interaction.data.values[1] == "yes"
	if not uj.togglecheckcard then
		interaction:reply(lang.card_disabled_message, true)
	else
		interaction:reply(lang.card_enabled_message, true)
	end
	for i, option in ipairs(component.options) do
		option.default = i == (uj.togglecheckcard and 1 or 2)
	end
end

function command.changed_skip_prompts(message, uj, component, newmessage, interaction)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/skipprompts.json", "")
	uj.skipprompts = interaction.data.values[1] == "yes"
	if uj.skipprompts then
		interaction:reply(lang.enabled_message, true)
	else
		interaction:reply(lang.disabled_message, true)
	end
	for i, option in ipairs(component.options) do
		option.default = i == (uj.skipprompts and 1 or 2)
	end
end

function command.run(message, mt)
	local uj = db.get_user(message._author.id)
	local togglecc = {
		type = 3,
		custom_id = "togglecc",
		options = {
			{
				label = "Maestro",
				value = "maestro",
				description = "Only seasons 1 to 8 can be pulled."
			},
			{
				label = "All cards",
				value = "all",
				description = "Cards from all seasons can be pulled."
			}
		}
	}

	local togglecheck = {
		type = 3,
		custom_id = "togglecheck",
		options = {
			{
				label = "Alert",
				value = "yes",
				description = "You will be alerted when you see a card not in your inventory."
			},
			{
				label = "Don't alert",
				value = "no",
				description = "You will not be alerted when you see a card not in your inventory."
			}
		}
	}
	local skipprompts = {
		type = 3,
		custom_id = "skipprompts",
		options = {
			{
				label = "Skip",
				value = "yes",
				description = "Yes/No prompts will be skipped."
			},
			{
				label = "Don't skip",
				value = "no",
				description = "Yes/No prompts will not be skipped."
			}
		}
	}

	for i, option in ipairs(togglecc.options) do
		option.default = i == (uj.disablecommunity and 1 or 2)
	end

	for i, option in ipairs(togglecheck.options) do
		option.default = i == (uj.togglecheckcard and 1 or 2)
	end

	for i, option in ipairs(skipprompts.options) do
		option.default = i == (uj.skipprompts and 1 or 2)
	end

	local components = {
		{
			type = 10,
			content = "# Settings",
		},
		{ type = 14 },
		{
			type = 10,
			content =
			"**Pull pool**\nRestricts the card pool to a specific season set\n-# This exclusively affects /pull."
		},
		{
			type = 1,
			components = { togglecc }
		},
		{ type = 14 },
		{
			type = 10,
			content =
			"**Alert new cards**\n Anytime a card not in your storage shows up (box, the shop), it will be indicated."
		},
		{
			type = 1,
			components = { togglecheck }
		},
		{ type = 14 },
		{
			type = 10,
			content =
			"**Skip prompts**\n Lets you skip most Yes/No prompts."
		},
		{
			type = 1,
			components = { skipprompts }
		},
	}

	local newmessage, err = message:replyComponents {
		flags = 32768, -- google IS_COMPONENTS_V2. holy hell.
		components = components
	}
	if err then print(err) end

	command.wait_for_component(message, newmessage, components)
end

command.custom_ids_to_functions = {
	togglecc = { 4, command.changed_toggle_cc },
	togglecheck = { 7, command.changed_toggle_check },
	skipprompts = { 10, command.changed_skip_prompts },
}

function command.wait_for_component(message, newmessage, components)
	local uj = db.get_user(message._author.id)
	local pressed, interaction = newmessage:waitComponent("selectMenu", nil, 1000 * 30, function(interaction)
		local reactionid = message._author.id

		if interaction.user.id ~= reactionid then
			local uj2 = db.get_user(interaction.user.id)
			local langfile2 = dpf.loadjson("langs/" .. uj2.lang .. "/ynbuttons.json", "")
			interaction:reply(langfile2.cannot_interact, true)
		end

		return interaction.user.id == reactionid
	end)

	if not pressed then
		print("Button timed out")
		components[4].components[1].disabled = true
		components[7].components[1].disabled = true
		components[10].components[1].disabled = true
		newmessage:update({ components = components })
		return
	end

	print(inspect(interaction.data))
	local comp_id, changed_func = table.unpack(command.custom_ids_to_functions[interaction.data.custom_id])
	changed_func(message, uj, components[comp_id].components[1], newmessage, interaction)
	newmessage:update({ components = components })
	db.save_user(message._author.id)

	command.wait_for_component(message, newmessage, components)
end

return command
