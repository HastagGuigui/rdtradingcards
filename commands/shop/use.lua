local command = {}

function command.wolf(message, mt, uj, lang)
	message:reply { embed = {
		color = uj.embedc,
		title = lang.petting_wolf,
		description = lang.petted_wolf,
		image = { url = "https://cdn.discordapp.com/attachments/829197797789532181/882289357128618034/petwolf.gif" }
	} }
end

function command.ghost(message, mt, uj, lang)
	message:reply { embed = {
		color = uj.embedc,
		title = lang.petting_ghost,
		description = lang.petted_ghost
	} }
end

function command.photo(message, mt, uj, lang)
	message:reply { embed = {
		color = uj.embedc,
		title = lang.petting_dog,
		description = lang.petted_dog,
		image = { url = "https://cdn.discordapp.com/attachments/829197797789532181/882287705638203443/okamii_triangle_frame_4.png" }
	} }
end

function command.run(message, mt)
	local time = sw:getTime()
	local uj = db.get_user(message._author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/shop/pet.json", "") -- fallback when request is not shop
	local wj = dpf.loadjson("savedata/worldsave.json", defaultworldsave)
	local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
	local request = mt[1] or mt.target

	if uj.lastrob + 4 > sj.stocknum and uj.lastrob ~= 0 then -- Can this even happen???
		lang = dpf.loadjson("langs/" .. uj.lang .. "/rob.json")
		local stocksleft = uj.lastrob + 4 - sj.stocknum
		local stockstring = formatstring(lang.more_restock, { stocksleft }, lang.plural_s)
		local minutesleft = math.ceil((26 / 24 - time:toDays() + sj.lastrefresh) * 24 * 60)

		local durationtext = formattime(minutesleft, uj.lang)
		if uj.lastrob + 3 == sj.stocknum then
			message:reply(formatstring(lang.blacklist_next, { durationtext }))
		else
			message:reply(formatstring(lang.blacklist, { stockstring, durationtext }))
		end
		return true
	end
	if request == "shop" or (uj.lang ~= "en" and request == lang.request_shop_1 or request == lang.request_shop_2 or request == lang.request_shop_3 or request == lang.request_shop_4) then
		-- for c!shop -season
		if mt[2] == "-season" then
			cmd.look.run(message, { "shop -season" })
		else
			cmd.shop_buy.buy(message, { name = mt[2], amount = mt[3] }, uj)
		end
		return true
	elseif request == "wolf" or (uj.lang ~= "en" and request == lang.request_wolf) then
		command.wolf(message, mt, uj, lang)
	elseif request == "ghost" or (uj.lang ~= "en" and request == lang.request_ghost) then
		command.ghost(message, mt, uj, lang)
	elseif request == "photo" or request == "dog" or (uj.lang ~= "en" and request == lang.request_photo or request == lang.request_dog) then
		command.photo(message, mt, uj, lang)
	else
		return false
	end
	return true
end

return command
