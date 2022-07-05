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

local player = require('player')

local model = {}
model.__index = model

function model:init()
	local obj = {}
	setmetatable(obj, model) -- make handle lookup
	
	-- NOTE: in lua list indices start with 1. when forced to index 0, iterating with :it() will work but out of order
	
	obj.allPlayers = T{} -- unordered list of all players that we ever received data for

	obj.parties = T{}
	for i = 0, 2 do
		obj.parties[i] = T{} -- lists for members of the main party, first and second alliance parties, ordered by party list position, index ranges 0..5
	end
	
	return obj
end

function model:dispose()
	self:clear()

	setmetatable(self, nil)
end

function model:clear()
	for ap in self.allPlayers:it() do
		ap:dispose()
	end
	self.allPlayers:clear()

	-- items already disposed via allPlayers
	for i = 0, 2 do
		self.parties[i]:clear()
	end
end

function model:updatePlayers()
	local members = T(windower.ffxi.get_party())
	local target = windower.ffxi.get_mob_by_target('t')
	local subtarget = windower.ffxi.get_mob_by_target('st')
	
	for i = 0, 17 do
		local idx = (i / 6):floor()
        local key = {'p%i', 'a1%i', 'a2%i'}[idx + 1]:format(i % 6)
		local member = members[key]
		if member and member.name then
			local id
			if member.mob and member.mob.id > 0 then
				id = member.mob.id
			end
			local foundPlayer = self:getPlayer(member.name, id, 'member')
			foundPlayer:update(member, target, subtarget)
			
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
				foundById:dispose()
				self.allPlayers:delete(foundById)
			else
				foundPlayer = foundById
				foundByName:dispose()
				self.allPlayers:delete(foundByName)
			end
		else -- merge
			foundPlayer = foundByName:merge(foundById)
			foundById:dispose()
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
			foundPlayer = player:init(name, id)
			self.allPlayers:append(foundPlayer)
		end
	end
	
	return foundPlayer
end

-- finds player by name, returns nil if not found
function model:findPlayer(name)
	return self:getPlayer(name, nil, 'findPlayer', true)
end

function model:refreshFilteredBuffs()
	for player in self.allPlayers:it() do -- TODO: alliance members might not have buff information, could only iterate the main party list as a minor optimization
		player:refreshFilteredBuffs()
	end
end

return model