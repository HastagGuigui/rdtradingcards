local command = {
    name = "inventory",
    description = "Shows all the cards in your inventory. Cards that are stored do not show up here.",
    options = {
        {
            name = "page",
            type = 4, -- INTEGER
            description = "Page Number (Every page shows 10 cards)",
            required = false,
            min_value = 0,
        },
        {
            name = "show-season",
            type = 5, -- BOOLEAN
            description = "Shows seasons on cards. (Default: false)",
            required = false
        },
        {
            name = "unstored-only",
            type = 5, -- BOOLEAN
            description = "Shows only cards that aren't present in storage. (Default: false)",
            required = false
        },
        {
            name = "season-filter",
            type = 3, -- STRING
            description = "In format \"1,2,3\". Also accepts 'maestro' as a shorthand for seasons 1 to 8.",
            required = false
        },
        {
            name = "rarity-filter",
            type = 3, -- STRING
            description =
            "In format \"sr,ur\". Rarity names are the ones used in card shorthands.",
            required = false
        }
    }
}
function command.run(message, mt)
    local author = message.author
    if not author then
        author = message.user
    end
    print(author.name .. " did !inventory")
    local uj = dpf.loadjson("savedata/" .. author.id .. ".json", defaultjson)
    local lang = dpf.loadjson("langs/" .. uj.lang .. "/inventory.json", "")
    local placeholder = dpf.loadjson("langs/" .. uj.lang .. "/look/missingcard.json", "")

    local enableShortNames = true
    local enableSeason = false

    local filterUnstored = false

    local filterSeasons = {}
    local filterSeasonsCount = 0
    local filterRarities = {}
    local filterRaritiesCount = 0

    local pagenumber = 1

    local args = {}
    if mt[1] then
        for substring in mt[1]:gmatch("%S+") do
            table.insert(args, substring)
        end
    elseif not next(mt) == nil then
        if mt.page then pagenumber = mt.page end
        if mt["show-season"] ~= nil then enableSeason = mt["show-season"] end
        if mt["unstored-only"] ~= nil then filterUnstored = mt["unstored-only"] end
        if mt["season-filter"] ~= nil then
            for substring in mt["season-filter"]:gmatch('([^,]+)') do
                table.insert(args, "-season"..substring)
            end
        end
        if mt["rarity-filter"] ~= nil then
            for substring in mt["rarity-filter"]:gmatch('([^,]+)') do
                table.insert(args, "-rarity"..substring)
            end
        end
    end

    for index, value in ipairs(args) do
        if tonumber(value) then
            pagenumber = math.floor(tonumber(value))
        elseif string.find(value, "-season") then
            if value == "-season" then
                enableSeason = true
                print("-season enabled")
            else
                local num = string.gsub(value, "-season", "") -- fuck you gsub
                local season = math.abs(tonumber(num))
                if season and season <= 11 then
                    filterSeasons[season] = true
                    filterSeasonsCount = filterSeasonsCount + 1
                    print("filtering for season " .. season)
                end
            end
        elseif string.find(value, "-rarity") then
            local rarity = string.gsub(value, "-rarity", "")
            if rarities[rarity] then
                filterRarities[rarity] = true
                filterRaritiesCount = filterRaritiesCount + 1
                print("filtering for rarity " .. rarity)
            end
        elseif value == "-unstored" then
            filterUnstored = true
        else
            local filename = usernametojson(value)
            if filename then
                uj = dpf.loadjson(filename, defaultjson)
            end
        end
    end

    local invtable = {}
    local invstring = ''
    local invfilter = uj.inventory

    if filterSeasonsCount > 0 then
        for k, v in pairs(invfilter) do
            if not filterSeasons[cdb[k] and cdb[k].season or -1] then
                invfilter[k] = nil
            end
        end
    end


    if filterRaritiesCount > 0 then
        for k, v in pairs(invfilter) do
            if not filterRarities[cdb[k] and cdb[k].type and rarities_invert[cdb[k].type] or "null"] then
                invfilter[k] = nil
            end
        end
    end

    if filterUnstored then
        for k, v in pairs(invfilter) do
            if uj.storage[k] and uj.storage[k] > 0 then
                invfilter[k] = nil
            end
        end
    end

    pagenumber = math.max(1, pagenumber)

    local numcards = tablelength(invfilter)

    local maxpn = math.ceil(numcards / 10)
    pagenumber = math.min(pagenumber, maxpn)
    print("Page number is " .. pagenumber)

    for k, v in pairs(invfilter) do
        table.insert(invtable,
            "**" .. (cdb[k] and cdb[k].name or placeholder.card) .. "** x" .. v ..
            (enableShortNames and (" `" .. k .. "` ") or "") ..
            (enableSeason and formatstring(lang.season, { cdb[k] and cdb[k].season or -1 }) or "")
            .. "\n"
        )
    end
    table.sort(invtable)

    for i = (pagenumber - 1) * 10 + 1, (pagenumber) * 10 do
        print(i)
        if invtable[i] then invstring = invstring .. invtable[i] end
    end

    local seasonnum = ""
    local raritytext = ""
    local multipleSeasons = filterSeasonsCount > 1
    local multipleRarities = filterRaritiesCount > 1

    for season, _ in pairs(filterSeasons) do
        if #seasonnum > 0 then seasonnum = seasonnum .. ", " end
        seasonnum = seasonnum .. tostring(season)
    end


    for rarity_short, _ in pairs(filterRarities) do
        if #raritytext > 0 then raritytext = raritytext .. ", " end
        raritytext = raritytext .. rarities[rarity_short]
    end

    local name = { next(uj.names) }
    local embedtitle = formatstring(lang.embed_title, { uj.id == author.id and author.name or name[1] })
    if filterSeasonsCount > 0 then
        local filtertitle = ""
        if multipleSeasons == true then
            if lang.needs_plural_s == true then
                filtertitle = lang.plural_s .. seasonnum
            else
                filtertitle = seasonnum
            end
        else
            filtertitle = seasonnum
        end
        if filterUnstored then filtertitle = filtertitle .. " (unstored)" end
        embedtitle = formatstring(lang.embed_title_season, { author.name, filtertitle })
    end

    message:reply {
        content = formatstring(lang.embed_contains, { uj.id == author.id and author.mentionString or name[1] }),
        embed = {
            color = uj.embedc,
            title = embedtitle,
            description = invstring,
            footer = {
                text = formatstring(lang.embed_page, { pagenumber, maxpn }),
                icon_url = author.avatarURL
            }
        }
    }
end

return command
