--[[
	author: Aussiemon
	
	-----
 
	Copyright 2022 Aussiemon

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

local mod = get_mod("MoreItemsLibrary")

local mod_data = {
	name = "More Items Library",
	description = mod:localize("mod_description"),
	is_togglable = false,
	is_mutator = false,
	mutator_settings = {}
}

mod_data.options_widgets = {}

mod.every_career = {
	-- Bright Wizard
	"bw_adept",
	"bw_scholar",
	"bw_unchained",
	
	-- Wood Elf
	"we_waywatcher",
	"we_maidenguard",
	"we_shade",
	
	-- Dwarf Ranger
	"dr_ranger",
	"dr_ironbreaker",
	"dr_slayer",
	
	-- Witch Hunter
	"wh_captain",
	"wh_bountyhunter",
	"wh_zealot",
	
	-- Empire Soldier
	"es_mercenary",
	"es_huntsman",
	"es_knight"
}

mod.cosmetic_item_types = {
	skin = true,
	hat = true,
	frame = true,
	weapon_skin = true
}

return mod_data
