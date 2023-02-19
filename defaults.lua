--[[
	Copyright © 2023, Tylas
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:

		* Redistributions of source code must retain the above copyright
		  notice, this list of conditions and the following disclaimer.
		* Redistributions in binary form must reproduce the above copyright
		  notice, this list of conditions and the following disclaimer in the
		  documentation and/or other materials provided with the distribution.
		* Neither the name of XivParty nor the
		  names of its contributors may be used to endorse or promote products
		  derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- imports
local const = require('const')

local defaults = {
	layout = const.defaultLayout, -- active UI layout, found in XivParty/layouts directory

	hideKeyCode = 207, -- DirectInput keyboard (DIK) code for holding down button to temporarily hide UI. set 0 to disable. default: "End" key
	hideSolo = false, -- hides the party list when you are not in a party
	hideAlliance = false, -- hides UI for alliance parties
	hideCutscene = true, -- hides UI during cutscenes or when talking to NPCs
	mouseTargeting = true, -- enables targeting party members using the mouse
	swapSingleAlliance = false, -- when only one alliance party exists, show the members in the 2nd alliance list

	rangeNumeric = false, -- enables numeric display of party member distances
	rangeIndicator = 0, -- if party members are closer than this distance, they will be marked. 0 = off
	rangeIndicatorFar = 0, -- a second distance for range indication, further away, displaying a hollow icon. 0 = off

	updateIntervalMsec = 30, -- the UI update interval in milliseconds, changing this will affect animation speeds and general performance

	party = {
		pos = L{ 0.015625, 0.4791666 }, -- relative coordinates, resolution independent (range 0.0 to 1.0)
		scale = L{ 0, 0 }, -- scale 0 will trigger screen resolution based autoscaling
		itemSpacing = 0, -- distance between party list items
		alignBottom = false, -- expands the party list from bottom to top
		showEmptyRows = false -- show empty rows in partially full parties
	},
	alliance1 = {
		pos = L{ 0.8671875, 0.5277777 },
		scale = L{ 0, 0 },
		itemSpacing = 0,
		alignBottom = false,
		showEmptyRows = false
	},
	alliance2 = {
		pos = L{ 0.8671875, 0.5972222 },
		scale = L{ 0, 0 },
		itemSpacing = 0,
		alignBottom = false,
		showEmptyRows = false
	},

	buffs = {
		filters = '', -- semicolon separated list of buff IDs to filter (e.g. '618;123;')
		filterMode = 'blacklist', -- 'blacklist' or 'whitelist', both use the same filter list
		customOrder = true -- sort buffs by a custom order defined in buffOrder.lua
	}
}

return defaults