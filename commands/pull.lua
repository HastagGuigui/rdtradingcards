local command = {
    name = "pull",
    description = "Lets you pull a card.",
}

function rand_from_table(tab)
    return tab[math.random(#tab)]
end

function command.run(message, mt)
    local time = sw:getTime()
    local author = message.author ~= nil and message.author or message.user
    print(author.name .. " did !pull")
    local uj = db.get_user(author.id)
    local lang = dpf.loadjson("langs/" .. uj.lang .. "/pull.json", "")

    if not message.guild then
        message:reply(lang.dm_message)
        return
    end

    local cooldown = config.cooldowns.pull

    if not uj.equipped then
        uj.equipped = "nothing"
    end

    if uj.equipped == "stoppedwatch" then
        cooldown = config.cooldowns.pull_stopwatch
    end

    if not uj.storedpulls then
        uj.storedpulls = 0
    end

    if not uj.acepulls then
        uj.acepulls = 0
    end

    local maxcryopodstorage = config.cooldowns.pull_cryopod_max


    if uj.equipped == "sparecryopod" then
        local missedpulls = math.floor((time:toHours() - math.max(uj.lastpull, uj.lastequip)) / cooldown) - 1
        if missedpulls > 0 then
            local resultmessage = formatstring(lang.cryopod_miss, { missedpulls })
            if uj.storedpulls == maxcryopodstorage then
                resultmessage = resultmessage .. formatstring(lang.cryopod_full, { maxcryopodstorage }) -- full!
            elseif missedpulls + uj.storedpulls > maxcryopodstorage then
                resultmessage = resultmessage .. formatstring(lang.cryopod_filled, {
                    (math.min(uj.storedpulls + missedpulls, maxcryopodstorage) - uj.storedpulls) -- formula for extra pulls
                })
            else
                resultmessage = resultmessage ..
                formatstring(lang.cryopod_partly, { missedpulls, uj.storedpulls + missedpulls })
            end
            message:reply(resultmessage)
            uj.storedpulls = math.min(uj.storedpulls + missedpulls, maxcryopodstorage)
        end
    elseif uj.storedpulls > 0 then
        uj.storedpulls = 0
    end

    if uj.lastpull + cooldown > time:toHours() then
        if uj.storedpulls > 0 then -- use a pull stored in the freezer (the spare cryopod)
            uj.storedpulls = uj.storedpulls - 1
            message:reply(formatstring(lang.cryopod_pull, { uj.storedpulls }, "s"))
        else
            local minutesleft = math.ceil(uj.lastpull * 60 - time:toMinutes() + cooldown * 60)
            local durationtext = formattime(minutesleft, uj.lang)

            message:reply(formatstring(lang.wait_message, { durationtext }))
            return
        end
    end

    if not uj.names then
        uj.names = {}
        uj.names[author.name .. "#" .. author.discriminator] = true
    end
    uj.id = author.id
    uj.lastpull = time:toHours()
    print(inspect(uj.names) .. " is/are the nickname/s")

    if uj.sodapt and uj.sodapt.pull then
        uj.lastpull = uj.lastpull + uj.sodapt.pull
        uj.sodapt.pull = nil
        if uj.sodapt == {} then uj.sodapt = nil end
    end

    message:reply(lang.pulling_card)

    local pulledcards = {}
    if uj.disablecommunity then
        pulledcards = { rand_from_table(ptablenc[uj.equipped]) }
    else
        pulledcards = { rand_from_table(ptable[uj.equipped]) }
    end

    if not uj.conspt then
        uj.conspt = "none"
    end
    if uj.conspt == "none" then
        if uj.equipped == "fixedmouse" and math.random(6) == 1 then
            if uj.disablecommunity then
                table.insert(pulledcards, rand_from_table(ptablenc[uj.equipped]))
            else
                table.insert(pulledcards, rand_from_table(ptable[uj.equipped]))
            end
            uj.timesdoubleclicked = uj.timesdoubleclicked and uj.timesdoubleclicked + 1 or 1
        end
    else
        -- Consumables that force a specific card(s):
        if uj.conspt == "sbubby" then
            pulledcards = { "sandwich" }
        elseif uj.conspt:sub(1, 6) == "season" then
            local season = tonumber(uj.conspt:sub(7)) or 0
            pulledcards = {}
            for _ = 1, 3 do -- todo: make that customizable!
                table.insert(pulledcards, rand_from_table(weightedseasontable[season]))
            end
        elseif uj.conspt:sub(1, 7) == "rarity_" then
            local rarity = uj.conspt:sub(8)
            if uj.disablecommunity then
                pulledcards = { rand_from_table(rarcardtablenc[rarity]) }
            else
                pulledcards = { rand_from_table(rarcardtable[rarity]) }
            end
        elseif uj.conspt:sub(1, 5) == "star_" then
            local star = tonumber(uj.conspt:sub(6))
            print("looking for a star of rating " .. star)
            if uj.disablecommunity then
                pulledcards = { rand_from_table(starcardtablenc[star]) }
            else
                pulledcards = { rand_from_table(starcardtable[star]) }
            end
        else
            if uj.disablecommunity then
                pulledcards = { rand_from_table(constablenc[uj.conspt]) }
            else
                pulledcards = { rand_from_table(constable[uj.conspt]) }
            end
        end

        -- Consumables that give extra cards:
        if uj.conspt == "quantummouse" then
            if uj.disablecommunity then
                table.insert(pulledcards, rand_from_table(constablenc["quantummouse"]))
            else
                table.insert(pulledcards, rand_from_table(constable["quantummouse"]))
            end

            if uj.equipped == "fixedmouse" and math.random(6) == 1 then
                if uj.disablecommunity then
                    table.insert(pulledcards, rand_from_table(constablenc["quantummouse"]))
                else
                    table.insert(pulledcards, rand_from_table(constable["quantummouse"]))
                end
                uj.timesdoubleclicked = uj.timesdoubleclicked and uj.timesdoubleclicked + 1 or 1
            end
        end
        uj.conspt = "none"
    end
    if forcepull ~= nil then
        pulledcards = { forcepull }
        forcepull = nil
    end
    for i, v in ipairs(pulledcards) do
        uj.inventory[v] = uj.inventory[v] and uj.inventory[v] + 1 or 1
        uj.timespulled = uj.timespulled and uj.timespulled + 1 or 1
        if uj.equipped == 'aceofhearts' then
            uj.acepulls = uj.acepulls + 1
        else
            uj.acepulls = 0
        end
    end

    local showacemessage = false

    if uj.acepulls >= 21 and uj.equipped == 'aceofhearts' then
        uj.acepulls = 0
        uj.tokens = uj.tokens + 10 or 10
        showacemessage = true
    end

    local show_tutorial_message = true
    if uj.has_seen_tutorials.pull then
        show_tutorial_message = false
    else
        uj.has_seen_tutorials.pull = true
    end

    for i, v in ipairs(pulledcards) do
        local cardname = cdb[v].name

        local title = lang.pulled_woah
        if uj.equipped == "okamiiscollar" then title = lang.pulled_woof end
        if v == "yor" or v == "yosr" or v == "your" then title = lang.pulled_yo end
        if i == 2 then title = lang.pulled_doubleclick end
        if i == 3 then title = lang.pulled_tripleclick end
        if v == "samarrrai" then title = "Ahoy Matey!" end

        local newstatus = formatstring("Inventory: {1} | Storage: {2}", { uj.inventory[v] or 0, uj.storage[v] or 0 })
        if not uj.storage[v] then
            newstatus = "[NEW CARD!]"
        end

        local footer = "Season " .. cdb[v].season .. " | " .. newstatus

        if v == "rdnot" then
            message:reply("```" ..
            title .. "\n@" .. formatstring(lang.rdnot_message, { author.name, uj.pronouns["their"] }) .. [[
_________________
| SR            |
|               |
|    \____/     |
|    / TT \  /  |
|   /|____|\/   |
|     l  l      |
|             𝅘𝅥𝅯 |
_________________```]] .. "\n" .. footer)
        elseif not cdb[v].spoiler then
            local msg = formatstring(lang.pulled_message,
                { author.mentionString, cardname, uj.pronouns["their"], v })
            message:reply { embed = {
                color = uj.embedc,
                title = title,
                description = msg,
                image = { url = type(cdb[v].embed) == "table" and cdb[v].embed[math.random(#cdb[v].embed)] or cdb[v].embed }, -- is this actually used for anything?
                footer = { text = footer }
            } }
        else
            print("spider moments")
            local msg = formatstring(lang.pulled_message,
                { author.mentionString, cardname, uj.pronouns["their"], v })
            message:reply {
                content = "**" .. title .. "**\n" .. msg,
                file = "card_images/SPOILER_" .. v .. ".png"
            }
            message:reply("-# " .. footer)
        end
        -- if not uj.togglecheckcard then
        --   if not uj.storage[v] then
        --     message:reply(formatstring(lang.not_in_storage, {cardname}))
        --   end
        -- end
    end
    if show_tutorial_message then
        message:reply(formatstring(lang.tutorial, { prefix }))
    end
    if showacemessage then
        message:reply(formatstring(lang.ace_of_hearts, { uj.pronouns['their'], uj.pronouns['they'] }))
    end
end

return command
