local command = {}
function command.perm_check(message)
  local cmember = message.guild:getMember(message.author)
  print("author is "..message.author.name.." and target role is "..config.rtsitemrole)
  if cmember:hasRole(config.rtsitemrole) then return true end
  return false
end
function command.run(message, mt)
  print(message.author.name .. " did !rtsitem")
  if not isauthoradmin(message) and not command.perm_check(message) then
    message:reply("haha no, nice try")
    return
  end



  local uj2f = usernametojson(mt[1])
  if not uj2f then
    message:reply("Sorry, but I could not find a user named " .. (mt[1] or "[NO NAME]") .. " in the database. Make sure that you have spelled it right, and that they have at least pulled a card to register!")
    return
  end

  local uj2 = dpf.loadjson(uj2f, defaultjson)

  local item = 'ratingform'
  local itemtype = 'cons'

  if mt[2] == 'granolabar' then
	item = 'granolabar'
	itemtype = 'cons'
  elseif mt[2] == 'hauntedgrass' then
	item = 'hauntedgrass'
	itemtype = 'cons'
  elseif mt[2] == 'sparecryopod' then
	item = 'sparecryopod'
	itemtype = 'item'
  elseif mt[2] == 'aceofhearts' then
	item = 'aceofhearts'
	itemtype = 'item'
  elseif mt[2] == 'subwayticket' then
	item = 'subwayticket'
	itemtype = 'cons'
  elseif mt[2] == 'ddd' then
	item = 'ddd'
	itemtype = 'cons'
  elseif mt[2] == 'oldfriend' then
	item = 'oldfriend'
	itemtype = 'item'
  elseif mt[2] == 'ratingform' then
  item = 'ratingform'
  itemtype = 'cons'
  end

  local numitems = 1


  if tonumber(mt[3]) then
    if tonumber(mt[3]) > 1 then numitems = math.floor(mt[3]) end
  end

  if item == 'subwayticket' then
	numitems = numitems * 3
  end

  if itemtype == 'cons' then
	if not uj2.consumables[item] then
	  uj2.consumables[item] = numitems
	else
	  uj2.consumables[item] = uj2.consumables[item] + numitems
	end
  else --non-consumable item
    uj2.items[item] = true
  end
  --add essence as well

  if item == 'subwayticket' then
	numitems = numitems / 3
  end

  if not uj2.consumables['essenceof'..item] then
	uj2.consumables['essenceof'..item] = numitems
  else
	uj2.consumables['essenceof'..item] = uj2.consumables['essenceof'..item] + numitems
  end


  dpf.savejson(uj2f,uj2)



  print("saved user2 json with new stuff")

  message:reply {
    content = 'You have given ' .. numitems .. ' rewards to <@' .. uj2.id .. '> .'
  }
end
return command
