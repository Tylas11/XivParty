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

local model = {}
local player = require('player')

-- NOTE: list indices start with 1. when forced to index 0, iterating with :it() will work but out of order

model.players = T{} -- party members to be displayed in the view, ordered by party list position, index range 0..5
model.allPlayers = T{} -- unordered list of all players that we ever received data for
model.buffFilters = T{} -- dictionary, key: buff ID, value: bool indicating whether to filter

function model:clear()
	for ap in self.allPlayers:it() do
		ap:dispose()
	end
	self.allPlayers:clear()
	
	self.players:clear() -- items already disposed via allPlayers
	self.buffFilters:clear()
end

function model:updatePlayers()
	local mainPlayer = windower.ffxi.get_player()
	local party = T(windower.ffxi.get_party())
	local zone = windower.ffxi.get_info().zone
	local target = windower.ffxi.get_mob_by_target('t')
	local subtarget = windower.ffxi.get_mob_by_target('st')
	
	for i = 0, 5 do
		local member = party['p%i':format(i % 6)]
		if member and member.name then
			local id
			if member.mob and member.mob.id > 0 then
				id = member.mob.id
			end
			local foundPlayer = self:getPlayer(member.name, id, 'member')
			foundPlayer:update(member, zone, target, subtarget)
			
			self.players[i] = foundPlayer
		else
			self.players[i] = nil
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
	
	-- found by both, but they are not the same object then merge
	if foundByName and foundById and foundByName ~= foundById then
		foundPlayer = foundByName:merge(foundById)
		foundById:dispose()
		self.allPlayers:delete(foundById)
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

return model