local reaction = {}
function reaction.run(message, interaction, data, response)
  local curfilename = data.curfilename
  local numcards = data.numcards
  local ujf = "savedata/" .. message.author.id .. ".json"
  local uj = dpf.loadjson(ujf, defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/shred.json", "")
  print("Loaded uj")

  if response == "yes" then
    print('user1 has accepted')

    if not uj.inventory[curfilename] then
      interaction:reply(lang.reaction_dont_have)
      return
    end

    if uj.inventory[curfilename] < numcards then
      interaction:reply(formatstring(lang.reaction_not_enough, {cdb[curfilename].name}))
      return
    end

    print("Removing item1 from user1")
    uj.inventory[curfilename] = uj.inventory[curfilename] - numcards
    if uj.inventory[curfilename] == 0 then uj.inventory[curfilename] = nil end

    uj.timesshredded = uj.timesshredded and uj.timesshredded + numcards or numcards

    interaction:reply(formatstring(lang.shredded_message, {uj.id, uj.pronouns["their"], numcards, cdb[curfilename].name}, lang.plural_s))
    dpf.savejson(ujf, uj)
    cmd.checkmedals.run(message, {}, message.channel)
  end

  if response == "no" then
    print('user1 has denied')
    interaction:reply(formatstring(lang.denied_message, {uj.id, uj.pronouns["their"], cdb[curfilename].name}, lang.plural_s))
  end
end
return reaction
