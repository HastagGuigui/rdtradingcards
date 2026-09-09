local command = {
	name = "shop",
	description = "Show what's in the shop right now."
}
function command.run(message, mt)
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/look/shop.json")
	if (uj.unlocked_commands and uj.unlocked_commands.shop) or uj.room == 3 then
		if uj.room ~= 3 then
			cmd.move.run(message, { room_definitions[3].name }, false)
		end
		command.shop(message, mt, uj, lang)
	else
		message:reply(formatstring("You haven't discovered this yet! Try using {1} and {2} to find it.", {
			formatslash("look", message.guild.id), formatslash("move", message.guild.id),
		}))
	end
end

function command.shop(message, args, uj, lang)
	local time = sw:getTime()
	checkforreload(time:toDays())
	local showSeasons = false
	local dont_have_indicator = uj.togglecheckcard and " **[!!]**" or ""

	if args.season or args[#args] == "-season" then
		showSeasons = true
		-- table.remove(args, #args)
	end

	local base_embed = { -- Components V2
		type = 17,    -- Container
		accent_color = uj.embedc,
		components = {
			{ type = 10, content = "## " .. lang.looking_at_shop },
			{ type = 10, content = lang.looking_shop },
			{ type = 14 }
		}
	}

	local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)

	-- Cards
	local cardstr = "### " .. lang.shop_category_card .. "\n"
	for i, v in ipairs(sj.cards) do
		local tokentext = formatstring(lang.shop_token, { v.price }, lang.plural_s)
		local prefix = "\n> "
		local suffix = " (" .. tokentext .. ")"
		if not uj.storage[v.name] then
			suffix = suffix .. dont_have_indicator
		end
		if v.stock <= 0 then
			prefix = prefix .. "~~"
			suffix = suffix .. "~~"
		end
		cardstr = cardstr ..
			prefix .. format_card_line({ v.name, v.stock }, showSeasons, lang, { card = "UNKNOWN CARD" }):gsub("\n", "")
			.. suffix
	end
	base_embed.components[#base_embed.components + 1] = { type = 10, content = cardstr }
	base_embed.components[#base_embed.components + 1] = { type = 14, divider = false }

	-- Items
	local itemstr = "### " .. lang.shop_category_item .. "\n"
	for i, v in ipairs(sj.consumables) do
		local tokentext = formatstring(lang.shop_token, { v.price }, lang.plural_s)
		local prefix = "\n> "
		local suffix = "(" .. tokentext .. ")"
		if v.stock <= 0 then
			prefix = prefix .. "~~"
			suffix = suffix .. "~~"
		end
		itemstr = itemstr ..
			prefix .. format_consumable_line( v.name, v.stock ) .. " "
			.. suffix
	end

	local tokentext = formatstring(lang.shop_token, { sj.itemprice }, lang.plural_s)
	local prefix = sj.itemstock <= 0 and "\n > ~~" or "\n > "
	local suffix = sj.itemstock <= 0 and "~~" or ""
	if not uj.items[sj.item] then
		suffix = suffix .. dont_have_indicator
	end
	itemstr = itemstr ..
		prefix ..
		formatstring("{1} x{2} ({3})", { format_equippable_line(sj.item), sj.itemstock, tokentext }) .. suffix
	base_embed.components[#base_embed.components + 1] = { type = 10, content = itemstr }
	base_embed.components[#base_embed.components + 1] = {
		type = 12,
		items = { {
			media = { url = "attachment://shop.png" }
		} },
	}

	base_embed.components[#base_embed.components + 1] = {
		type = 10,
		content = "-# " .. formatstring(lang.checktoken, { uj.tokens }, lang.plural_s)
	}

	local file = getshopimage()
	local data, err = message:replyComponents({
		flags = 32768,
		components = { base_embed },
		files = { file }
	})

	if err then
		print(err)
	end
end

return command
