--[[
	author: Aussiemon
	
	-----
 
	Copyright 2022 Aussiemon

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

local locals = {}

-- Item Data --

locals.mod_item_rarity = "default"
locals.default_catalog_version = "1"
locals.default_purchase_date = "2018-03-08T00:00:00.132Z"
locals.default_remaining_uses = 1
locals.default_unit_price = 0

locals.backend_templates = {
	-- Cosmetic --
	skin = {
		CustomData = {}, -- List of Strings
	},
	hat = {
		CustomData = {}, -- List of Strings
	},
	frame = {
		CustomData = {}, -- List of Strings
	},
	weapon_skin = {
		CustomData = { -- List of Strings
			skin = nil, -- String
		},
		skin = "", -- String
	},
	-- Equipment --
	melee = {
		CustomData = { -- List of Strings
			power_level = nil, -- String
			properties = nil, -- String representation of list
			skin = nil, -- String
			traits = nil, -- String representation of array
		},
		power_level = "", -- Number
		properties = {}, -- List of Numbers
		skin = "", -- String
		traits = {}, -- Array of Strings
	},
	ranged = {
		CustomData = { -- List of Strings
			power_level = nil, -- String
			properties = nil, -- String representation of list
			skin = nil, -- String
			traits = nil, -- String representation of array
		},
		power_level = "", -- Number
		properties = {}, -- List of Numbers
		skin = "", -- String
		traits = {}, -- Array of Strings
	},
	necklace = {
		CustomData = { -- List of Strings
			power_level = nil, -- String
			properties = nil, -- String representation of list
			traits = nil, -- String representation of array
		},
		power_level = "", -- Number
		properties = {}, -- List of Numbers
		traits = {}, -- Array of Strings
	},
	ring = {
		CustomData = { -- List of Strings
			power_level = nil, -- String
			properties = nil, -- String representation of list
			traits = nil, -- String representation of array
		},
		power_level = "", -- Number
		properties = {}, -- List of Numbers
		traits = {}, -- Array of Strings
	},
	trinket = {
		CustomData = { -- List of Strings
			power_level = nil, -- String
			properties = nil, -- String representation of list
			traits = nil, -- String representation of array
		},
		power_level = "", -- Number
		properties = {}, -- List of Numbers
		traits = {}, -- Array of Strings
	},
	-- Miscellaneous --
	-- keep_decoration_painting = {
		-- CustomData = {}, -- List of Strings
	-- },
	-- crafting_material = {
		-- CustomData = {}, -- List of Strings
	-- },
	-- deed = {
		-- CustomData = { -- List of Strings
			-- difficulty = nil, -- String
			-- level_key = nil, -- String
		-- },
		-- difficulty = "", -- String
		-- level_key = "", -- String
	-- },
	-- loot_chest = {
		-- CustomData = {}, -- List of Strings
	-- },
}

-- Send back local variables
return locals