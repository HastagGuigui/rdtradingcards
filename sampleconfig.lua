local config = {
	prefix = "c!",                    -- prefix of every command
	errorping = "<@448560475987509268>", -- ping that happens when a crash occurs in a command
	admins = {                        -- discord IDs
		"448560475987509268"          -- default id is #Guigui, remove it if you're not #Guigui
	},
	cooldowns = {                     -- All values are in hours, besides pull_cryopod_max.
		pull = 11.5,                  -- c!p
		pull_stopwatch = 10,          -- c!p with Stopped Watch equipped
		pull_cryopod_max = 3,         -- In pull counts, the amount of pulls stored in the Spare Cryopod

		pray = 23,                    -- c!pray
		pray_necklace = 20,           -- c!pray with Faithful Necklace equipped

		box = 11.5,                   -- c!b
		box_gloves = 8,               -- c!b with Stained Gloves equipped

		equip = 6,                    -- c!equip
	},
	shop = {
		restock_delay = 26 / 24, -- in days

	},
	emojis = {
		-- stars used by Rate Your Experience Form
		star = ":star:",                              -- filled
		missingstar = "<:missingstar:1510309604603461762>", -- empty

		-- rarities
		-- defined here because every bot will have different IDs for emojis
		rarity = {
			-- You can define the emoji shown for every rarity here using its shorthand
			-- Example:
			--		r = "<:rare_icon:1538469427069059153>"
		}
	},
	rtsitemrole = "1041882546545369199"
}
-- You can reload the config at any time using c!reloadconfig.
return config
