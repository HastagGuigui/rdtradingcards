local command = {
	name = "throw",
	description = "Throw a card, anyone can catch it!",
	options = {
		{
			name = "card",
			description = "The card to throw",
			type = 3,
			required = true,
			autocomplete = true,
		},
	}
}
function command.run(message, mt)
	local author = message.author or message.user
	print(author.name .. " did !throw")
	local uj = db.get_user(author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/throw.json", "")
	local kolang = dpf.loadjson("langs/ko/throw.json", "")
	local enlang = dpf.loadjson("langs/en/throw.json", "")

	local time = sw:getTime()
	local timeout = 20
	if not message.guild then
		message:reply(lang.dm_message)
		return
	end

	if not (#mt == 1) and not mt.card then
		message:reply(lang.no_arguments)
		return
	end

	local query = mt[1] or mt.card

	local cardfilename, consfilename = texttofn(query), constexttofn(query)
	local curfilename = cardfilename or consfilename

	if not (curfilename) then
		if nopeeking then
			message:reply(formatstring(lang.error_nopeeking, { query }))
		else
			message:reply(formatstring(lang.no_item, { query }))
		end
		return
	end

	local thrownname = cardfilename and cdb[cardfilename].name or consdb[consfilename].name

	if not (cardfilename and uj.inventory[cardfilename] or uj.consumables[consfilename]) then
		print("user doesnt have item")
		if nopeeking then
			message:reply(formatstring(lang.error_nopeeking, { query }))
		else
			message:reply(formatstring(lang.dont_have, { thrownname }))
		end
		return
	end

	local thrownstring = ""
	local koaction = { "던졌습니다", "발사했습니다", "날렸습니다", "퍼부었습니다", "상승시켰습니다", "뿅시켰습니다" }
	local kocaction = math.random(1, #koaction)
	local koplace = { "하늘로", "공중으로", "구름으로", "천국으로", "대기권으로", "우주로" }
	local kocplace = math.random(1, #koplace)
	local koitem = cardfilename and kolang.card_thrown or kolang.item_thrown
	local kotrfstring = message.author.mentionString ..
	"님이 " .. koplace[kocplace] .. " **" .. thrownname .. "** " .. koitem .. koaction[kocaction] .. "!"

	if uj.lang ~= "en" then
		if uj.lang == "ko" then
			thrownstring = kotrfstring .. formatstring(lang.thrown_message, { timeout })
		else
			thrownstring = trf("throw", { ping = message.author.mentionString, name = thrownname }) ..
			formatstring(lang.thrown_message, { timeout })
		end
		thrownstring = thrownstring ..
		trf("throw", { ping = message.author.mentionString, name = thrownname }) ..
		formatstring(enlang.thrown_message, { timeout })
	else
		thrownstring = trf("throw", { ping = message.author.mentionString, name = thrownname }) ..
		formatstring(lang.thrown_message, { timeout })
	end
	thrownstring = thrownstring .. formatstring(lang.thrown_command, { prefix, curfilename })

	message:reply(thrownstring)

	uj = dpf.loadjson("savedata/" .. message.author.id .. ".json", defaultjson)
	if cardfilename then
		uj.inventory[cardfilename] = uj.inventory[cardfilename] - 1
		if uj.inventory[cardfilename] == 0 then uj.inventory[cardfilename] = nil end
	else
		uj.consumables[consfilename] = uj.consumables[consfilename] - 1
		if uj.consumables[consfilename] == 0 then uj.consumables[consfilename] = nil end
	end
	uj.timesthrown = uj.timesthrown and uj.timesthrown + 1 or 1

	local tj = dpf.loadjson("savedata/thrown.json", {})
	if not tj[curfilename] then tj[curfilename] = { tostring(time:toHours()) } else table.insert(tj[curfilename],
			tostring(time:toHours())) end

	print("user had item, removed from original user")
	dpf.savejson("savedata/thrown.json", tj)

	if not client:waitFor(tostring(time:toHours()), timeout * 1000) then
		print((curfilename) .. " hasn't been caught!")
		tj = dpf.loadjson("savedata/thrown.json", {})
		uj = db.get_user(author.id)

		for x = #tj[curfilename], 1, -1 do
			if tj[curfilename][x] == tostring(time:toHours()) then
				table.remove(tj[curfilename], x)
				break
			end
		end

		if cardfilename then
			uj.inventory[cardfilename] = uj.inventory[cardfilename] and uj.inventory[cardfilename] + 1 or 1
		else
			uj.consumables[consfilename] = uj.consumables[consfilename] and uj.consumables[consfilename] + 1 or 1
		end

		if not next(tj[curfilename]) then tj[curfilename] = nil end
		db.save_user(author.id)
		dpf.savejson("savedata/thrown.json", tj)
		local kofall = { "떨어졌습니다. ", "충돌했습니다. ", "낙하했습니다. " }
		local kocfall = math.random(1, #kofall)
		local koground = { "지면으로 ", "바닥으로 ", "지구 상으로 " }
		local kocground = math.random(1, #koground)
		koitem = cardfilename and kolang.card_fall or kolang.item_fall
		kotrfstring = "**" .. thrownname .. "** " .. koitem .. koground[kocground] .. kofall[kocfall]
		local fallstring = ""
		if uj.lang ~= "en" then
			if uj.lang == "ko" then
				fallstring = kotrfstring ..
				formatstring(kolang.fall_message,
					{ message.author.mentionString, prosel.getPronoun("en", uj.pronouns["selection"], "their") })
				fallstring = fallstring ..
				"\n" ..
				trf("fall", { name = thrownname, item = cardfilename and enlang.card_fall or enlang.item_fall }) ..
				formatstring(enlang.fall_message,
					{ message.author.mentionString, prosel.getPronoun("en", uj.pronouns["selection"], "their") })
			else
				fallstring = trf("fall",
					{ name = thrownname, item = cardfilename and enlang.card_fall or enlang.item_fall }) ..
				formatstring(lang.fall_message,
					{ message.author.mentionString, prosel.getPronoun("en", uj.pronouns["selection"], "their") })
				fallstring = fallstring ..
				"\n" ..
				trf("fall", { name = thrownname, item = cardfilename and enlang.card_fall or enlang.item_fall }) ..
				formatstring(lang.fall_message,
					{ message.author.mentionString, prosel.getPronoun("en", uj.pronouns["selection"], "their") })
			end
		else
			fallstring = trf("fall", { name = thrownname, item = cardfilename and enlang.card_fall or lang.item_fall }) ..
			formatstring(enlang.fall_message,
				{ message.author.mentionString, prosel.getPronoun("en", uj.pronouns["selection"], "their") })
		end
		message:reply(fallstring)
	end
end

return command
