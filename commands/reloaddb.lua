local command = {}
function command.run(message, mt, overwrite)
  local authcheck

  if overwrite then
    authcheck = true
  elseif message.guild then
    authcheck = isauthoradmin(message)
  end

  if authcheck then
    print("authcheck passed")
    _G["privatestuff"] = dofile('privatestuff.lua')


    -- Lua implementation of PHP scandir function
    _G['scandir'] = function (directory)
      return fs.readdirSync(directory)
    end

    for i, v in ipairs(scandir("commands")) do
      if fs.existsSync("commands/"..v.."/") then
        for _, vrec in ipairs(scandir("commands/"..v)) do
          local filename = string.sub(vrec, 1, -5)
          cmd[v.."_"..filename] = dofile('commands/' .. v.."/"..vrec)
        end
      else
        local filename = string.sub(v, 1, -5)
        cmd[filename] = dofile('commands/' .. v)
      end
    end
    print("done loading commands")

    for i, v in ipairs(scandir("reactions")) do
      local filename = string.sub(v, 1, -5)
      cmdre[filename] = dofile('reactions/' .. v)
    end
    print("done loading reactions")

    for i, v in ipairs(scandir("consumables")) do
      local filename = string.sub(v, 1, -5)
      cmdcons[filename] = dofile('consumables/' .. v)
    end
    print("done loading consumables")

    for i, v in ipairs(scandir("data/tracery")) do
      local filename = string.sub(v, 1, -6)
      tr[filename] = dpf.loadtracery('data/tracery/' .. v)
    end
    print("done loading tracery")

    _G["embed_colors"] = { -- easy to add more: just put a new line!
      default =  {colorcode = 0x85c5ff, shortname = "default", fullname = "RDCards Blue"},
      red =      {colorcode = 0xff0000, shortname = "red", fullname = "Stylish Red"},
      orange =   {colorcode = 0xff8000, shortname = "orange", fullname = "Pretty Orange"},
      yellow =   {colorcode = 0xfcd68d, shortname = "yellow", fullname = "Light Yellow"},
      green =    {colorcode = 0x00ff88, shortname = "green", fullname = "Jade Green"},
      blue =     {colorcode = 0x33ccff, shortname = "blue", fullname = "Nice Blue"},
      purple =   {colorcode = 0x7c00bf, shortname = "purple", fullname = "Fun Purple"},
      pink =     {colorcode = 0xff00dc, shortname = "pink", fullname = "Hot Pink"},
      brown =    {colorcode = 0x481b1d, shortname = "brown", fullname = "Beans Brown"},
    }


    _G['defaultjson'] = {
      inventory = {},
      storage = {},
      consumables = {},
      medals = {},
      items = {nothing = true},
      equipped = "nothing",
      conspt = "none",
      lastpull = -24,
      lastprayer = -7,
      lastequip = -24,
      lastbox = -24,
      lastrob = 0,
      tokens = 0,
      embedc = 0x85c5ff,
      unlocked_colors = {
        default = true
      },
      -- themeoffers = {
      --   red = {},
      --   orange = {},
      --   yellow = {},
      --   green = {},
      --   blue = {},
      --   purple = {},
      --   pink = {},
      --   brown = {},
      -- },
      -- currentoffer = "",
      has_seen_tutorials = {
        pull = false,
        pray = false,
      },
      pronouns = {
        selection = "they",
        their = "their",
        them = "them",
        theirself = "themself",
        they = "they",
        theirs = "theirs"
      },
      lang = "en",
      room = 0,
      -- chickstats = {
      --   bodycolor = {255, 250, 0},
      --   eyecolor = {49, 49, 49},
      --   scleracolor = {248, 248, 248},
      --   beakcolor = {255, 128, 3},
      --   footcolor =  {255, 128, 3},
      --   headwear = "nothing",
      --   eyewear = "nothing",
      --   neckwear = "nothing",
      --   shoes = "nothing",
      --   others = {}
      -- }
    }

    _G["errorping"] = (config.errorping ~= nil)

    if config.prefix then
      _G["prefix"] = config.prefix
    end

    _G['defaultworldsave'] = {
      tokensdonated = 0,
      boxpool = {"ssss45", "roomsdc_ur", "roomsdc_r", "underworld", "enchantedlove", "wallclockur", "dogtor", "moai", "coolbird", "beanshopper", "cardboardworld", "acofoi", "rollermobster", "inimaur", "fhottour", "superstrongcavity", "soundsr", "pancakefever", "nicoleur", "feedthemachine", "retrofunky", "heartchickalt"},
      lablookindex = 0,
      lablooktext = "abcdefghijklmnopqrstuvwxyz",
      ws = 0,
    }

    _G['defaultshopsave'] = {
      lastrefresh = 0,
      stocknum = 0,
      consumables = {
        {
          name = "caffeinatedsoda",
          stock = 10,
          price = 5
        },
        {
          name = "lunarrocks",
          stock = 11,
          price = 4
        },
        {
          name = "fancyteaset",
          stock = 12,
          price = 3
        }
      },
      cards = {
        {
          name = "514",
          stock = 10,
          price = 3
        },
        {
          name = "samurair",
          stock = 10,
          price = 1
        },
        {
          name = "knowyou",
          stock = 10,
          price = 3
        },
        {
          name = "alienalien",
          stock = 10,
          price = 1
        },
      },
      item = "hardcandy",
      itemstock = 10,
      itemprice = 4
    }

    _G["rarities"] = {
      r = "Rare",
      sr = "Super Rare",
      ur = "Ultra Rare",
      dc = "Discontinued",
      alt = "Alternate",
      altr = "Alternate Rare",
      altsr = "Alternate Super Rare",
      altur = "Alternate Ultra Rare",
      dcr = "Discontinued Rare",
      dcsr = "Discontinued Super Rare",
      dcur = "Discontinued Ultra Rare",
      dcalt = "Discontinued Alternate",
      altalt = "Alternate Alternate",
      pico8 = "PICO-8",
      c = "Collector's"
    }
    _G["rarities_alternate"] = {"alt", "dcalt", "altalt", "altr", "altsr", "altur"}
    _G["starrating"] = {
      [1] = {"r", "pico8"},
      [2] = {"sr", "pico8"},
      [3] = {"ur"},
      [4] = {"alt", "dc"},
      [5] = {
        "alt", "dc", "dcr", "dcsr", "dcur",
        "dcalt", "altalt", "altr", "altsr", "altur"
      }
    }
    _G["rarities_invert"] = {}
    for k,v in pairs(rarities) do _G["rarities_invert"][v] = k end
--  _G["starrating_invert"] = {}
--  for k,v in pairs(starrating) do
--    for _, v2 in ipairs(v) do
--      _G["starrating_invert"][v2] = k
--    end
--  end
    _G["rarity_sell_prices"] = {
      r = 1,
      sr = 2,
      ur = 4,
      dc = {4, 6},
      alt = {4, 6},
      altr = {5, 8},
      altsr = {8, 10},
      altur = {13, 17},
      dcr = {5, 8},
      dcsr = {8, 10},
      dcur = {13, 17},
      dcalt = {8, 10},
      altalt = {8, 10},
      pico8 = 2,
    }

    _G['amtable'] = {
      pyrowmid = {"strange machine", "machine", "panda"},
      lab = {"mouse hole", "mouse", "mousehole", "peculiar box", "box", "peculiarbox", "terminal"},
      shop = {"shop", "rob"}
    }

    _G['amids'] = {}
    amids[0] = "pyrowmid"
    amids[1] = "lab"
    amids[3] = "shop"

    _G['automove'] = function(cr,r,message)
      print("automove")
      local uj = db.get_user(message._author.id)
      local reqroom = "none"
      for k,v in pairs(amtable) do
        for a,b in ipairs(v) do
          if b == r then
            print("trying to use something in " .. k)
            local has_already_been_there = false
            for amk, amv in pairs(amids) do
              if amv == k and uj.discovered_rooms[amk] then
                has_already_been_there = true
              end
            end
            if has_already_been_there then
              reqroom = k
            else
              return "undiscovered"
            end
          end
        end
      end
      if reqroom ~= amids[cr] and reqroom ~= "none" then
        return cmd.move.run(message,{reqroom},false)
      end
    end

    _G['botdebug'] = false

    _G['nopeeking'] = false

    print("loading cards")


    --_G['cdata'] = dpf.loadjson("data/cards.json", defaultjson)

    _G['cdata'] = {basemult = 4, groups = {}}

    _G['jsonfiles']	= {}

    for i, v in ipairs(scandir("data/cards")) do --TODO: replace with something that supports subdirectories
      if string.sub(v, -4, -1) == 'json' then
        --print('loading json '..v)
        local groupdata = dpf.loadjson("data/cards/"..v, defaultjson)
        local groupname = string.sub(v, 1, -6)
        jsonfiles[groupname] = groupdata
      end
    end

    _G['jsongroups'] = {}

    for k,v in pairs(jsonfiles) do
      if jsongroups[k] then
        print('adding existing')
        for _i,_v in ipairs(v.cards) do
          table.insert(jsongroups[k].cards, _v)
        end
      else
        jsongroups[k] = v
        print('adding new')
      end
    end

    for k,v in pairs(jsongroups) do
      print('added group '..k)
      table.insert(cdata.groups,v)
    end

    --dpf.savejson('outcards.json',cdata)

    print('loading itemdb')
    _G['itemdb'] = dpf.loadjson("data/items.json", defaultjson)

    print('loading accessorydb')
    _G['accessorydb'] = dpf.loadjson("data/accessories.json", defaultjson)

    --generate pull table
    _G['ptable'] = {}
    _G['seasontable'] = {}
    _G['cdb'] = {}
    _G['constable'] = {}
    _G['ptablenc'] = {}
    _G['constablenc'] = {}
    _G['rarcardtable'] = {}
    _G['rarcardtablenc'] = {}
    _G['starcardtable'] = {}
    _G['starcardtablenc'] = {}
    _G['weightedseasontable'] = {}
    local iterateitemdb = itemdb
    iterateitemdb["aboveur"] = {}
    iterateitemdb["quantummouse"] = {}
    iterateitemdb["oldfiles"] = {}
    -- iterateitemdb["pocketdimension"] = {}

    for k, q in pairs(iterateitemdb) do
      ptable[k] = {}
      constable[k] = {}
      ptablenc[k] = {}
      constablenc[k] = {}
      for i, v in ipairs(cdata.groups) do
        for w, x in ipairs(v.cards) do
          local cmult = 1
          if x.bonuses and x.bonuses[k] then
            cmult = 10 -- might tweak this??
            for y=1, (cdata.basemult * v.basechance * x.chance) do
              table.insert(constable[k],x.filename)
              if x.season <= 8 then
                  table.insert(constablenc[k],x.filename)
              end
            end
          end
          for y = 1, (cdata.basemult * v.basechance * x.chance * cmult) do
            table.insert(ptable[k],x.filename)
            if x.season <= 8 then
                table.insert(ptablenc[k],x.filename)
            end
          end
          if k == "quantummouse" and (x.type == "Rare" or x.type == "PICO-8" or x.type == "Super Rare" or x.type == "Ultra Rare") then
            for y = 1, (cdata.basemult * v.basechance * x.chance) do
              table.insert(constable[k],x.filename)
              if x.season <= 8 then
                  table.insert(constablenc[k],x.filename)
              end
            end
          end
        end
      end
    end

    for i, v in ipairs(cdata.groups) do
      for w, x in ipairs(v.cards) do
        cdb[x.filename] = x
        cdb[x.filename]["basechance"] = v.basechance
        if not seasontable[x.season] then
          print("making season "..x.season)
          seasontable[x.season] = {}
          weightedseasontable[x.season] = {}
        end
        if rarities_invert[x.type] then
          local rarity = rarities_invert[x.type]
          --local rating = starrating_invert[rarity]
          --print("Rating of "..rarity..": "..rating)
          if rarity and not rarcardtable[rarity] then
            print("making rarity "..rarity)
            rarcardtable[rarity] = {}
            rarcardtablenc[rarity] = {}
          end
          --if not starcardtable[rating] then
          --  print("making rating "..rating)
          --  starcardtable[rating] = {}
          --end
          table.insert(rarcardtable[rarity], x.filename)
          if x.season <= 8 then
            table.insert(rarcardtablenc[rarity], x.filename)
          end
          --table.insert(starcardtable[rating], x.filename)
          --if rating == 5 then -- is this a good idea?
          --  table.insert(constable["pocketdimension"], x.filename)
          --end
        else
          print("[ERROR] Card "..x.filename.." has invalid rarity: "..x.type)
        end
        table.insert(seasontable[x.season], x.filename)
        for y = 1, (cdata.basemult * v.basechance * x.chance) do
          table.insert(weightedseasontable[x.season], x.filename)
        end
      end
    end

    for i, v in pairs(starrating) do
      print("making rating "..i)
      starcardtable[i] = {}
      starcardtablenc[i] = {}
      for i2, v2 in pairs(v) do
        for _, v3 in ipairs(rarcardtable[v2]) do
          for y = 1, (cdata.basemult * cdb[v3].basechance * cdb[v3].chance) do
            table.insert (starcardtable[i], v3)
            if cdb[v3].season <= 8 then
              table.insert (starcardtablenc[i], v3)
            end
          end
        end
      end
    end

    constable["pocketdimension"] = {}
    constablenc["pocketdimension"] = {}

    for i,v in pairs(rarcardtable) do
      if (i:find("alt")) then
        for _, v2 in ipairs(v) do
          for y = 1, (cdata.basemult * cdb[v2].basechance * cdb[v2].chance) do
            table.insert (constable["pocketdimension"], v2)
            if cdb[v2].season <= 8 then
              table.insert (constablenc["pocketdimension"], v2)
            end
          end
        end
      end
    end

    -- print("here is cdb")
    -- print(inspect(cdb))
    -- print("here is seasontable")
    -- print(inspect(seasontable))
    -- print("here is ptable")
    -- print(inspect(ptable))

    print('loading consdb')
    _G['consdb'] = dpf.loadjson("data/consumables.json", defaultjson)

    print("making conspt")
    _G['conspt'] = {}
    for k,v in pairs(consdb) do
      for i=1,v.chance do
        table.insert(conspt,k)
      end
    end

    print("loading collector's info")
    _G['coll'] = dpf.loadjson("data/coll.json", defaultjson)

    print("loading medaldb")
    _G['medaldb'] = dpf.loadjson("data/medals.json", defaultjson)

    print('loading itemdb')
    _G['itemdb'] = dpf.loadjson("data/items.json", defaultjson)

    print("loading medal requires")
    _G['medalrequires'] = dofile("data/medalrequires.lua")

    _G['upgradeimages'] = {
      "https://cdn.discordapp.com/attachments/829197797789532181/838908505192661022/upgrade1.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838908506496958464/upgrade2.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838908508841836564/upgrade3.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838908510972280842/upgrade4.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838908513119109130/upgrade5.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838908515179036742/upgrade6.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838908517477253181/upgrade7.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838908519876263967/upgrade8.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838908522040918066/upgrade9.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838908524389203998/upgrade10.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838908548205379624/upgrade11.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838908558963376128/upgrade12.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838908564105723925/upgrade13.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838908567347003392/upgrade14.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838908570355236914/upgrade15.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838908575879135242/upgrade16.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838908579901734963/upgrade17.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838908584078999583/upgrade18.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838908589674332180/upgrade19.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838908616329265212/upgrade20.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838910126554742814/upgrade21.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838910145491894292/upgrade22.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/838910782556733511/upgrade23.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/849420890281345034/upgrade24.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/853044075704221716/upgrade25.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/853044088089215046/upgrade26.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/853044088164188180/upgrade27.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/853044089305563184/upgrade28.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/853044089003311105/upgrade29.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/853044859139784725/upgrade30.png"
    }

    _G['labimages'] = {
      "https://cdn.discordapp.com/attachments/829197797789532181/831907762081497118/lab0.png", --use embeds, they said
      "https://cdn.discordapp.com/attachments/829197797789532181/831907763076333588/lab1.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907764762574868/lab2.png", --it will be easy, they said
      "https://cdn.discordapp.com/attachments/829197797789532181/831907766682517544/lab3.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907771020214292/lab4.png", --i'm so sorry, dps
      "https://cdn.discordapp.com/attachments/829197797789532181/831907771716075632/lab5.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907773830791198/lab6.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907776657227816/lab7.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907779236724786/lab8.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907782151110656/lab9.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907809926316052/lab10.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907816570224700/lab11.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907820299485215/lab12.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907824485400626/lab13.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907829383823401/lab14.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907832977948712/lab15.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907838213357638/lab16.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907842084175872/lab17.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907846848380958/lab18.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907851671830538/lab19.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907856558194708/lab20.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907860207239168/lab21.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907864444534834/lab22.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907869049356338/lab23.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907874141765683/lab24.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907878990381076/lab25.png",
      "https://cdn.discordapp.com/attachments/829197797789532181/831907882618323015/lab26.png" --h
    }

    _G['letters'] = {
      " ",
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
      "g",
      "h",
      "i",
      "j",
      "k",
      "l",
      "m",
      "n",
      "o",
      "p",
      "q",
      "r",
      "s",
      "t",
      "u",
      "v",
      "w",
      "x",
      "y",
      "z"
    }

    print("loading functions")

    _G['trf'] = function (x,rep)
      if not rep then
        rep = {}
      end
      local t,d = tr[x]:flatten('#origin#')
      for k,v in pairs(rep) do
        t = string.gsub(t,"@"..k.."@", v)
      end
      return t
    end

    _G['getletterindex'] = function (x)
      print("finding letterindex of "..x)
      for i, v in ipairs(letters) do
        if v == x then
          return i
        end
      end
    end

    _G['resetclocks'] = function ()
      for i,v in ipairs(scandir("savedata")) do
        local cuj = dpf.loadjson("savedata/" .. v, defaultjson)
        if cuj.id and db.cache[cuj.id] then
    		db.save_user(cuj.id)
     		db.uncache_user(cuj.id)
        end
        if cuj.lastpull then
          cuj.lastpull = -24
          cuj.lastprayer = -24
          cuj.lastequip = -24
          cuj.lastbox = -24
        end
        if cuj.lastrefresh then
          cuj.lastrefresh = 0
        end
        dpf.savejson("savedata/" .. v, cuj)
      end
    end

    _G['nametofn'] = function (x)
      for i, v in pairs(cdb) do
        if string.lower(v.name) == string.lower(x) then
          return i
        end
      end
    end

    _G['texttofn'] = function (x)
      if nametofn(x) or cdb[string.lower(x)] then
        return nametofn(x) or string.lower(x)
      end
    end

    _G['medalnametofn'] = function (x)
      for k, v in pairs(medaldb) do
        if string.lower(v.name) == string.lower(x) then
          return k
        end
      end
    end

    _G['medaltexttofn'] = function (x)
      if medalnametofn(x) or medaldb[string.lower(x)] then
        return medalnametofn(x) or string.lower(x)
      end
    end

    _G['consnametofn'] = function (x)
      for k, v in pairs(consdb) do
        if string.lower(v.name) == string.lower(x) then
          return k
        end
      end
    end

    _G['constexttofn'] = function (x)
      if consnametofn(x) or consdb[string.lower(x)] then
        return consnametofn(x) or string.lower(x)
      end
    end

    _G['itemnametofn'] = function (x)
      for k, v in pairs(itemdb) do
        if string.lower(v.name) == string.lower(x) then
          return k
        end
      end
    end

    _G['itemtexttofn'] = function (x)
      if itemnametofn(x) or itemdb[string.lower(x)] then
        return itemnametofn(x) or string.lower(x)
      end
    end

    _G['usernametoid'] = function (x)
    for i,v in ipairs(scandir("savedata")) do
      local cuj = dpf.loadjson("savedata/"..v,defaultjson)
      if cuj.id then
        if cuj.id == x or ("<@!" .. cuj.id .. ">") == x or ("<@" .. cuj.id .. ">") == x then --prioritize id and mentions over nickname
          return cuj.id
        end
      end
      if cuj.names then
        for j,w in pairs(cuj.names) do
          if string.lower(j) == string.lower(x) then
            return cuj.id
          end
        end
      end
    end
    end

    _G['usernametojson'] = function (x)
      print(x)
      return "savedata/" .. usernametoid(x) .. ".json"
    end


    _G['commands'] = {}

    _G['addcommand'] = function(trigger,commandfunction, expectedargs,force,usebypass)
      local newcommand = {}
      newcommand.trigger = prefix .. trigger
      newcommand.commandfunction = commandfunction or cmd.ping
      newcommand.expectedargs = 0 or expectedargs
      newcommand.force = force
      newcommand.usebypass = usebypass

      table.insert(commands, newcommand)
    end

    addcommand("ping",cmd.ping)
    addcommand("help",cmd.help)
    addcommand("resetclock",cmd.resetclock)
    addcommand("uptime",cmd.uptime)
    addcommand("testcards",cmd.testcards)
    addcommand("pull",cmd.pull)
    addcommand("inventory",cmd.inventory)
    addcommand("inv",cmd.inventory)
    addcommand("give",cmd.give)
    addcommand("trade",cmd.trade)
    addcommand("store",cmd.store)
    addcommand("storage",cmd.storage)
    addcommand("reloaddb",cmd.reloaddb)
    addcommand("reloadconfig",cmd.reloadconfig)
    addcommand("medals",cmd.medals)
    addcommand("crash",cmd.crash)
    addcommand("showmedal",cmd.showmedal)
    addcommand("runlua",cmd.runlua)
    addcommand("generategive",cmd.generategive)
    addcommand("search",cmd.search)
    addcommand("tell",cmd.tell)
    addcommand("beans",cmd.beans)
    addcommand("nickname",cmd.nickname)
    addcommand("checkmedals",cmd.checkmedals)
    addcommand("pronouns",cmd.pronoun)
    addcommand("pronounlist",cmd.pronounlist)
    addcommand("pronounform",cmd.pronounform)
    addcommand("pronoun",cmd.pronoun)
    addcommand("pray",cmd.pray)
    addcommand("prat",cmd.prat)
    addcommand("look",cmd.look)
    addcommand("use",cmd.use)
    addcommand("smell",cmd.smell)
    addcommand("shred",cmd.shred)
    addcommand("items",cmd.items)
    addcommand("showitem",cmd.showitem)
    addcommand("equip",cmd.equip)
    addcommand("granttoken",cmd.granttoken)
    addcommand("machine",cmd.use,0,{"machine"})
    addcommand("name",cmd.nickname)
    addcommand("fullinventory",cmd.fullinventory)
    addcommand("fullinv",cmd.fullinventory)
    addcommand("fullstorage",cmd.fullstorage)
    addcommand("setworldstate",cmd.setworldstate)
    addcommand("setspecialuser",cmd.setspecialuser)
    addcommand("ladder",cmd.use,0,{"ladder"})
    addcommand("givetoken",cmd.givetoken)
    addcommand("skipprompts",cmd.skipprompts)
    addcommand("vipstest",cmd.vipstest)
    --addcommand("chick",cmd.chick)
    addcommand("move",cmd.move)
    addcommand("renamefile",cmd.renamefile)
    addcommand("getfile",cmd.getfile)
    addcommand("stats",cmd.use,0,{"terminal","stats"},true)
    addcommand("upgrade",cmd.use,0,{"terminal","upgrade"})
    addcommand("credits",cmd.use,0,{"terminal","credits"},true)
    addcommand("savedata",cmd.use,0,{"terminal","savedata"},true)
    addcommand("logs",cmd.use,0,{"terminal","logs"},true)
    addcommand("terminal",cmd.use,0,{"terminal"})
    addcommand("buy",cmd.use,0,{"shop"})
    addcommand("shop",cmd.use,0,{"shop"})
    addcommand("box",cmd.use,0,{"box"})
    addcommand("show",cmd.show)
    addcommand("p",cmd.pull)
    addcommand("b",cmd.use,0,{"box"})
    addcommand("throw",cmd.throw)
    addcommand("yeet",cmd.throw) --im a comedy genius
    addcommand("toss",cmd.throw) --suggested by axi
    addcommand("vipstest",cmd.vipstest,0)
    addcommand("catch",cmd.catch)
    addcommand("giveitem",cmd.giveitem)
    addcommand("prestige",cmd.prestige)
    addcommand("togglecheck",cmd.togglecheck)
    addcommand("togglecc",cmd.togglecc)
    addcommand("piss",cmd.use,0,{"terminal", "piss"},true)
    addcommand("language",cmd.language)
    addcommand("lang",cmd.language)
    addcommand("langlist",cmd.langlist)
    addcommand("rob",cmd.rob)
    addcommand("rtsitem",cmd.rtsitem)
    addcommand("embed", cmd.embed)
    addcommand("reloadslash", cmd.reloadslash)

    cmd.reloadslash.setup()

    _G['getitemthumb'] = function(item,cons)
      local cf = io.open("vips_out/cache/items/"..item..".png", "r")
      if not cf then --check if file exists
        print("caching thumb for ".. item)
        local dir = "items/"
        if cons then
          dir = "assets/consumables/"
        end
        print(dir..item..".png")
        local itemimg = vips.Image.new_from_file(dir..item..".png") -- load item image
        itemimg = itemimg:resize(0.15) --TODO: force nearest neighbor scaling?
        itemimg:write_to_file("vips_out/cache/items/"..item..".png")
        print("done cachin'")
      end
      return "vips_out/cache/items/"..item..".png"
    end

    _G['getcardthumb'] = function(card)
      local cf = io.open("vips_out/cache/cards/"..card..".png", "r")
      if not cf then --check if file exists
        print("caching thumb for " .. card)
        local check = io.open("card_images/"..card..".png")
        if not check then
          card = "none"
        end
        local cardimg = vips.Image.new_from_file("card_images/"..card..".png") -- load item image
        cardimg = cardimg:resize(96 / cardimg:height()) --TODO: force nearest neighbor scaling?
        cardimg:write_to_file("vips_out/cache/cards/"..card..".png")
        print("done cachin'")
      end
      return "vips_out/cache/cards/"..card..".png"
    end
    -- getitemthumb("decaf",true)
    -- getitemthumb("stainedgloves")
    -- getcardthumb("knowyou")

    _G['getshopimage'] = function()
      local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
      local osj = dpf.loadjson("vips_out/cache/shop/lastshop.json", {})

      if json.encode(sj) ~= json.encode(osj) then--holy shit why
        local darkener = vips.Image.new_from_file("assets/darkener.png")
        print("remaking shop")
        local base = vips.Image.new_from_file("assets/shop/base.png")
        local item = vips.Image.new_from_file(getitemthumb(sj.item))
        if sj.itemstock == 0 then
          item = item:Colourspace('b-w')
          item = item:composite2(darkener,"over")
        end
        base = base:composite2(item,"over",{x=900,y=420})
        for i,v in pairs(sj.consumables) do
          item = vips.Image.new_from_file(getitemthumb(v.name,true))
          if v.stock == 0 then
            item = item:Colourspace('b-w')
            item = item:composite2(darkener,"over")
          end
          base = base:composite2(item,"over",{x=260 + (i-1)*213 ,y=420})
          i = i + 1
        end
        local x = 0
        local y = 0
        for i,v in ipairs(sj.cards) do
          if i == 1 then
            x,y = 210,173
          elseif i == 2 then
            x,y = 330,173
          elseif i == 3 then
            x,y = 210,293
          elseif i == 4 then
            x,y = 330,293
          end

          local card = vips.Image.new_from_file(getcardthumb(v.name))
          if v.stock == 0 then
            card = card:Colourspace('b-w')
            card = card:composite2(darkener,"over")
          end
          base = base:composite2(card,"over",{x=x,y=y})
        end

        base:write_to_file("vips_out/shop.png")
        dpf.savejson("vips_out/cache/shop/lastshop.json", sj)
      else
        print("shop is already good")
      end
      return "vips_out/shop.png"
    end
    -- getshopimage()

    _G["colortablefromint"] = function(col)
      return {math.floor(col / (256*256))%256, math.floor(col/256)%256, col%256,255}
    end

    _G['getthemeofferimage'] = function(uj)
      print("remaking trade")
      local base = vips.Image.new_from_file("assets/terminal_trade.png")

      local cards = {"srtgoatr", "marvinr", "doctahr"}
      if uj.currentoffer then
        cards = uj.themeoffers[uj.currentoffer]
      end
      for index, value in ipairs(cards) do
        local yposition = 78+32*(index-1)
        local card = vips.Image.new_from_file(getcardthumb(value))
        card = card:resize(32/card:height())
        base = base:composite2(card, "over", {x=29,y=yposition})
        local text = vips.Image.text("<span foreground='white'>"..value.."</span>", {width=96, rgba=true, font="Departure Mono 11px"})
        base = base:composite2(text, "over", {x=64,y=yposition+10})
      end
      local offer_text = "theme :3"
      if uj.currentoffer == "_owo" then
        offer_text = "owo"
      end
      local text_img = vips.Image.text("<span foreground='white'>"..offer_text.."</span>", {width=96, rgba=true, font="Departure Mono 11px"})
      if uj.currentoffer ~= "_owo" then
        base = base:draw_rect(colortablefromint(embed_colors[uj.currentoffer].colorcode), 243, 88, 64, 32, {fill = true})
      end
      base = base:composite2(text_img, "over", {x=248,y=uj.currentoffer == "_owo" and 81 or 79})
      base:write_to_file("vips_out/terminal_trade.png")
      return "vips_out/terminal_trade.png"

    end

    _G['reload_theme_trade'] = function (uj)
      local themes_not_unlocked = {}
      for themename, themedata in pairs(embed_colors) do
        if not uj.unlocked_colors[themename] then
          themes_not_unlocked[#themes_not_unlocked+1] = themename
          print(" doesn't have ".. themename)
        else
          print(" has ".. themename)
        end
      end
      print(tostring(#themes_not_unlocked).." themes not unlocked")
      if not uj.hasengwish then
        themes_not_unlocked[#themes_not_unlocked+1] = "_owo"
      end
      if #themes_not_unlocked > 0 then
        uj.currentoffer = themes_not_unlocked[math.random(#themes_not_unlocked)]
      end
    end

    _G['setup_theme_offers'] = function(uj)
      -- Get all the themes you don't have
      local themes_not_unlocked = {}
      for themename, themedata in pairs(embed_colors) do
        if not uj.unlocked_colors[themename] then
          themes_not_unlocked[#themes_not_unlocked+1] = themename
          print(" doesn't have ".. themename)
        else
          print(" has ".. themename)
        end
      end
      print(tostring(#themes_not_unlocked).." themes not unlocked")
      if not uj.hasengwish then
        themes_not_unlocked[#themes_not_unlocked+1] = "_owo"
      end
      if not uj.themeoffers then
        uj.themeoffers = {}
      end
      for _, color in ipairs(themes_not_unlocked) do
        if not uj.themeoffers[color] then
          uj.themeoffers[color] = {}
          for i = 1, 3, 1 do
            uj.themeoffers[color][i] = ptable["nothing"][math.random(#ptable["nothing"])]
          end
        end
      end
      uj.currentoffer = themes_not_unlocked[math.random(#themes_not_unlocked)]
      return uj
    end

    _G['formatstring'] = function (baseString, objectsToAdd, plural_s)
      -- Replace the base {X}
      local output = baseString or "[NO STRING PLEASE REPORT]"

      -- print(output)

      for key, value in pairs(objectsToAdd) do
        output = output:gsub("{"..tostring(key).."}",tostring(value))
      end


      -- Replace the {Xs}
      if plural_s ~= nil and plural_s ~= "" then
        for key, value in pairs(objectsToAdd) do
          if type(value) == "number" and value ~= 1 then
            output = output:gsub("{"..tostring(key).."s}",plural_s)
          else
            output = output:gsub("{"..tostring(key).."s}","")
          end
        end
      end


      return output
    end

    _G['formattime'] = function (minutesleft, langcode)
      -- i have unjankified it (lying)
      local lang = dpf.loadjson("langs/" .. langcode .. "/pull.json", "")
      local durationtext = ""
      if math.floor(minutesleft / 60) > 0 then
        durationtext = math.floor(minutesleft / 60) .. lang.time_hour
          if lang.needs_plural_s == true then
            if math.floor(minutesleft / 60) ~= 1 then
              durationtext = durationtext .. lang.time_plural_s
            end
          end
      end
      if minutesleft % 60 > 0 then
        if durationtext ~= "" then
          durationtext = durationtext .. lang.time_and
        end
        durationtext = durationtext .. minutesleft % 60 .. lang.time_minute
        if lang.needs_plural_s == true then
          if minutesleft % 60 ~= 1 then
            durationtext = durationtext .. lang.time_plural_s
          end
        end
      end
      return durationtext
    end


    _G['clearcache'] = function()
      os.remove("test.txt")
      print("deleting card cache")
      for i, v in ipairs(scandir("vips_out/cache/cards")) do
        local status, err = os.remove("vips_out/cache/cards/" .. v)
        if not status then
          print(err)
        end
      end

      print("deleting item cache")
      for i, v in ipairs(scandir("vips_out/cache/items")) do
        local status, err = os.remove("vips_out/cache/items/" .. v)
        if not status then
          print(err)
        end
      end
    end

    _G['checkforreload'] = function(days)
      local cooldown = config.shop.restock_delay
      print(days .. "days")
      local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
      if days >= sj.lastrefresh + cooldown then
        stockshop()
        sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
        sj.lastrefresh = cooldown * math.floor(days / cooldown)
        dpf.savejson("savedata/shop.json", sj)
      end
    end

    _G['stockshop'] = function()
      local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
      if not sj.stocknum then
        sj.stocknum = 0
      end
      local newcards = {{name="",stock=0,price=0},{name="",stock=0,price=0},{name="",stock=0,price=0},{name="",stock=0,price=0}}
      for i,v in ipairs(sj.cards) do--------------------cards
        print("stocking" .. i)
        local finding = true
        local nc = ""
        while finding do
          nc = ptable.nothing[math.random(#ptable.nothing)]
          print(nc)
          local new = true
          for w,x in ipairs(newcards) do
            if x.name == nc then
              new = false
            end
          end
          if new == true then
            finding = false
          end
        end
        local price = 8
        local rarity = cdb[nc].type
        local expected_price = rarity_sell_prices[rarities_invert[rarity]]
        if type(expected_price) == "number" then -- Fixed rarity price
          price = expected_price
        elseif type(expected_price) == "table" and #expected_price == 2 then -- Variable rarity price
          price = math.random(expected_price[1], expected_price[2])
        end

        local stock = cdb[nc].chance * 4 + math.random(2, 5)

        if cdb[nc].season == #seasontable then
          stock = stock + math.random(4, 8)
        elseif cdb[nc].season > #seasontable - 3 then
          stock = stock + math.random(2, 4)
        end

        newcards[i] = {name = nc,stock = stock, price = price}
        sj.cards = newcards
      end
      ---------------------------------------------item

      local itempt = {}
      for k in pairs(itemdb) do
        if k ~= "fixedmouse" and k ~= "nothing" then
          table.insert(itempt, k)
        end
      end
      sj.item = itempt[math.random(#itempt)]
      sj.itemstock = math.random(4, 7)
      sj.itemprice = 4
      -----------------------consumables
      local newconsumables = {{name="",stock=0,price=0},{name="",stock=0,price=0},{name="",stock=0,price=0}}
      for i,v in ipairs(sj.consumables) do

        local finding = true
        local nc = ""
        while finding do
          nc = conspt[math.random(#conspt)]
          local new = true
          for w,x in ipairs(newconsumables) do
            if x.name == nc then
              new = false
            end
          end
          if new == true then
            finding = false
          end
        end

        newconsumables[i] = {name = nc,stock = consdb[nc].basestock + math.random(0, 4), price = consdb[nc].baseprice + math.random(-1,1)}

      end
      sj.consumables = newconsumables

      sj.stocknum = sj.stocknum + 1

      dpf.savejson("savedata/shop.json", sj)
    end

    _G['shophas'] = function (x)
      local sj = dpf.loadjson("savedata/shop.json", defaultshopsave)
      local found = false
      for i,v in ipairs(sj.consumables) do
        if v.name == x then
          found = true
        end
      end
      for i,v in ipairs(sj.cards) do
        if v.name == x then
          found = true
        end
      end
      if sj.item == x then
        found = true
      end
      return found
    end

    _G['tablelength'] = function(T)
      local count = 0
      for _ in pairs(T) do count = count + 1 end
      return count
    end

    print("getchickimage")
    _G['getchickimage'] = function (userid)
      local ujf = ("savedata/" .. userid .. ".json")
      local uj = dpf.loadjson(ujf, defaultjson)

      --getting all the body parts
      local chickbody = vips.Image.new_from_file("chick/chick_body.png")
      local chickeyes = vips.Image.new_from_file("chick/chick_eyes.png")
      local chicksclerae = vips.Image.new_from_file("chick/chick_sclerae.png")
      local chickbeak = vips.Image.new_from_file("chick/chick_beak.png")
      local chickfeet = vips.Image.new_from_file("chick/chick_feet.png")

      --coloring the body
      local cbodycolor = uj.chickstats.bodycolor
      chickbody = chickbody:colourspace("hsv") * { 0, 0, 1, 1 }
      chickbody = chickbody:colourspace("srgb") * { cbodycolor[1] / 255, cbodycolor[2] / 255, cbodycolor[3] / 255, 1 }

      --coloring the body parts
      local ceyecolor = uj.chickstats.eyecolor
      chickeyes = chickeyes * { ceyecolor[1] / 255, ceyecolor[2]/255, ceyecolor[3] / 255, 1 }

      local cscleracolor = uj.chickstats.scleracolor
      chicksclerae = chicksclerae * { cscleracolor[1] / 255, cscleracolor[2]/255, cscleracolor[3] / 255, 1 }

      local cbeakcolor = uj.chickstats.beakcolor
      chickbeak = chickbeak * { cbeakcolor[1] / 255, cbeakcolor[2]/255, cbeakcolor[3] / 255, 1 }

      local cfootcolor = uj.chickstats.footcolor
      chickfeet = chickfeet * { cfootcolor[1] / 255, cfootcolor[2]/255, cfootcolor[3] / 255, 1 }

      --combining the body parts
      local chickimg = chickbody:composite2(chickeyes, "over")
      chickimg = chickimg:composite2(chicksclerae, "over")
      chickimg = chickimg:composite2(chickbeak, "over")
      chickimg = chickimg:composite2(chickfeet, "over")


      --adding others (middle layer)
      if uj.chickstats.others and uj.chickstats.others ~= {} then
        for i,v in ipairs(uj.chickstats.others) do
          print("loading "..v)
          if accessorydb.other[v].layer == "middle" then
            if not accessorydb.other[v].replace then
              local otherimg = vips.Image.new_from_file("chick/accessories/" .. v .. ".png")
              if accessorydb.other[v].bodycolor then
                print("found bodycolor")

                local cbodycolor = uj.chickstats.bodycolor
                otherimg = otherimg:colourspace("hsv") * { 0, 0, 1, 1 }
                otherimg = otherimg:colourspace("srgb") * { cbodycolor[1] / 255, cbodycolor[2] / 255, cbodycolor[3] / 255, 1 }
              end
              if accessorydb.other[v].sclerae then
                print("found scl")
                local scleraelayer = vips.Image.new_from_file("chick/accessories/" .. v .. "_sclerae.png")
                scleraelayer = scleraelayer * { cscleracolor[1] / 255, cscleracolor[2]/255, cscleracolor[3] / 255, 1 }
                otherimg = otherimg:composite2(scleraelayer, "over")
              end
              if accessorydb.other[v].eyes then
                print("found eyes")
                local eyeslayer = vips.Image.new_from_file("chick/accessories/" .. v .. "_eyes.png")
                eyeslayer = eyeslayer * { ceyecolor[1] / 255, ceyecolor[2]/255, ceyecolor[3] / 255, 1 }
                otherimg = otherimg:composite2(eyeslayer, "over")
              end
              if accessorydb.other[v].legs then
                print("found legs")
                local legslayer = vips.Image.new_from_file("chick/accessories/" .. v .. "_legs.png")
                legslayer = legslayer * { cfootcolor[1] / 255, cfootcolor[2]/255, cfootcolor[3] / 255, 1 }
                otherimg = otherimg:composite2(legslayer, "over")
              end
              if accessorydb.other[v].uncolored then
                local uclayer = vips.Image.new_from_file("chick/accessories/" .. v .. "_uncolored.png")
                otherimg = otherimg:composite2(uclayer, "over")
              end
              chickimg = chickimg:composite2(otherimg, "over")
            else
              chickimg = vips.Image.new_from_file("chick/accessories/" .. v .. ".png")
              if accessorydb.other[v].bodycolor then
                print("found bodycolor")

                local cbodycolor = uj.chickstats.bodycolor
                chickimg = chickimg:colourspace("hsv") * { 0, 0, 1, 1 }
                chickimg = chickimg:colourspace("srgb") * { cbodycolor[1] / 255, cbodycolor[2] / 255, cbodycolor[3] / 255, 1 }
              end
            end
          end
        end
      end

      --adding headwear
      if (uj.chickstats.headwear and uj.chickstats.headwear ~= "nothing") then
        local hatimg = vips.Image.new_from_file("chick/accessories/" .. uj.chickstats.headwear .. ".png")
        chickimg = chickimg:composite2(hatimg, "over")
      end

      --adding eyewear
      if (uj.chickstats.eyewear and uj.chickstats.eyewear ~= "nothing") then
        local glassesimg = vips.Image.new_from_file("chick/accessories/" .. uj.chickstats.eyewear .. ".png")
        chickimg = chickimg:composite2(glassesimg, "over")
      end

      --adding neckwear
      if (uj.chickstats.neckwear and uj.chickstats.neckwear ~= "nothing") then
        local neckimg = vips.Image.new_from_file("chick/accessories/" .. uj.chickstats.neckwear .. ".png")
        chickimg = chickimg:composite2(neckimg, "over")
      end

      --adding clothes
      if (uj.chickstats.clothes and uj.chickstats.clothes ~= "nothing") then
        local clothesimg = vips.Image.new_from_file("chick/accessories/" .. uj.chickstats.clothes .. ".png")
        chickimg = chickimg:composite2(clothesimg, "over")
      end

      --adding shoes
      if (uj.chickstats.shoes and uj.chickstats.shoes ~= "nothing") then
        local shoeimg = vips.Image.new_from_file("chick/accessories/" .. uj.chickstats.shoes .. ".png")
        chickimg = chickimg:composite2(shoeimg, "over")
      end

      --adding others (top layer)
      if uj.chickstats.others and uj.chickstats.others ~= {} then
        for i,v in ipairs(uj.chickstats.others) do
          if accessorydb.other[v].layer == "top" then
            local otherimg = vips.Image.new_from_file("chick/accessories/" .. v .. ".png")
            if accessorydb.other[v].bodycolor then
              print(accessorydb.other[v].uncoloredlayer)
              local cbodycolor = uj.chickstats.bodycolor
              otherimg = otherimg:colourspace("hsv") * { 0, 0, 1, 1 }
              otherimg = otherimg:colourspace("srgb") * { cbodycolor[1] / 255, cbodycolor[2] / 255, cbodycolor[3] / 255, 1 }
              if accessorydb.other[v].uncolored then
                local uclayer = vips.Image.new_from_file("chick/accessories/" .. v .. "_uncolored.png")
                otherimg = otherimg:composite2(uclayer, "over")
              end
            end
            chickimg = chickimg:composite2(otherimg, "over")
          end
        end
      end
      return chickimg
    end

    print("done loading")

    if not overwrite then
      message:reply('All commands have been reloaded.')
    end

  else
    message:reply('Sorry, but only moderators can use this command!')
  end
  --print(message.author.name .. " did !reloaddb")
end
return command
