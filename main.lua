-- ok i know ths code is hot stinky garbage but it *works*, god damn-it.

-- it works most of the time. most of the time.
_G["discordia"] = require('discordia')
require("discordia-components")
_G["slash_tools"] = require('discordia-slash').util.tools()
_G["client"] = discordia.Client():useApplicationCommands()
_G["prefix"] = "h!"
_G["json"] = require('libs/json')
_G["fs"] = require('fs')
--from https://github.com/DeltaF1/lua-tracery, TODO properly follow the license lmao
_G["tracery"] = require('libs/tracery')
_G["dpf"] = require('libs/dpf')
_G["inspect"] = require('libs/inspect')
_G["prosel"] = require('libs/prosel')
_G["vips"] = require('vips')
_G["http"] = require('coro-http')
require("libs/extra_functions") -- adds more to base classes

-- load all the extensions
discordia.extensions()

-- import all the commands
_G['cmd'] = {}
-- import reaction commands
_G['cmdre'] = {}
_G["cmdslash"] = {}

_G['cmdcons'] = {}

_G['tr'] = {}
_G['isauthoradmin'] = function(message)
  local cmember = message.guild:getMember(message.author ~= nil and message.author or message.user)
  if cmember:hasRole(privatestuff.modroleid) then return true end
  for _, id in ipairs(config.admins) do
    print(""..cmember.id.." = "..id)
    if cmember.id == id then return true end
  end
  return false
end

local rcf = dofile('commands/reloadconfig.lua')
rcf.run(nil,nil)
local rdb = dofile('commands/reloaddb.lua')
rdb.run(nil,nil,true)
print("exited rdb.run")

_G['sw'] = discordia.Stopwatch()
sw:start()

client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)
print("yay got past load ready")

client:on('messageCreate', function(message)
  handlemessage(message)
end)

client:on("slashCommand", function(interaction, command, args)
	print("slash command", interaction, command, args, handleslash)
    handleslash(interaction, command, args)
end)

-- for autocompletion
-- focused_option - option where focused = true

-- cmd.focused returns value directly
client:on("slashCommandAutocomplete", function(interaction, command, focused_option, args)
	print("autocomplete", interaction, command, focused_option, args, handle_autocomplete)
    handle_autocomplete(interaction, command, focused_option, args)
end)

print("Resetting clocks")
resetclocks()

print("Clearing cache")
clearcache()

print("Stocking shop")
stockshop()

client:run(privatestuff.botid)

client:setGame("with cards | "..config.prefix.."help")
