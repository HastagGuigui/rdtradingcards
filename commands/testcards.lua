local command = {}
function command.run(message, mt)
  if botdebug then
    message:reply('ok, testing. There are '.. table.count(cdb) ..' cards in the database.')
    print(message.author.name .. " did !testcards")
    for i,v in pairs(cdb) do
      local emb = v.embed or ""
	  if type(emb) == 'table' then
		emb = 'shade embed exception'
	  end
      message:reply {
        content = 'TESTCARDS: '.. v.name .. ' smells like ' .. cdb[v.filename].smell .. ', ' .. cdb[v.filename].description .. emb
      }
      message:reply{
        file = getcardthumb(v.filename)
      }
    end
  else
    message:reply('Not so fast, buckaroo.')
  end
end
return command
