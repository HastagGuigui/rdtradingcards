local command = {
    name = "equip",
    description = "Equip an item in your inventory.",
    options = {
        {
            name = "item",
            description = "The item to equip.",
            required = true,
            type = 4, -- STRING
            autocomplete = true
        }
    }
}
function command.run(message, mt)
    local author = message.author ~= nil and message.author or message.user
    local time = sw:getTime()
    local uj = db.get_user(author.id)
    local lang = dpf.loadjson("langs/" .. uj.lang .. "/equip.json", "")

    local request = nil
    if #mt == 1 then
        request = mt[1]
    elseif mt.item then
        request = mt.item
    end

    if request == nil then
        message:reply(lang.no_arguments)
        return
    end
    print(author.name .. " did !equip")
    print(string.sub(message.content, 0, 8))

    if not uj.equipped then
        uj.equipped = "nothing"
    end
    if not uj.items then
        uj.items = { nothing = true }
        uj.equipped = "nothing"
    end

    if not uj.lastequip then
        uj.lastequip = -24
    end

    if uj.lastequip + config.cooldowns.equip > time:toHours() then
        --extremely jank implementation, please make this cleaner if possible
        local minutesleft = math.ceil(uj.lastequip * 60 - time:toMinutes() + 360.00)
        local durationtext = formattime(minutesleft, uj.lang)
        message:reply(formatstring(lang.wait_message, { durationtext }))
        return
    end

    local curfilename = itemtexttofn(request)

    if not curfilename then
        if nopeeking then
            message:reply(formatstring(lang.nopeeking, { request }))
        else
            message:reply(formatstring(lang.nodatabase, { request }))
        end
        return
    end

    if not uj.items[curfilename] then
        if nopeeking then
            message:reply(formatstring(lang.nopeeking, { request }))
        else
            message:reply(formatstring(lang.donthave, { itemdb[curfilename].name }))
        end
        return
    end

    if uj.equipped == curfilename then
        message:reply(formatstring(lang.already_equipped, { itemdb[curfilename].name }))
        return
    end

    --woo hoo
    print(uj.equipped)
    if not uj.skipprompts then
        ynbuttons(message, formatstring(lang.prompt, { itemdb[uj.equipped].name, itemdb[curfilename].name }), "equip",
            { newequip = curfilename }, uj.id, uj.lang)
    else
        if uj.equipped == 'aceofhearts' then
            if uj.acepulls ~= 0 then
                message:reply('The pulls stored in your **Ace of Hearts** disappear...')
                uj.acepulls = 0
            end
        end
        uj.equipped = curfilename
        message:reply(formatstring(lang.equipped, { uj.id, itemdb[curfilename].name, uj.pronouns["their"] }))
        uj.lastequip = time:toHours()

        if uj.sodapt and uj.sodapt.equip then
            uj.lastequip = uj.lastequip + uj.sodapt.equip
            uj.sodapt.equip = nil
            if uj.sodapt == {} then uj.sodapt = nil end
        end

        print('saved equipped as ' .. curfilename)
    end
end

return command
