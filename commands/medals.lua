local command = {
	name = "medals",
	description = "Show your unlocked medals",
	options = {
		{
			name = "page",
			description = "Page of medals, just in case you have a lot of them.",
			type = 3,
			min_value = 1
		}
	}
}
function command.run(message, mt)
	local author = message.author or message.user
	print(author.name .. " did !medals")
	local uj = db.get_user(author.id)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/medals.json", "")

	local page_arg = mt[1] or mt.page
	local pagenumber = tonumber(page_arg) and math.floor(page_arg) or 1
	pagenumber = math.max(1, pagenumber)

	local nummedals = 0
	for k, v in pairs(uj.medals) do
		if v then nummedals = nummedals + 1 end
	end
	print("Number of medals is " .. nummedals)
	local maxpn = math.ceil(nummedals / 10)
	pagenumber = math.min(pagenumber, maxpn)

	print("Page number is " .. pagenumber)
	local medaltable = {}
	local medalstring = ''

	for k, v in pairs(uj.medals) do
		if v then table.insert(medaltable, "**" .. medaldb[k].name .. "**\n") end
	end
	table.sort(medaltable)

	for i = (pagenumber - 1) * 10 + 1, (pagenumber) * 10 do
		print(i)
		if medaltable[i] then medalstring = medalstring .. medaltable[i] end
	end

	message:reply {
		content = formatstring(lang.embed_contains, { author.mentionString }),
		embed = {
			color = uj.embedc,
			title = formatstring(lang.embed_title, { author.name }),
			description = medalstring,
			footer = {
				text = formatstring(lang.embed_page, { pagenumber, maxpn }),
				icon_url = author.avatarURL
			}
		}
	}
end

return command
