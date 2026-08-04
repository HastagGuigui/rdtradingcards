local command = {
  name = "pronoun",
  description = "Set your pronouns",
  pronoun_list = { "they", "he", "she", "it", "xe", "sta", "ze", "vee" },
  options = {
    {
      name = "pronoun",
      type = 3, -- STRING
      description = "The pronoun you want to set for you",
      required = true,
      choices = {}
    },
  }
}

for _, pronoun in ipairs(command.pronoun_list) do
  command.options[1].choices[_] = {
    name = pronoun, value = pronoun
  }
end

function command.set_pronoun(uj, group)
  uj.pronouns = group
end

function command.run(message, mt)
  local author = message.author and message.author or message.user
  print(author.name .. " did !pronoun")
  local uj = db.get_user(author.id)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/pronoun.json", "")

  if not uj.pronouns then
    command.set_pronoun(uj, lang["they"])
  end

  local pronoun_exists = false
  for _, pronoun in ipairs(command.pronoun_list) do
    if pronoun == mt[1] or pronoun == mt.pronoun then
      command.set_pronoun(uj, lang[pronoun])
      pronoun_exists = true
      break
    end
  end

  if not pronoun_exists then
    if not mt[1] or mt[1] == "" then
      message:reply(lang.no_value)
      else
      message:reply(formatstring(lang.no_database, { mt[1] }))
    end
  end
end

return command
