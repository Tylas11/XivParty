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

_addon.name = 'XivParty'
_addon.author = 'Tylas'
_addon.version = '1.7.0'
_addon.commands = {'xp', 'xivparty'}

config = require('config')
texts  = require('texts')
images = require('images')
packets = require('packets')
res = require('resources')
logger = require('logger')
file = require('files')
require('strings')

utils = require('utils')
img = require('img')

local md = require('model')
local model = md:init()

settings = require('settings')
local layoutDefaults = require('layout')

local bo = require('buffOrder')
buffOrder = getBuffOrderWithIdKeys(bo)

local view = require('view')
local player = require('player')

local isLoaded = false
local isInitialized = false
local zoning = false
local hidden = false

math.randomseed(os.time())

-- constants

local layoutAuto = 'auto'
local layout1080 = '1080p'
local layout1440 = '1440p'

-- initialization / dispose / events

windower.register_event('load', function()
	if windower.ffxi.get_info().logged_in then
		settings:init(model)
		settings:load()
		loadLayout(settings.layout)
		isLoaded = true
	end
end)

windower.register_event('login', function()
	if not isLoaded then
		settings:init(model)
		settings:load()
		loadLayout(settings.layout)
		isLoaded = true
	end
end)

windower.register_event('logout', function()
	isLoaded = false
end)

windower.register_event('status change', function(status)
	if not hidden and status == 4 then -- hide UI during cutscenes
		hidden = true
		view:hide()
	elseif hidden and status ~= 4 then
		hidden = false
		view:show()
	end
end)

function init()
	if settings.hideSolo and isSolo() then return end
	if isInitialized then return end
	
	utils:log('Initializing...')
	view:init(model)
	view:show()
	
	isInitialized = true
end

function dispose()
	utils:log('Disposing...')
	isInitialized = false
	
	view:dispose()
	model:clear()
end

-- per frame updating

windower.register_event('prerender', function()
	if zoning then return end
	
	settings:update()
	
	if settings.hideSolo then
		if not isSolo() and not isInitialized then
			init()
		elseif isSolo() and isInitialized then
			dispose()
		end
	elseif windower.ffxi.get_info().logged_in and not isInitialized then
		init()
	end
    
	if not isInitialized then return end
	
	model:updatePlayers()
	view:update()
end)

-- packets

windower.register_event('incoming chunk',function(id,original,modified,injected,blocked)
	if not zoning then
		if id == 0xC8 then -- alliance update
			local packet = packets.parse('incoming', original)
			if packet then
				for i = 1, 18 do
					local playerId = packet['ID ' .. tostring(i)]
					local flags = packet['Flags ' .. tostring(i)]
					if flags and playerId and playerId > 0 then
						local foundPlayer = model:getPlayer(nil, playerId, 'alliance')
						foundPlayer:updateLeaderFromFlags(flags)
					end
				end
			end
		end
	
		if id == 0xDF then -- char update
			local packet = packets.parse('incoming', original)
			if packet then
				local playerId = packet['ID']
				if playerId and playerId > 0 then
					utils:log('PACKET: Char update for player ID: '..playerId, 0)
					
					local foundPlayer = model:getPlayer(nil, playerId, 'char')
					foundPlayer:updateJobFromPacket(packet)
				else
					utils:log('Char update: ID not found.', 1)
				end
			end
		end
		
		if id == 0xDD then -- party member update
			local packet = packets.parse('incoming', original)
			if packet then
				local name = packet['Name']
				local playerId = packet['ID']
				if name and playerId and playerId > 0 then
					utils:log('PACKET: Party member update for '..name, 0)
					
					local foundPlayer = model:getPlayer(name, playerId, 'party')
					foundPlayer:updateJobFromPacket(packet)
				else
					utils:log('Party update: name and/or ID not found.', 1)
				end
			end
		end
	end
	
	if not zoning and id == 0x076 then -- party buffs (Credit: Kenshi, PartyBuffs)
		for k = 0, 4 do
			local playerId = original:unpack('I', k*48+5)
			
			if playerId ~= 0 then -- NOTE: main player buffs are not available here
				local buffsList = {}
				
				for i = 1, 32 do -- starting at 1 to match the offset in windower.ffxi.get_player().buffs
					local buff = original:byte(k*48+5+16+i-1) + 256*( math.floor( original:byte(k*48+5+8+ math.floor((i-1)/4)) / 4^((i-1)%4) )%4) -- Credit: Byrth, GearSwap
					
					if buff == 255 then -- empty buff
						buff = nil
					end
					buffsList[i] = buff
				end
				
				local foundPlayer = model:getPlayer(nil, playerId, 'buffs')
				foundPlayer:updateBuffs(buffsList)
				utils:log('Updated buffs for player with ID ' .. tostring(playerId), 1)
			end
		end
	end
	
	if id == 0xB then
		utils:log('Zoning...')
		zoning = true
		dispose()
	elseif id == 0xA and zoning then
		utils:log('Zoning done.')
		coroutine.schedule(zoningFinished, 3) -- delay a bit so init does not see pre-zone party lists
	end
end)

-- utilities

function isSolo()
	return windower.ffxi.get_party().party1_leader == nil
end

function loadLayout(layoutName)
	if layoutName == layoutAuto then
		local resY = windower.get_windower_settings().ui_y_res
		if resY <= 1200 then
			layoutName = layout1080
		else
			layoutName = layout1440
		end
		
		--print('Detected Y resolution ' .. tostring(resY) .. '. Loading layout \'' .. layoutName .. '\'.')
	end

	layout = config.load('layouts/' .. layoutName .. '.xml', layoutDefaults)
end

function checkBuff(buffId)
	if buffId and res.buffs[buffId] then
		return true
	elseif not buffId then
		error('Invalid buff ID.')
	else
		error('Buff with ID ' .. buffId .. ' not found.')
	end
	
	return false
end

function getBuffText(buffId)
	local buffData = res.buffs[buffId]
	if buffData then
		return buffData.en .. ' (' .. buffData.id .. ')'
	else
		return tostring(buffId)
	end
end

function getRange(arg)
	if not arg then return nil end

	local range = string.lower(arg)
	if range == 'off' then
		range = 0
	else
		range = tonumber(range)
	end
	
	if not range then
		error('Invalid range \'' .. arg .. '\'.')
	end
	
	return range
end

function zoningFinished()
	zoning = false
	init()
end

-- commands / help

windower.register_event('addon command', function(...)
	local args = T{...}
	local command
	if args[1] then
		command = string.lower(args[1])
	end
	
	if command == 'setup' then
		if not isInitialized then
			error('Party list not initialized. Join a party or disable hiding while solo.')
		else
			local ret = handleCommandOnOff(view:setupEnabled(), args[2], 'Setup mode')
			view:setupEnabled(ret)
		end
	elseif command == 'hidesolo' then
		local ret = handleCommandOnOff(settings.hideSolo, args[2], 'Party list hiding while solo')
		settings.hideSolo = ret
		settings:save()
	elseif command == 'alignbottom' then
		local ret = handleCommandOnOff(settings.alignBottom, args[2], 'Bottom alignment')
		settings.alignBottom = ret
		settings:save()
		view:update(true) -- force a redraw
	elseif command == 'customorder' then
		local ret = handleCommandOnOff(settings.buffs.customOrder, args[2], 'Custom buff order')
		settings.buffs.customOrder = ret
		settings:save()
	elseif command == 'range' then
		if args[2] then
			local range1 = getRange(args[2])
			local range2 = getRange(args[3])
			if range1 then
				settings.rangeIndicator = range1
				if range2 then
					settings.rangeIndicatorFar = range2
					if settings.rangeIndicator > settings.rangeIndicatorFar then
						settings.rangeIndicator = range2
						settings.rangeIndicatorFar = range1
					end
					log('Range indicators set to ' .. tostring(range1) .. ' / ' .. tostring(range2) .. '.')
				else
					settings.rangeIndicatorFar = 0
					if range1 > 0 then
						log('Range indicator set to ' .. tostring(range1) .. '.')
					else
						log('Range indicator disabled.')
					end
				end
				settings:save()
			end
		else
			showHelp()
		end
	elseif command == 'filter' or command == 'filters' then
		local subCommand = string.lower(args[2])
		if subCommand == 'add' then
			local buffId = tonumber(args[3])
			if checkBuff(buffId) then
				settings.buffFilters[buffId] = true
				settings:save()
				model:refreshFilteredBuffs()
				log('Added buff filter for ' .. getBuffText(buffId))
			end
		elseif subCommand == 'remove' then
			local buffId = tonumber(args[3])
			if checkBuff(buffId) then
				settings.buffFilters[buffId] = nil
				settings:save()
				model:refreshFilteredBuffs()
				log('Removed buff filter for ' .. getBuffText(buffId))
			end
		elseif subCommand == 'clear' then
			settings.buffFilters = T{}
			settings:save()
			model:refreshFilteredBuffs()
			log('All buff filters cleared.')
		elseif subCommand == 'list' then
			log('Currently active buff filters (' .. settings.buffs.filterMode .. '):')
			for buffId, doFilter in pairs(settings.buffFilters) do
				if doFilter then
					log(getBuffText(buffId))
				end
			end
		elseif subCommand == 'mode' then
			local ret = handleCommand(settings.buffs.filterMode, args[3], 'Filter mode', 'blacklist', 'blacklist', 'whitelist', 'whitelist')
			settings.buffs.filterMode = ret
			settings:save()
			model:refreshFilteredBuffs()
		else
			showHelp()
		end
	elseif command == 'buffs' then
		local playerName = args[2]
		local buffs
		if playerName then
			playerName = playerName:ucfirst()
			local foundPlayer = model:findPlayer(playerName)
			if foundPlayer then
				buffs = foundPlayer.buffs
				log(playerName .. '\'s active buffs:')
			else
				error('Player ' .. playerName .. ' not found.')
				return
			end
		else
			buffs = windower.ffxi.get_player().buffs
			log('Your active buffs:')
		end
		for i = 1, 32 do
			if buffs[i] then
				log(getBuffText(buffs[i]))
			end
		end
	elseif command == 'layout' then
		if args[2] then
			local isAuto = args[2] == layoutAuto
			local filename = 'layouts/' .. args[2] .. '.xml'
			
			if isAuto or file.exists(filename) then
				if isAuto then
					log('Enabled automatic resolution based layout selection.')
				else
					log('Loading layout \'' .. args[2] .. '\'.')
				end
				
				dispose()
				loadLayout(args[2])
				settings.layout = args[2]
				settings:save()
				init()
			else
				error('The layout file \'' .. filename .. '\' does not exist!')
			end
		else
			showHelp()
		end
	elseif command == 'job' then
		local job = windower.ffxi.get_player().main_job
		local ret = handleCommandOnOff(settings.jobEnabled, args[2], 'Job specific settings for ' .. job, true)
		
		if ret then
			if not settings.jobEnabled then
				settings:load(true, true)
				log('Settings changes to range and buffs will now only affect this job.')
			end
		elseif settings.jobEnabled then
			settings.jobEnabled = false
			settings:save()
			settings:load()
			log('Global settings applied. The job specific settings for ' .. job .. ' will remain saved for later use.')
		end
	else
		showHelp()
	end
end)

function handleCommandOnOff(currentValue, argsString, text, plural)
	local isNowText = nil
	if plural then
		isNowText = 'are now'
	end
	return handleCommand(currentValue, argsString, text, 'on', true, 'off', false, isNowText)
end

function handleCommand(currentValue, argsString, text, option1String, option1Value, option2String, option2Value, isNowText)
	local setValue
	if not isNowText then
		isNowText = 'is now'
	end

	if argsString and string.lower(argsString) == option1String then
		setValue = option1Value
	elseif argsString and string.lower(argsString) == option2String then
		setValue = option2Value
	elseif not argsString or argsString == '' then
		if currentValue == option1Value then
			setValue = option2Value
		else
			setValue = option1Value
		end
	else
		error('Unknown parameter \'' .. argsString .. '\'.')
		return currentValue
	end
	
	local setString = option1String
	if setValue == option2Value then
		setString = option2String
	end
	log(text .. ' ' .. isNowText .. ' ' .. setString .. '.')
	
	return setValue
end

function showHelp()
	log('Commands: //xivparty or //xp')
	log('filter - hides specified buffs in party list. Use command \"buffs\" to find out IDs.')
	log('   add <ID> - adds filter for a buff (e.g. //xp filter add 123)')
	log('   remove <ID> - removes filter for a buff')
	log('   clear - removes all filters')
	log('   list - shows list of currently set filters')
	log('   mode - switches between blacklist and whitelist mode (both use same filter list)')
	log('buffs <name> - shows list of currently active buffs and their IDs for a party member')
	log('range <near> <far> - shows a marker for each party member closer than the set distances (off or 0 to disable)')
	log('customOrder - toggles custom buff order (customize in bufforder.lua)')
	log('hideSolo - hides the party list while solo')
	log('alignBottom - expands the party list from bottom to top')
	log('job - toggles job specific settings for current job')
	log('setup - move the UI via drag and drop, hold CTRL for grid snap, mouse wheel to adjust space between party members')
	log('layout <file> - loads a UI layout file. Use \'auto\' to enable resolution based selection.')
end