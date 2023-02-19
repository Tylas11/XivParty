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
local res = require('resources')

-- imports
local classes = require('classes')
local player = require('player')
local utils = require('utils')

-- create the class
local model = classes.class()

local partyKeys = { 'p%i', 'a1%i', 'a2%i' }

function model:init()
	-- NOTE: in lua list indices start with 1. when forced to index 0, iterating with :it() will work but out of order

	self.allPlayers = T{} -- unordered list of all players that we ever received data for

	self.parties = T{}
	for i = 0, 2 do
		self.parties[i] = T{} -- lists for members of the main party, first and second alliance parties, ordered by party list position, index ranges 0..5
	end
end

function model:dispose()
	self:clear()
end

function model:clear()
	self.allPlayers:clear()

	-- items already disposed via allPlayers
	for i = 0, 2 do
		self.parties[i]:clear()
	end
end

function model:updatePlayers()
	local members = T(windower.ffxi.get_party())
	local target = windower.ffxi.get_mob_by_target('t')
	local subtarget = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('stpt') or windower.ffxi.get_mob_by_target('stal')

	for i = 0, 17 do
		local idx = (i / 6):floor()
		local member = members[string.format(partyKeys[idx + 1], i % 6)]

		if member and member.name then
			local id
			if member.mob and member.mob.id > 0 then
				id = member.mob.id
			end

			local foundPlayer = self:getPlayer(member.name, id, 'member')
			if foundPlayer then
				foundPlayer:update(member, target, subtarget)
			end

			self.parties[idx][i % 6] = foundPlayer
		else
			self.parties[idx][i % 6] = nil
		end
	end
end

-- gets or creates a player based on name or ID
-- will merge existing players if a name-ID match is found
function model:getPlayer(name, id, debugTag, dontCreate)
	local foundPlayer
	local foundByName
	local foundById

	if not name and not id then
		utils:log('Attempted a player lookup without name and ID.', 4)
		return nil
	end

	for ap in self.allPlayers:it() do
		if name and ap.name == name then
			foundByName = ap
		end
		if id and ap.id == id then
			foundById = ap
		end
	end

	-- found by both, but they are not the same object
	if foundByName and foundById and foundByName ~= foundById then
		-- both have an ID but it is not the same, this can happen if players/trusts left the party and are still in the allPlayers list
		if foundByName.id ~= nil and foundById.id ~= nil and foundByName.id > 0 and foundById.id > 0 and foundByName.id ~= foundById.id then
			utils:log('ID conflict finding player, returning player with higher ID.', 2)

			-- use the player with the higher ID (most likely newer, confirmed true for trusts)
			if foundByName.id > foundById.id then
				foundPlayer = foundByName
				self.allPlayers:delete(foundById)
			else
				foundPlayer = foundById
				self.allPlayers:delete(foundByName)
			end
		else -- merge
			foundPlayer = foundByName:merge(foundById)
			self.allPlayers:delete(foundById)
		end
	else
		if foundByName then
			foundPlayer = foundByName
		else
			foundPlayer = foundById
		end

		if not foundPlayer and not dontCreate then
			utils:log('Creating new player (' .. debugTag .. ')', 2)
			foundPlayer = player.new(name, id, self)
			self.allPlayers:append(foundPlayer)
		end
	end

	return foundPlayer
end

-- finds player by name, returns nil if not found
function model:findPlayer(name)
	return self:getPlayer(name, nil, 'findPlayer', true)
end

-- finds leader of a party, defaults to main party when no index is specified
function model:findPartyLeader(partyIndex)
	if not partyIndex then partyIndex = 0 end

    for p in self.parties[partyIndex]:it() do
        if p.isLeader then
            return p
        end
    end

    return nil
end

function model:refreshFilteredBuffs()
	for p in self.parties[0]:it() do -- alliance members do not have buff information, only iterate the main party list as a minor optimization
		p:refreshFilteredBuffs()
	end
end

function model:hasAlliance2Members()
	return self.parties[2]:length() > 0
end

-- creates dummy parties for setup mode
function model:createSetupData()
	for partyIndex = 0, 2 do
		for i = 0, 5 do
			local j = res.jobs[math.random(1,22)].ens
			local sj = res.jobs[math.random(1,22)].ens

			local setupPlayer = player.new('Player' .. tostring(i + 1), (i + 1), nil) -- model only needed for party leader lookup for trusts, can skip here
			setupPlayer:createSetupData(j, sj, partyIndex == 0)
			self.parties[partyIndex][i] = setupPlayer
		end

		self.parties[partyIndex][0].isLeader = true
		self.parties[partyIndex][0].isAllianceLeader = true
		self.parties[partyIndex][0].isQuarterMaster = true

		-- NOTE: can't be both selected and out of zone, so range only 0-2
		self.parties[partyIndex][math.random(0,2)].isSelected = true

		-- set a zone that is not the current zone for one player, to show off the zone name display
		local zone = windower.ffxi.get_info().zone
		if zone == 0 then
			zone = zone + 1
		else
			zone = zone - 1
		end
		local outsideZonePlayer = self.parties[partyIndex][math.random(3,5)]
		outsideZonePlayer.zone = zone
		outsideZonePlayer.isOutsideZone = true
	end
end

-- sets bar percentage values of selected setup party members
function model:debugSetBarValue(type, value, partyIndex, playerIndex)
	if value == nil then value = 0 end
	if partyIndex == nil then partyIndex = 0 end
	if playerIndex == nil then playerIndex = 0 end

	if type == 'tpp' then
		self.parties[partyIndex][playerIndex].tpp = value
	elseif type == 'mpp' then
		self.parties[partyIndex][playerIndex].mpp = value
	else
		self.parties[partyIndex][playerIndex].hpp = value
	end
end

-- adds a new setup player to the specified party
function model:debugAddSetupPlayer(partyIndex)
	if not partyIndex then partyIndex = 0 end

	local setupParty = self.parties[partyIndex]
	local i = setupParty:length()

	if i > 5 then error('Cannot add setup player, party full!') return end

	local j = res.jobs[math.random(1,22)].ens
	local sj = res.jobs[math.random(1,22)].ens

	local setupPlayer = player.new('Player' .. tostring(i + 1), (i + 1), nil) -- model only needed for party leader lookup for trusts, can skip here
	setupPlayer:createSetupData(j, sj, partyIndex == 0)
	setupParty[i] = setupPlayer
end

function model:debugTestBuffs()
	for p = 0, 5 do
		local setupParty = self.parties[0]

		local cutoff = math.random(1, 32)
		for i = 1, 32 do
			local buff = nil
			if i < cutoff then
				buff = math.random(1, 631)
			end
			setupParty[p].buffs[i] = buff
		end
	end
end

return model