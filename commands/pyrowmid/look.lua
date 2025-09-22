local command = {}
function command.run(message, mt, uj, wj)
	local lang = dpf.loadjson("langs/" .. uj.lang .. "/look/pyrowmid.json", "")

	if string.lower(mt[1]) == "pyrowmid" or mt[1] == "" or mt[1] == lang.request_pyrowmid then
		if wj.ws < 501 then
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_pyrowmid,
				description = lang.looking_pre_501,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/829255814169493535/pyr7.png'
				}
			} }
		elseif wj.ws == 501 then
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_pyrowmid,
				description = lang.looking_501,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/831189023426478170/pyrhole.png'
				}
			} }
		elseif wj.ws == 502 then
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_pyrowmid,
				description = lang.looking_502,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/831191711917146183/pyrhole2.png'
				}
			} }
		elseif wj.ws == 503 then
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_pyrowmid,
				description = lang.looking_503,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/831192398524710982/pyrhole3.png'
				}
			} }
		elseif wj.ws == 504 then
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_pyrowmid,
				description = lang.looking_504,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/831263091470630922/pyrhole4.png'
				}
			} }
		elseif wj.ws == 505 then
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_pyrowmid,
				description = lang.looking_505,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/831223296112066560/pyrhole5.png'
				}
			} }
		elseif wj.ws == 506 then
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_pyrowmid,
				description = lang.looking_506,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/831225534834802769/pyrhole6.png'
				}
			} }
		else
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_pyrowmid,
				description = lang.looking_507,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/831291533915324436/pyrholefinal.png'
				}
			} }
		end
	elseif string.lower(mt[1]) == "panda" or string.lower(mt[1]) == "het" or (uj.lang ~= "en" and mt[1] == lang.request_panda) then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.looking_at_panda,
			description = lang.looking_panda,
		} }
	elseif string.lower(mt[1]) == "throne" or (uj.lang ~= "en" and mt[1] == lang.request_throne) then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.looking_at_throne,
			description = lang.looking_throne,
		} }
	elseif string.lower(mt[1]) == "strange machine" or string.lower(mt[1]) == "machine" or (uj.lang ~= "en" and mt[1] == lang.request_machine_1 or mt[1] == lang.request_machine_2 or mt[1] == lang.request_machine_3) then
		if wj.ws == 506 then
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_machine,
				description = lang.looking_machine_506,
			} }
		else
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_machine,
				description = lang.looking_machine,
			} }
		end
	elseif string.lower(mt[1]) == "hole" or (uj.lang ~= "en" and mt[1] == lang.request_hole) then
		if wj.ws < 501 then
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_hole,
				description = lang.looking_hole_pre_501,
			} }
		elseif wj.ws == 501 then
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_hole,
				description = lang.looking_hole_501,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/831507279975153754/holeclose.png'
				}
			} }
		elseif wj.ws == 502 then
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_hole,
				description = lang.looking_hole_502,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/831507280905633812/holeclose2.png'
				}
			} }
		elseif wj.ws == 503 then
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_hole,
				description = lang.looking_hole_503,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/831507281941495948/holeclose3.png'
				}
			} }
		elseif wj.ws == 504 then
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_hole,
				description = lang.looking_hole_504,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/831507283624198174/holeclose4.png'
				}
			} }
		elseif wj.ws == 505 then
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_hole,
				description = lang.looking_hole_505,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/831507285242150922/holeclose5.png'
				}
			} }
		elseif wj.ws == 506 then
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_hole,
				description = lang.looking_hole_506,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/831507288165449728/holeclose6.png'
				}
			} }
		else
			message.channel:send { embed = {
				color = uj.embedc,
				title = lang.looking_at_hole,
				description = lang.looking_hole_507,
				image = {
					url = 'https://cdn.discordapp.com/attachments/829197797789532181/831507279164997642/holeclosefinal.png'
				}
			} }
		end
	elseif (string.lower(mt[1]) == "ladder" or (uj.lang ~= "en" and mt[1] == lang.request_ladder)) and wj.labdiscovered then
		message.channel:send { embed = {
			color = uj.embedc,
			title = lang.looking_at_ladder,
			description = lang.looking_ladder,
			image = {
				url = 'https://cdn.discordapp.com/attachments/829197797789532181/831507279164997642/holeclosefinal.png'
			}
		} }
	else
		return false
	end
	return true
end

return command
