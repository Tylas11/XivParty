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
local uiPartyList = require('uiPartyList')
local player = require('player')
local layoutDefaults = require('layout')
local const = require('const')
local utils = require('utils')

local view = {}

local isInitialized = false
local isSetupEnabled = false

local partyLists = T{} -- UI elements for each party
local setupParties = T{} -- setup data for each party (a list of lists of players)

local layout
local layoutAlliance

local lastPartyIndex

function view:init(model)
	if isInitialized then return end

	if not model then
		utils:log('view:init missing parameter model!', 4)
		return
	end

	if Settings.hideAlliance then
		lastPartyIndex = 0
	else
		lastPartyIndex = 2
	end

	self:checkLayout(Settings.layout)
	self:loadLayout(Settings.layout)

	for i = 0, lastPartyIndex do
		partyLists[i] = uiPartyList.new(
			model.parties[i],
			self:getSettingsByIndex(i),
			i == 0 and layout.partyList or layoutAlliance.partyList, -- lua style ternary operator
		    i == 0)
	end

	isInitialized = true
end

function view:dispose()
	if not isInitialized then return end

	for i = 0, lastPartyIndex do
		partyLists[i]:dispose()
	end
	setupParties:clear()
	partyLists:clear()

	isSetupEnabled = false
	isInitialized = false
end

local function getLayoutFileNames(layoutName)
	local layoutFile = const.layoutDir .. layoutName .. const.xmlExtension
	local layoutAllianceFile = const.layoutDir .. layoutName .. const.layoutAllianceSuffix .. const.xmlExtension

	return layoutFile, layoutAllianceFile
end

function view:checkLayout(layoutName)
	local layoutFile = getLayoutFileNames(layoutName)

	if not windower.file_exists(windower.addon_path .. layoutFile) then
		log('Layout \'' .. layoutName .. '\' not found. Reverting to default \'' .. const.defaultLayout .. '\'.')

		Settings.layout = const.defaultLayout
		Settings:save()
	end
end

function view:loadLayout(layoutName)
	local layoutFile, layoutAllianceFile = getLayoutFileNames(layoutName)

	layout = config.load(layoutFile, layoutDefaults)

	if windower.file_exists(windower.addon_path .. layoutAllianceFile) then
		layoutAlliance = config.load(layoutAllianceFile, layoutDefaults)
	else
		layoutAlliance = layout
	end
end

function view:getSettingsByIndex(index)
	if index == 0 then return Settings.party end
	if index == 1 then return Settings.alliance1 end
	if index == 2 then return Settings.alliance2 end

	utils:log('view:getSettingsByIndex: index ' .. tostring(index) .. 'not found!', 4)
	return nil
end

function view:setupEnabled(enable)
	if not isInitialized then return end
	if enable == nil then return isSetupEnabled end

	isSetupEnabled = enable

	for i = 0, lastPartyIndex do
		if enable and not setupParties[i] then
			setupParties[i] = self:createSetupData(i == 0)
		end
		partyLists[i]:setupEnabled(enable, setupParties[i])
	end
end

-- creates party and buffs for setup mode
function view:createSetupData(isMainParty)
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

function view:update(force)
	if not isInitialized then return end

	for i = 0, lastPartyIndex do
		partyLists[i]:update(force)
	end
end

function view:show(flagId)
	if not isInitialized then return end

	for i = 0, lastPartyIndex do
		partyLists[i]:show(flagId)
	end
end

function view:hide(flagId)
	if not isInitialized then return end

	for i = 0, lastPartyIndex do
		partyLists[i]:hide(flagId)
	end
end

function view:visible(isVisible, flagId)
	if not isInitialized then return end

	for i = 0, lastPartyIndex do
		partyLists[i]:visible(isVisible, flagId)
	end
end

function view:debugSaveLayout()
	if not isInitialized then return end

	layout:save()
	layoutAlliance:save();

	log('Layout saved.')
end

-- sets bar percentage values of selected setup party members
function view:debugSetupSetValue(type, value, partyIndex, playerIndex)
	if not isInitialized or not isSetupEnabled then return end
	if value == nil then value = 0 end
	if partyIndex == nil then partyIndex = 0 end
	if playerIndex == nil then playerIndex = 0 end

	if type == 'tpp' then
		setupParties[partyIndex][playerIndex].tpp = value
	elseif type == 'mpp' then
		setupParties[partyIndex][playerIndex].mpp = value
	else
		setupParties[partyIndex][playerIndex].hpp = value
	end
end

return view