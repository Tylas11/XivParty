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
require('strings')

-- imports
local classes = require('classes')
local defaults = require('defaults')
local jobDefaults = require('jobdefaults')
local utils = require('utils')
local const = require('const')

-- create the class
local settings = classes.class()

local resX = windower.get_windower_settings().ui_x_res
local resY = windower.get_windower_settings().ui_y_res

function settings:init(model)
	self.model = model

	self.globalSettings = nil
	self.jobSettings = nil
	self.currentJob = ''

	self.jobEnabled = false -- also part of jobSettings and will be written to it
	self.buffFilters = T{} -- dictionary, key: buff ID, value: bool indicating whether to filter
end

-- copies settings from one table to another
-- schema defines which keys shall be copied
-- (optional) ignoreSchema defines which keys shall be skipped
local function copySettings(from, to, schema, ignoreSchema)
	for key, val in pairs(schema) do
		if not ignoreSchema or ignoreSchema[key] == nil then
			if type(from[key]) == 'table' then
				to[key] = table.copy(from[key])
			else
				to[key] = from[key]
			end
		end
	end
end

function settings:load(create, enable)
	local wasJobEnabled = self.jobEnabled

	self.globalSettings = config.load(defaults)
	self.jobSettings = nil
	self.jobEnabled = false

	copySettings(self.globalSettings, self, defaults)

	local job = windower.ffxi.get_player().main_job
	if job then
		local jobFilePath = const.dataDir .. string.lower(job) .. const.xmlExtension
		local fullJobFilePath = windower.addon_path .. jobFilePath

		local exists = windower.file_exists(fullJobFilePath)
		if create or exists then
			local js = config.load(jobFilePath, jobDefaults)

			if not js.jobEnabled and enable then
				js.jobEnabled = true
				js:save()
			end

			if js.jobEnabled then
				self.jobSettings = js
				self.jobEnabled = true
				self.currentJob = job

				if create and not exists then
					copySettings(self, self.jobSettings, jobDefaults) -- apply current global settings to new job file
					self.jobSettings:save()
					log('Created job settings for ' .. job .. ' and copied global settings.')
				else
					copySettings(self.jobSettings, self, jobDefaults) -- load job settings
					log('Loaded job settings for ' .. job .. '.')
				end
			end
		end
	end

	if wasJobEnabled and not self.jobEnabled then
		log('Global settings applied.')
	end

	self:loadFilters()
end

function settings:save()
	self:saveFilters()

	if self.jobSettings then
		copySettings(self, self.jobSettings, jobDefaults) -- copy only keys that are in job settings
		self.jobSettings:save()

		copySettings(self, self.globalSettings, defaults, jobDefaults) -- copy keys that are NOT in job settings
		self.globalSettings:save()
	else
		copySettings(self, self.globalSettings, defaults) -- copy all keys
		self.globalSettings:save()
	end
end

function settings:update()
	local player = windower.ffxi.get_player()
	if not player then return end

	if self.currentJob ~= player.main_job then
		self.currentJob = player.main_job

		self:load()
	end
end

function settings:loadFilters()
	self.buffFilters:clear()

	-- why use a custom CSV parser? because config.lua does not detect a list with a single element as a list >_>
	if self.buffs.filters ~= '' then
		for part in T(self.buffs.filters:split(';')):it() do
			local buffIdString = part:trim()
			if buffIdString ~= '' then
				self.buffFilters[tonumber(buffIdString)] = true
			end
		end
	end

	self.model:refreshFilteredBuffs()
end

function settings:saveFilters()
	self.buffs.filters = ''

	for buffId, doFilter in pairs(self.buffFilters) do
		-- why add a semicolon even on the first element? because config.lua will mistake a single element as a number and not a string
		self.buffs.filters = self.buffs.filters .. tostring(buffId) .. ';'
	end
end

function settings:getPartySettings(partyIndex)
	if partyIndex == 0 then return self.party end
	if partyIndex == 1 then return self.alliance1 end
	if partyIndex == 2 then return self.alliance2 end
end

function settings:partyIndexToName(partyIndex)
	if partyIndex == 0 then return 'main party' end
	if partyIndex == 1 then return 'alliance 1' end
	if partyIndex == 2 then return 'alliance 2' end
end

-- gets the UI position in screen coordinates
-- @param partyIndex 0 = main party, 1 = alliance1, 2 = alliance2
function settings:getUiPosition(partyIndex)
	local partySettings = self:getPartySettings(partyIndex)

	local pos = utils:coord(partySettings.pos)
	return { x = utils:round(pos.x * resX), y = utils:round(pos.y * resY) }
end

-- sets the UI position and stores them as relative coordinates
-- @param posX horizontal position in screen coordinates
-- @param posY vertical position in screen coordinates
-- @param partyIndex 0 = main party, 1 = alliance1, 2 = alliance2
function settings:setUiPosition(posX, posY, partyIndex)
	local partySettings = self:getPartySettings(partyIndex)

	partySettings.pos = L{ posX / resX, posY / resY }
end

-- gets the UI scale
-- @param partyIndex 0 = main party, 1 = alliance1, 2 = alliance2
function settings:getUiScale(partyIndex)
	local partySettings = self:getPartySettings(partyIndex)

	return utils:coord(partySettings.scale)
end

-- sets the UI scale
-- @param scaleX horizontal scale
-- @param scaleY vertical scale
-- @param partyIndex 0 = main party, 1 = alliance1, 2 = alliance2
function settings:setUiScale(scaleX, scaleY, partyIndex)
	local partySettings = self:getPartySettings(partyIndex)

	partySettings.scale = L{ scaleX, scaleY }
end

return settings