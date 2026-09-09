local command = {}

function command.use(message, uj, wj)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/use/pyrowmid/pyrowmid.json", "")
	if uj.tokens == nil then uj.tokens = 0 end
	if wj.ws >= 506 or wj.ws < 501 then
		message:reply(lang.hole_nodonations)
		return true
	end
	if uj.tokens > 0 then
		ynbuttons(message, {
			color = uj.embedc,
			title = lang.using_hole,
			description = formatstring(lang.use_hole, { uj.tokens }),
		}, "usehole", {}, uj.id, uj.lang)
		return true
	else
		message:reply(lang.hole_notokens)
	end
end
return command
