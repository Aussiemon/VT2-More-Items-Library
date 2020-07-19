--[[
	author: Aussiemon
	
	-----
 
	Copyright 2019 Aussiemon

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
	-----
	
	A library of functions to simplify working with mod items.
	
	Usage:
	
	- If the item is completely new, and does not yet have an ItemMasterList entry:
	
		1. Create a new table
		
		2. Fill that table with the relevant regular fields of an ItemMasterList entry
		
		3. Insert your new entry into an array
		
		4. Pass that array to mod.add_mod_items_to_masterlist()
		
		Your item now has an ItemMasterList and NetworkLookup entry. ANY COMPLETELY NEW ITEM WILL CURRENTLY CRASH LOBBY PLAYERS WHO DO NOT HAVE MATCHING ITEM LISTS.
		
	- When an item has an ItemMasterList entry, it can be added to your inventory:
	
		1. Use table.clone to copy the ItemMasterList entry
		
		2. Add a mod_data table to your entry copy (entry.mod_data = {})
		
		3. To this mod_data table, add any of the fields listed below in the backend_template for your item's slot_type. To look at your existing items for reference material, call the Vermintide Mod Framework's 'dtf' function on the return result of PlayFabMirror.get_all_inventory_items().
				
		4. Insert your new entry into an array
		
		5. Pass that array to mod.add_mod_items_to_local_backend() with your mod's name
		
		For example:
			local entry = table.clone(ItemMasterList["ring_06"])
			entry.mod_data = {
				backend_id = "something_unique",
				ItemInstanceId = "same as backend_id",
				CustomData = {
					traits = "[\"ring_potion_duration\"]",
					power_level = "300",
					properties = "{\"power_vs_skaven\":1,\"power_vs_unarmoured\":1}"
				},
				traits = {
					"ring_potion_duration"
				},
				power_level = 300,
				properties = {
					power_vs_unarmoured = 1,
					power_vs_skaven = 1,
				},
			}
			mod:add_mod_items_to_local_backend({entry}, "your mod name")
		
		Your item is now 'owned' for the game session, and will appear in item menus.
		
	-- When trying to remove items created by MoreItemsLibrary:
	
		1. Create a numerical array of backend_ids for removal (e.g. local items = { "one", "two", "three" })
		
		2. Pass that array to mod.remove_mod_items_from_local_backend() with your mod's name
--]]

local mod = get_mod("MoreItemsLibrary")


-- ##########################################################
-- ################## Variables #############################

-- Private Variables --

local general_data = mod:persistent_table("more_items_general_data")
local backend_mod_items = mod:persistent_table("backend_mod_items")
local new_masterlist_entries = mod:persistent_table("new_masterlist_entries")

local templates = mod:dofile("scripts/mods/MoreItemsLibrary/MoreItemsLibrary_templates")

local mod_item_rarity = templates.mod_item_rarity
local default_catalog_version = templates.default_catalog_version
local default_purchase_date = templates.default_purchase_date
local default_remaining_uses = templates.default_remaining_uses
local default_unit_price = templates.default_unit_price
local backend_templates = templates.backend_templates

local backend_mirror_hooked = false

local echo_header = "[More Items Library]: "

-- Optimization Locals --

local ItemMasterList = ItemMasterList
local Managers = Managers
local NetworkLookup = NetworkLookup
local PlayerUnitAttachmentExtension = PlayerUnitAttachmentExtension
local PlayFabMirror = PlayFabMirror

local pairs = pairs
local rawget = rawget
local table = table
local tostring = tostring


-- ##########################################################
-- ############## Utility Functions #########################

-- Add item to modded backend items:
--  item_id: string item id destination key in backend_mod_items
--  item: table of data and properties to add to backend_mod_items
local add_modded_item = function(item_id, item)
	backend_mod_items[item_id] = item
end

-- Remove item from modded backend items by id:
--  item_id: string item id of item in backend_mod_items
local remove_modded_item = function(item_id)
	local backend = Managers.backend
	local backend_item_interface = backend:get_interface("items")
	local career_names = backend_item_interface:equipped_by(item_id)

	if #career_names > 0 then
		return false
	end
	
	backend_mod_items[item_id] = false
	return true
end

-- Retrieve item from modded backend items by id:
--  item_id: string item id of item in backend_mod_items
local get_modded_item = function(item_id)
	return backend_mod_items[backend_id]
end

-- Retrieve the backend_ids of all modded items:
local get_modded_item_list = function()
	local backend_ids = {}
	local index = 1
	
	for key, val in pairs(backend_mod_items) do
		backend_ids[index] = key
		index = index + 1
	end
	
	return backend_ids
end

-- Refresh the list of backend items for menus and windows
local refresh_modded_items = function()
	local backend = Managers.backend
	local backend_item_interface = backend:get_interface("items")
	
	if backend_item_interface then
		backend_item_interface:make_dirty()
	end
end

-- Hooks the backend mirror instance stored at startup

local hook_backend_mirror = function()
	if backend_mirror_hooked then return end
	
	if general_data["backend_mirror_persisted"] then
		local backend_mirror = mod:persistent_table("backend_mirror_more_items")
		
		if backend_mirror and backend_mirror.get_all_inventory_items then
			mod:hook(backend_mirror, "get_all_inventory_items", function (func, ...)
				
				-- Original function
				local backend_items = func(...)
				
				-- Insert backend mod items
				for mod_backend_id, mod_backend_item in pairs(backend_mod_items) do
					if mod_backend_item == false then
						backend_mod_items[mod_backend_id] = nil
						backend_items[mod_backend_id] = nil
					else
						backend_items[mod_backend_id] = mod_backend_item
					end
				end
				
				-- Return backend items with mod additions
				return backend_items
			end)
			backend_mirror_hooked = true
		end
	end
end

-- CURRENTLY DEPRECATED:
-- Outputs complete table of backend items to your Vermintide game folder
-- File is located at '<game folder>/launcher/dump/owned_items.json' by default
local export_backend_items_to_file = function(self, export_name)
	local backend = Managers.backend
	local backend_item_interface = backend:get_interface("items")
	local backend_items = backend_item_interface:get_all_backend_items()
	
	mod:dtf(backend_items, export_name or "owned_items", 10)
end

mod:command("GetAllModItems", "Print list of More Items Library items", function()
	local items = get_modded_item_list()
	for i = 1, #items do
		if items[i] then
			mod:echo(items[i])
		end
	end
end)

--mod:command("RemoveModItems", "Remove all unequipped More Items Library items", function()
--	mod:remove_mod_items_from_local_backend(get_modded_item_list(), "USER")
--end)


-- ##########################################################
-- ################ Main Functions ##########################

-- Add new mod items to ItemMasterList:
--   items: list of item data entries
mod.add_mod_items_to_masterlist = function(self, items)
	local item_master_list_patch = items

	for item_num = 1, #item_master_list_patch do
		repeat
			local item = item_master_list_patch[item_num]
			
			-- Check for non-existent item or name
			if not item or not item.name then
				break
			end
			
			-- Check for existing ItemMasterList entry
			local item_name = item.name
			local already_exists = rawget(ItemMasterList, item_name)
			if already_exists then
				break
			end
			
			-- Add item to ItemMasterList
			ItemMasterList[item_name] = item
			
			-- Add item to tracked list of new masterlist entries
			new_masterlist_entries[item_name] = true
			
			-- Add item to NetworkLookup
			local item_name_index = #NetworkLookup.item_names + 1
			NetworkLookup.item_names[item_name_index] = item_name
			NetworkLookup.item_names[item_name] = item_name_index
			
			-- Add item to NetworkLookup damage sources
			local slot_type = item.slot_type
			if slot_type == "melee" or slot_type == "ranged" then
				local damage_source_index = #NetworkLookup.damage_sources + 1
				NetworkLookup.damage_sources[damage_source_index] = item_name
				NetworkLookup.damage_sources[item_name] = damage_source_index
			end
		until true
	end
	
	refresh_modded_items()
end

-- Add new mod items to local backend:
--   items: list of item data entries to add
--   mod_name: string name of the calling mod
mod.add_mod_items_to_local_backend = function(self, items, mod_name)
	
	-- Don't allow anonymous mods
	if not mod_name then
		mod:echo(echo_header .. "Unknown mod attempted to add items.")
		return
	end
	
	for item_num = 1, #items do
		repeat
			-- Skip if item does not exist
			local item = items[item_num]
			if not item then
				mod:echo(echo_header .. mod_name
						.. " tried to add a nil item.")
				break
			end
			
			-- Skip if item is not a known type
			local slot_type = item.slot_type
			if not slot_type or not backend_templates[slot_type] then
				mod:echo(echo_header .. mod_name
						.. " tried to add unknown item type "
						.. tostring(slot_type))
				break
			end
			
			-- Skip if item has no name
			local default_item_name = item.name
			if not default_item_name then
				mod:echo(echo_header .. mod_name
						.. " tried to add an item with no name.")
				break
			end
			
			-- Backendify item by template
			local backend_item = table.clone(backend_templates[slot_type])
			local mod_data = item.mod_data or {}
			
			-- Add template-specific fields if supplied
			for key, value in pairs(backend_item) do
				if mod_data[key] then
					backend_item[key] = mod_data[key]
				end
			end
			
			-- Set backend id for item
			local default_backend_id = mod_name .. "_" .. default_item_name
			
			backend_item.IsModItem = true
			backend_item.CreatedBy = mod_name
			
			backend_item.backend_id = mod_data.backend_id or default_backend_id
			backend_item.ItemInstanceId = mod_data.ItemInstanceId or default_backend_id
			
			-- Add backend values for normal fields
			backend_item.CatalogVersion = mod_data.CatalogVersion or default_catalog_version
			backend_item.PurchaseDate = mod_data.PurchaseDate or default_purchase_date
			backend_item.RemainingUses = mod_data.RemainingUses or default_remaining_uses
			backend_item.UnitPrice = mod_data.UnitPrice or default_unit_price
			
			backend_item.ItemId = mod_data.ItemId or item.key or default_item_name
			backend_item.key = mod_data.key or item.key or default_item_name
			
			-- Add item data to backend item
			backend_item.data = item
			
			-- All mod items should have default rarity to prevent salvage
			backend_item.CustomData.rarity = mod_item_rarity
			backend_item.rarity = mod_item_rarity
			
			-- Add mod item by backend_id, overwriting if already in use
			add_modded_item(backend_item.backend_id, backend_item)
		until true
	end
	
	refresh_modded_items()
end

-- Remove mod items from local backend:
--   items: list of mod-created backend item ids to remove (e.g. {"item1", "item2", "item3"})
--   mod_name: string name of the calling mod
mod.remove_mod_items_from_local_backend = function(self, items, mod_name)
	
	-- Don't allow anonymous mods
	if not mod_name then
		mod:echo(echo_header .. "Unknown mod attempted to remove items.")
		return
	end
	
	for item_num = 1, #items do
		repeat
			-- Skip if given a nil id
			local backend_id = items[item_num]
			if not backend_id then
				mod:echo(echo_header .. mod_name
						.. " tried to remove a nil item.")
				break
			end
			
			-- Setup mod item removal if it exists at the given backend_id
			remove_modded_item(backend_id)
		until true
	end
	
	refresh_modded_items()
end


-- ##########################################################
-- #################### Hooks ###############################

-- At every call to local backend, insert loaded mod items
--
-- Zero: Since it doesn't seem like we can reference PlayFabMirror directly, we'll run this once to get to its class so we can hook its functions
--          If it works, it works
mod:hook(BackendInterfaceItemPlayfab, "init", function (func, self, backend_mirror)
	mod:persistent_table("backend_mirror_more_items", backend_mirror)
	general_data["backend_mirror_persisted"] = true
	
	-- Hook the mirror now that we have it persisted
	hook_backend_mirror()
    
    return func(self, backend_mirror)
end)


-- ##########################################################
-- ################### Callback #############################

mod.on_game_state_changed = function()
	hook_backend_mirror()
end

mod.on_all_mods_loaded = function()
	hook_backend_mirror()
end

-- ##########################################################
-- ################### Script ###############################

-- ##########################################################
