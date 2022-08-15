--[[
	Copyright © 2022, Tylas
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

local defaults = {}

defaults.layout = 'auto' -- active UI layout, found in XivParty/layouts directory. use 'auto' for automatic resolution based selection

defaults.party = {} -- TODO: meaningful default positions and comments here!
defaults.party.posX = 70
defaults.party.posY = 400
defaults.party.itemSpacing = 0 -- distance between party list items
defaults.party.alignBottom = false -- expands the party list from bottom to top
defaults.alliance1 = {}
defaults.alliance1.posX = 100
defaults.alliance1.posY = 600
defaults.alliance1.itemSpacing = 0 -- distance between party list items
defaults.alliance1.alignBottom = false -- expands the party list from bottom to top
defaults.alliance2 = {}
defaults.alliance2.posX = 130
defaults.alliance2.posY = 800
defaults.alliance2.itemSpacing = 0 -- distance between party list items
defaults.alliance2.alignBottom = false -- expands the party list from bottom to top

defaults.posX = 70 -- x screen position of the party list
defaults.posY = 400 -- y screen position of the party list

defaults.hideSolo = false -- hides the party list when you are not in a party
defaults.hideAlliance = false -- hides UI for alliance parties
defaults.hideCutscenes = true -- hides UI during cutscenes or when talking to NPCs

defaults.rangeIndicator = 0 -- if party members are closer than this distance, they will be marked. 0 = off
defaults.rangeIndicatorFar = 0 -- a second distance for range indication, further away, displaying a hollow icon. 0 = off

defaults.buffs = {}
defaults.buffs.filters = '' -- semicolon separated list of buff IDs to filter (e.g. '618;123;')
defaults.buffs.filterMode = 'blacklist' -- 'blacklist' or 'whitelist', both use the same filter list
defaults.buffs.customOrder = true -- sort buffs by a custom order defined in buffOrder.lua

return defaults