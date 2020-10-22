--[[
	Copyright © 2020, Tylas
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
_addon.version = '1.2.0'
_addon.commands = {'xp', 'xivparty'}

config = require('config')
texts  = require('texts')
images = require('images')
packets = require('packets')
res = require('resources')
logger = require('logger')
file = require('files')
require('strings')

local defaults = require('defaults')
local layoutDefaults = require('layout')

utils = require('utils')
img = require('img')
model = require('model')

local bo = require('buffOrder')
buffOrder = getBuffOrderWithIdKeys(bo)

local view = require('view')
local player = require('player')
local pet = require('pet')

local isLoaded = false
local isInitialized = false
local zoning = false
local hidden = false

-- constants

local layoutAuto = 'auto'
local layout1080 = '1080p'
local layout1440 = '1440p'

-- initialization / dispose / events

windower.register_event('load', function()
    if windower.ffxi.get_info().logged_in then
        settings = config.load(defaults)
		loadLayout(settings.layout)
		isLoaded = true
    end
end)

windower.register_event('login', function()
	if not isLoaded then
		settings = config.load(defaults)
		loadLayout(settings.layout)
		isLoaded = true
	end
end)

windower.register_event('logout', function()
	settings = nil
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
	loadFilters()
	view:init()
	view:pos(settings.posX, settings.posY)
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

	if settings and settings.hideSolo then
		if not isSolo() and not isInitialized then
			init()
		elseif isSolo() and isInitialized then
			dispose()
		end
	elseif windower.ffxi.get_info().logged_in and not isInitialized then
		init()
	end

	if not isInitialized then return end
	
	updatePlayers()
	view:update()
end)

function updatePlayers()
	local mainPlayer = windower.ffxi.get_player()
	local party = T(windower.ffxi.get_party())
	local zone = windower.ffxi.get_info().zone
	local target = windower.ffxi.get_mob_by_target('t')
	local subtarget = windower.ffxi.get_mob_by_target('st')
	local playerPet = windower.ffxi.get_mob_by_target('pet')
	local partyCount = 0
	
	for i = 0, 5 do
		local key = 'p%i':format(i % 6)
		local member = party[key]
		
		if member and not member.isPet then
			local foundPlayer = model:findAndSortPlayer(member, i)
			if not foundPlayer then
				foundPlayer = model:takePlayerFromTemp(member)
				if foundPlayer then
					utils:log('found new player: '..member.name, 2)
					model.players[i] = foundPlayer -- insert, pushing possible existing player at this position aside. will be re-sorted later
				else
					utils:log('Creating new player: '..member.name, 2)
					model.players[i] = player:init()
				end
			end
			
			local player = model.players[i]
			partyCount = partyCount +1
			
			player.isSelected = (target ~= nil and member.mob ~= nil and target.id == member.mob.id)
			player.isSubTarget = (subtarget ~= nil and member.mob ~= nil and subtarget.id == member.mob.id)
			player.name = member.name
			player.isPet = false
		
			if member.zone and (member.zone ~= zone) then -- outside zone
				player:clear()
				player.zone = '('..res.zones[member.zone].name..')'
			else
				player.hp = member.hp
				player.mp = member.mp
				player.tp = member.tp
				player.hpp = member.hpp
				player.mpp = member.mpp
				
				if member.tp then
					player.tpp = math.min(member.tp / 30, 100)
				end
				player.zone = ''
				
				if member.mob then
					player.id = member.mob.id
					player.distance = member.mob.distance
					
					model:mergeTempBuffs(player)
				else
					player.distance = 99999
				end
				
				if (member.name == mainPlayer.name) then -- set buffs and job info for main player
					player:updateBuffs(mainPlayer.buffs, model.buffFilters)
					player.job = res.jobs[mainPlayer.main_job_id].name_short
					player.jobLvl = mainPlayer.main_job_level
					
					if (mainPlayer.sub_job_id) then -- only if subjob is set
						player.subJob = res.jobs[mainPlayer.sub_job_id].name_short
						player.subJobLvl = mainPlayer.sub_job_level
					end
				end
			end
		else
			local player = model.players[i]
		
			if player and not player.isPet then
				for tp in model.tempPlayers:it() do
					if tp == player then
						utils:log('Found duplicate player '..player.name..' in temp list, deleting.', 3)
						model.tempPlayers:delete(tp)
						break
					end
				end
				
				player:dispose()
				model.players[i] = nil
			end
		end
	end
	
	--remove all trailing pets
	if partyCount <= 5 then
		for i = partyCount+1, 6 do
			local pet = model.players[i]
			if pet and pet.isPet then
				utils:log('Removing Pet with position: '..i, 2)
				pet:dispose()
				model.players[i] = nil
			end
		end
	end
	
	--re-add pet
	utils:log('Adding Pet with PartyCount: '..partyCount, 0)
	local j = partyCount
	if isPetJob() then
		partyCount = partyCount +1
		if playerPet then
			local foundPet = model:findAndSortPlayer(playerPet, j)
			if not foundPet then
				utils:log('Creating new pet: '..playerPet.name..' at '..j, 2)
				model.players[j] = pet:init()
			end
			local foundPet = model.players[j]
			foundPet.name = playerPet.name
			foundPet.noPet = false
			foundPet.distance = playerPet.distance
		else
			model.players[j] = pet:init()
			local foundPet = model.players[j]
			foundPet:vanish()
		end
	end
	
	if settings.growth == "up" then
		utils:log('PartyCount: '..partyCount, 0)
		if not view:moveEnabled() and ((isPetJob() and partyCount > 2) or (not isPetJob() and partyCount > 1)) then
			local offset = 0;
			for i = 0, partyCount do
				offset = offset + (i * 7)
			end
			view:pos(settings.posX, settings.posY-(offset))
		elseif not view:moveEnabled() then
			view:pos(settings.posX, settings.posY)
		end
	end
end

-- packets

windower.register_event('incoming chunk',function(id,original,modified,injected,blocked)
	if not zoning then
		if id == 0xDF then -- char update
			packet = packets.parse('incoming', original)
			if packet then
				local playerId = packet['ID']
				utils:log('PACKET: Char update for player ID: '..playerId, 0)
			
				local foundPlayer = model:findOrCreateTempPlayer(nil, playerId)
				updatePlayerJobFromPacket(foundPlayer, packet)
			end
		end
		if id == 0xDD then -- party member update
			packet = packets.parse('incoming', original)
			if packet then
				local name = packet['Name']
				local playerId = packet['ID']
				if name then
					utils:log('PACKET: Party member update for '..name, 0)
					local foundPlayer = model:findOrCreateTempPlayer(name, playerId)
					updatePlayerJobFromPacket(foundPlayer, packet)
				else
					utils:log('Name data not found.', 3)
				end
			else
				utils:log('Failed to parse packet.', 3)
			end
		end
		
		--pet stuff
		if isPetJob() then
			updatePetFromPacket(id, original)
		end
		
	end
	if not zoning and id == 0x076 then -- party buffs (Credit: Kenshi, PartyBuffs)
        for k = 0, 4 do
            local playerId = original:unpack('I', k*48+5)
            
            if playerId ~= 0 then -- NOTE: main player buffs are not available here
				local buffsList = {}
				
                for i = 1, 32 do -- starting at 1 to match the offset in windower.ffxi.get_player().buffs
                    local buff = original:byte(k*48+5+16+i-1) + 256*( math.floor( original:byte(k*48+5+8+ math.floor((i-1)/4)) / 4^((i-1)%4) )%4) -- Credit: Byrth, GearSwap
					
					if buff == 255 then -- push empty buffs to a higher number so they get sorted at the end of the list
						buff = 1000
					end
					buffsList[i] = buff
                end
				
				local foundPlayer = model:findPlayer(nil, playerId)
				if not foundPlayer then
					utils:log('Player with ID '..tostring(playerId)..' not found. Storing temporary buffs.', 2)
					model.tempBuffs[playerId] = buffsList
				else
					utils:log('Updated buffs for player with ID ' .. tostring(playerId), 1)
					foundPlayer:updateBuffs(buffsList, model.buffFilters)
				end
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

function updatePlayerJobFromPacket(player, packet)
	-- these can contain NON 0 / NON 0 when the party member is out of zone
	-- seem to always get NON 0 / NON 0 if character has no SJ
	local mJob = packet['Main job']
	local mJobLvl = packet['Main job level']
	local sJob =  packet['Sub job']
	local sJobLvl = packet['Sub job level']
	local playerId = packet['ID']
	
	if (mJob and mJobLvl and sJob and sJobLvl and mJobLvl > 0) then
		player.id = playerId
		player.job = res.jobs[mJob].name_short
		player.jobLvl = mJobLvl
		player.subJob = res.jobs[sJob].name_short
		player.subJobLvl = sJobLvl
		
		utils:log('Set job info: '..res.jobs[mJob].name_short..tostring(mJobLvl)..'/'..res.jobs[sJob].name_short..tostring(sJobLvl), 0)
	else
		utils:log('Unusable job info. Dropping.', 0)
	end
end

function updatePetFromPacket(id, original)

	if original == nil then
		return
	end

	if id == 0x44 then
		packet = packets.parse('incoming', original)
		local petName = original:unpack('z', 0x59)
		if petName == "" then
			return
		end
		local pet = model:findPlayer(petName, nil)
		utils:log('PACKET: 0x44 Found Pet: '..petName, 0)

		if pet and original:unpack('C', 0x05) == 0x12 then    -- puppet update
							
			local current_hp, max_hp, current_mp, max_mp = original:unpack('HHHH', 0x069)

			-- windower.add_to_chat(8, '0x44 PUPPET'
			--						..', cur_hp: '..current_hp
			--						..', max_hp: '..max_hp
			--						..', cur_mp: '..current_mp
			--						..', max_mp: '..max_mp
			--						..', name: '.. original:unpack('z', 0x59)
			--					)
			pet.hp = current_hp
			pet.mp = current_mp
			pet.maxhp = max_hp
			pet.maxmp = max_mp
			if pet.maxhp ~= 0 then
				pet.hpp = math.floor(100 * pet.hp / pet.maxhp)
			else
				pet.hpp = 0
			end
			if pet.maxmp ~= 0 then
				pet.mpp = math.floor(100 * pet.mp / pet.maxmp)
			else
				pet.mpp = 0
			end
		end

	elseif id == 0x67 or id == 0x068 then    -- general hp/tp/mp update
	
		packet = packets.parse('incoming', original)
		utils:log('PACKET: 0x67 or 0x068', 0)
		local msg_type = packet['Message Type'] or null
		local msg_len = packet['Message Length']  or null
		local pet_idx = packet['Pet Index']  or null
		local own_idx = packet['Owner Index']  or null

		local petName = ((msg_len > 24) and original:unpack('z', 0x19) or "")

		if (msg_type == 0x04) and id == 0x067 then
			pet_idx, own_idx = own_idx, pet_idx
		end
		
		utils:log('PACKET:0x67 or 0x068 ['..msg_type..'] Searching for : '..petName..' '..pet_idx, 2)
		local pet = model:findPlayer(petName, pet_idx)
		
		if pet == nil then
			utils:log('PACKET:0x67 or 0x068 No Pet found', 2)
			return
		end
				
		utils:log('PACKET:0x67 or 0x068 ['..msg_type..'] Found Pet: '..petName, 2)

		if (msg_type == 0x04) then
			utils:log('PACKET: 0x04', 0)
			if (pet_idx == 0) then
				pet:dispose() -- died
			else
				utils:log('PACKET: Updating General', 0)
				pet.tp = packet['Pet TP']
				pet.hpp = packet['Current HP%']
				pet.mpp = packet['Current MP%']
				--windower.add_to_chat(8, '0x04 '
				--					..', pet.tp: '..pet.tp
				--					..', pet.hpp: '..pet.hpp
				--					..', pet.mpp : '..pet.mpp 
				--					..', pet.maxhp: '..pet.maxhp
				--					..', pet.maxmp: '..pet.maxmp
				--				)
				pet.tpp = math.floor(100 * pet.tp / 3000)
				if pet.maxhp and pet.maxhp >= 0 then
					pet.hp = math.floor(pet.hpp * pet.maxhp / 100)
				else
					pet.hp = pet.hpp
				end
				if pet.maxmp and pet.maxmp >= 0 then
					pet.mp = math.floor(pet.mpp * pet.maxmp / 100)
				else
					pet.mp = pet.mpp
				end
			end
		end
	end
end
-- utilities

function isSolo()
	return windower.ffxi.get_party().party1_leader == nil
end

function isPetJob()
	local player = windower.ffxi.get_player()
	if not player then
		return false
	end
	return S{"SMN","PUP", "BST", "GEO"}:contains(windower.ffxi.get_player().main_job)
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

function loadFilters()
	-- why use a custom CSV parser? because config.lua does not detect a list with a single element as a list >_>
	if settings.buffs.filters ~= '' then
		for part in T(settings.buffs.filters:split(';')):it() do
			local buffIdString = part:trim()
			if buffIdString ~= '' then
				model.buffFilters[tonumber(buffIdString)] = true
			end
		end
	end
end

function saveFilters()
	settings.buffs.filters = ''
	
	for buffId, doFilter in pairs(model.buffFilters) do 
		-- why add a semicolon even on the first element? because config.lua will mistake a single element as a number and not a string
		settings.buffs.filters = settings.buffs.filters .. tostring(buffId) .. ';'
	end
	settings:save()
end

function refreshFilteredBuffs()
	for player in model.players:it() do
		player:updateBuffs(player.buffs, model.buffFilters)
	end
end

function checkBuff(buffId)
	if buffId and res.buffs[buffId] then
		return true
	else
		log('Buff with ID ' .. buffId .. ' not found.')
		return false
	end
end

function getBuffText(buffId)
	local buffData = res.buffs[buffId]
	if buffData then
		return buffData.en .. ' (' .. buffData.id .. ')'
	else
		return tostring(buffId)
	end
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
	
	if command == 'move' then
		local ret = handleCommandOnOff(view:moveEnabled(), args[2], 'Mouse dragging')
		view:moveEnabled(ret)
	elseif command == 'hidesolo' then
		local ret = handleCommandOnOff(settings.hideSolo, args[2], 'Party list hiding while solo')
		settings.hideSolo = ret
		settings:save()
	elseif command == 'customorder' then
		local ret = handleCommandOnOff(settings.buffs.customOrder, args[2], 'Custom buff ordering')
		settings.buffs.customOrder = ret
		settings:save()
	elseif command == 'range' then
		if args[2] then
			local range = string.lower(args[2])
			if range == 'off' then
				range = 0
			else
				range = tonumber(range)
			end
			settings.rangeIndicator = range
			settings:save()
		else
			showHelp()
		end
	elseif command == 'filter' or command == 'filters' then
		local subCommand = string.lower(args[2])
		if subCommand == 'add' then
			local buffId = tonumber(args[3])
			if checkBuff(buffId) then
				model.buffFilters[buffId] = true
				saveFilters()
				refreshFilteredBuffs()
				log('Added buff filter for ' .. getBuffText(buffId))
			end
		elseif subCommand == 'remove' then
			local buffId = tonumber(args[3])
			if checkBuff(buffId) then
				model.buffFilters[buffId] = nil
				saveFilters()
				refreshFilteredBuffs()
				log('Removed buff filter for ' .. getBuffText(buffId))
			end
		elseif subCommand == 'clear' then
			model.buffFilters = T{}
			saveFilters()
			refreshFilteredBuffs()
			log('All buff filters cleared.')
		elseif subCommand == 'list' then
			log('Currently active buff filters (' .. settings.buffs.filterMode .. '):')
			for buffId, doFilter in pairs(model.buffFilters) do
				if doFilter then
					log(getBuffText(buffId))
				end
			end
		elseif subCommand == 'mode' then
			local ret = handleCommand(settings.buffs.filterMode, args[3], 'Filter mode', 'blacklist', 'blacklist', 'whitelist', 'whitelist')
			settings.buffs.filterMode = ret
			settings:save()
			refreshFilteredBuffs()
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
				log('Player ' .. playerName .. ' not found.')
			end
		else
			buffs = windower.ffxi.get_player().buffs
			log('Your active buffs:')
		end
		for i = 1, 32 do
			if buffs[i] and buffs[i] ~= 1000 and buffs[i] ~= 255 then
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
				log('The layout file \'' .. filename .. '\' does not exist!')
			end
		else
			showHelp()
		end
	else
		showHelp()
	end
end)

function handleCommandOnOff(currentValue, argsString, text)
	return handleCommand(currentValue, argsString, text, 'on', true, 'off', false)
end

function handleCommand(currentValue, argsString, text, option1String, option1Value, option2String, option2Value)
	local setValue

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
		log('Unknown parameter \'' .. argsString .. '\'')
		return currentValue
	end
	
	local setString = option1String
	if setValue == option2Value then
		setString = option2String
	end
	log(text .. ' is now ' .. setString .. '.')
	
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
	log('range <distance> - shows a marker for each party member closer than the set distance (off or 0 to disable)')
	log('customOrder - toggles custom buff ordering (customize in bufforder.lua)')
	log('hideSolo - hides the party list while solo')
	log('move - move the UI via drag and drop, mouse wheel to adjust space between party members')
	log('layout <file> - loads a UI layout file. Use \'auto\' to enable resolution based selection.')
end