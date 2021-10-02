--[[
	Copyright © 2021, Tylas
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

local settings = {}

local defaults = require('defaults')
local jobDefaults = require('jobdefaults')

local globalSettings = nil
local jobSettings = nil
local currentJob = ''
local model = nil
local isInitialized = false

settings.jobEnabled = false -- also part of jobSettings and will be written to it
settings.buffFilters = T{} -- dictionary, key: buff ID, value: bool indicating whether to filter

function settings:init(md)
	model = md
	isInitialized = true
end

function settings:load(create, enable)
	local wasJobEnabled = settings.jobEnabled

	globalSettings = config.load(defaults)
	jobSettings = nil
	settings.jobEnabled = false
	
	self:copy(globalSettings, settings, defaults)
	
	local job = windower.ffxi.get_player().main_job
	if job then
		local jobFilePath = 'data/' .. string.lower(job) .. '.xml'
		local fullJobFilePath = windower.addon_path .. jobFilePath
		
		local exists = windower.file_exists(fullJobFilePath)
		if create or exists then
			local js = config.load(jobFilePath, jobDefaults)
			
			if not js.jobEnabled and enable then
				js.jobEnabled = true
				js:save()
			end
			
			if js.jobEnabled then
				jobSettings = js
				settings.jobEnabled = true
				currentJob = job
				
				if create and not exists then
					self:copy(settings, jobSettings, jobDefaults) -- apply current global settings to new job file
					jobSettings:save()
					log('Created job settings for ' .. job .. ' and copied global settings.')
				else
					self:copy(jobSettings, settings, jobDefaults) -- load job settings
					log('Loaded job settings for ' .. job .. '.')
				end
			end
		end
	end
	
	if wasJobEnabled and not settings.jobEnabled then
		log('Global settings applied.')
	end
	
	self:loadFilters()
end

function settings:save()
	self:saveFilters()

	if jobSettings then
		self:copy(settings, jobSettings, jobDefaults) -- copy only keys that are in job settings
		jobSettings:save()
		
		self:copy(settings, globalSettings, defaults, jobDefaults) -- copy keys that are NOT in job settings
		globalSettings:save()
	else
		self:copy(settings, globalSettings, defaults) -- copy all keys
		globalSettings:save()
	end
end

function settings:update()
	if not isInitialized then return end

	local job = windower.ffxi.get_player().main_job
	
	if currentJob ~= job then
		currentJob = job
		
		self:load()
	end
end

-- copies settings from one table to another
-- schema defines which keys shall be copied
-- (optional) ignoreSchema defines which keys shall be skipped
function settings:copy(from, to, schema, ignoreSchema)
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

function settings:loadFilters()
	settings.buffFilters:clear()

	-- why use a custom CSV parser? because config.lua does not detect a list with a single element as a list >_>
	if settings.buffs.filters ~= '' then
		for part in T(settings.buffs.filters:split(';')):it() do
			local buffIdString = part:trim()
			if buffIdString ~= '' then
				settings.buffFilters[tonumber(buffIdString)] = true
			end
		end
	end
	
	model:refreshFilteredBuffs()
end

function settings:saveFilters()
	settings.buffs.filters = ''
	
	for buffId, doFilter in pairs(settings.buffFilters) do 
		-- why add a semicolon even on the first element? because config.lua will mistake a single element as a number and not a string
		settings.buffs.filters = settings.buffs.filters .. tostring(buffId) .. ';'
	end
end

return settings