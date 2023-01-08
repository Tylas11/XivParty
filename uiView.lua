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

-- windower library imports
local config = require('config')
local res = require('resources')

-- imports
local classes = require('classes')
local uiContainer = require('uiContainer')
local uiPartyList = require('uiPartyList')
local player = require('player')
local layoutDefaults = require('layout')
local const = require('const')
local utils = require('utils')

-- create the class, derive from uiContainer
local uiView = classes.class(uiContainer)

-- private functions
local function getLayoutFileNames(layoutName)
	local layoutFile = const.layoutDir .. layoutName .. const.xmlExtension
	local layoutAllianceFile = const.layoutDir .. layoutName .. const.layoutAllianceSuffix .. const.xmlExtension

	return layoutFile, layoutAllianceFile
end

local function checkLayout(layoutName)
	local layoutFile = getLayoutFileNames(layoutName)

	if not windower.file_exists(windower.addon_path .. layoutFile) then
		log('Layout \'' .. layoutName .. '\' not found. Reverting to default \'' .. const.defaultLayout .. '\'.')

		Settings.layout = const.defaultLayout
		Settings:save()
	end
end

local function loadLayout(layoutName)
	local layoutFile, layoutAllianceFile = getLayoutFileNames(layoutName)

	local layout = config.load(layoutFile, layoutDefaults)
	local layoutAlliance

	if windower.file_exists(windower.addon_path .. layoutAllianceFile) then
		layoutAlliance = config.load(layoutAllianceFile, layoutDefaults)
	else
		layoutAlliance = layout
	end

	return layout, layoutAlliance
end

function uiView:init(model)
	if not model then
		utils:log('uiView:init missing parameter model!', 4)
		return
	end

	if self.super:init() then
		self.partyLists = T{} -- UI elements for each party
		self.setupParties = T{} -- setup data for each party (a list of lists of players)
		self.isSetupEnabled = false

		self.lastPartyIndex = 2
		if Settings.hideAlliance then
			self.lastPartyIndex = 0
		end

		checkLayout(Settings.layout)
		self.layout, self.layoutAlliance = loadLayout(Settings.layout)

		for i = 0, self.lastPartyIndex do
			self.partyLists[i] = self:addChild(uiPartyList.new(
				i == 0 and self.layout.partyList or self.layoutAlliance.partyList, -- lua style ternary operator
				model.parties[i],
				i))
		end

		-- initialize UI, as there is no parent element to call these for us
		self:layoutElement()
		self:createPrimitives()
	end
end

function uiView:setupEnabled(enable)
	if not self.isEnabled then return end

	self.isSetupEnabled = enable

	for i = 0, self.lastPartyIndex do
		if enable and not self.setupParties[i] then
			self.setupParties[i] = self:createSetupData(i == 0)
		end
		self.partyLists[i]:setupEnabled(enable, self.setupParties[i])
	end
end

-- creates party and buffs for setup mode
function uiView:createSetupData(isMainParty)
	if not self.isEnabled then return end

	local setupParty = T{}

	for i = 0, 5 do
		local j = res.jobs[math.random(1,22)].ens
		local sj = res.jobs[math.random(1,22)].ens

		local setupPlayer = player.new('Player' .. tostring(i + 1), (i + 1), nil) -- model only needed for party leader lookup for trusts, can skip here
		setupPlayer:createSetupData(j, sj, isMainParty)
		setupParty[i] = setupPlayer
	end

	setupParty[0].isLeader = true
	setupParty[0].isAllianceLeader = true
	setupParty[0].isQuarterMaster = true

	-- NOTE: can't be both selected and out of zone, so range only 0-2
	setupParty[math.random(0,2)].isSelected = true

	-- set a zone that is not the current zone for one player, to show off the zone name display
	local zone = windower.ffxi.get_info().zone
	if zone == 0 then
		zone = zone + 1
	else
		zone = zone - 1
	end
	local outsideZonePlayer = setupParty[math.random(3,5)]
	outsideZonePlayer.zone = zone
	outsideZonePlayer.isOutsideZone = true

	return setupParty
end

function uiView:debugSaveLayout()
	if not self.isEnabled then return end

	self.layout:save()
	self.layoutAlliance:save();

	log('Layout saved.')
end

-- sets bar percentage values of selected setup party members
function uiView:debugSetupSetValue(type, value, partyIndex, playerIndex)
	if not self.isEnabled or not self.isSetupEnabled then return end
	if value == nil then value = 0 end
	if partyIndex == nil then partyIndex = 0 end
	if playerIndex == nil then playerIndex = 0 end

	if type == 'tpp' then
		self.setupParties[partyIndex][playerIndex].tpp = value
	elseif type == 'mpp' then
		self.setupParties[partyIndex][playerIndex].mpp = value
	else
		self.setupParties[partyIndex][playerIndex].hpp = value
	end
end

function uiView:debugAddPlayer(party)
	if not self.isEnabled or not self.isSetupEnabled then return end
	if not party then party = 0 end

	local setupParty = self.setupParties[party]
	local i = #setupParty + 1

	local j = res.jobs[math.random(1,22)].ens
	local sj = res.jobs[math.random(1,22)].ens

	local setupPlayer = player.new('Player' .. tostring(i + 1), (i + 1), nil) -- model only needed for party leader lookup for trusts, can skip here
	setupPlayer:createSetupData(j, sj, party == 0)
	setupParty[i] = setupPlayer
end

return uiView