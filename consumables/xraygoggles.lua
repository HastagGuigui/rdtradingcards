local item = {}

function item.run(uj, message, mt, interaction)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/cons.json")
	if message.addReaction then
		message:addReaction("✅")
	else
		message:reply("-# ✅")
	end
	local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)
	local boxstring = ""
	for i, v in ipairs(table.sorted(wj.boxpool)) do
		local emoji = config.emojis.rarity[rarities_invert[cdb[v].type]]
		boxstring = boxstring .. emoji .. " **" .. cdb[v].name .. "**\n"
	end

	uj.consumables["xraygoggles"] = uj.consumables["xraygoggles"] - 1
	if uj.consumables["xraygoggles"] == 0 then uj.consumables["xraygoggles"] = nil end
	uj.timesitemused = uj.timesitemused and uj.timesitemused + 1 or 1

	if interaction then interaction:updateDeferred() end
	message.author:send {
		content = lang.xraygoggles_contains,
		embed = {
			title = lang.xraygoggles_title,
			description = boxstring,
			color = uj.embedc,
		}
	}
end

return item
