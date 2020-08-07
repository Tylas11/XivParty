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

local model = {}
local player = require('player')

-- NOTE: list indices start with 1. when forced to index 0, iterating with :it() will work but out of order

model.players = T{} -- ordered list by party list position, index range 0..5
model.tempPlayers = T{} -- unordered list, dont access using indices!
model.tempBuffs = T{} -- dictionary, key: player ID
model.buffFilters = T{} -- dictionary, key: buff ID, value: bool indicating whether to filter

function model:clear()
	for player in self.players:it() do
		player:dispose()
	end
	self.players:clear()
	
	for tempPlayer in self.tempPlayers:it() do
		tempPlayer:dispose()
	end
	self.tempPlayers:clear()
	
	self.tempBuffs:clear()
	self.buffFilters:clear()
end

function model:takePlayerFromTemp(member)
	for temp in self.tempPlayers:it() do
		if (temp.name == nil and member.mob ~= nil and temp.id == member.mob.id) then
			utils:log('Found player based on ID '..member.mob.id..' in temp players list.')
			return self.tempPlayers:delete(temp)
		end
	
		if temp.name == member.name then
			utils:log('Found player '..member.name..' in temp players list.')
			return self.tempPlayers:delete(temp)
		end
	end
	
	return nil
end

function model:findAndSortPlayer(member, index)
	for i = 0, 5 do
		if self.players[i] and self.players[i].name == member.name then
			if (index ~= i) then
				temp = self.players[index]
				self.players[index] = self.players[i]
				self.players[i] = temp
			
				utils:log('Found '..member.name..' and swapped from index '..tostring(index)..' to '..tostring(i))
			end
			
			return self.players[index]
		end
	end
	
	return nil
end

function model:mergeTempBuffs(player)
	if self.tempBuffs[player.id] then
		utils:log('Found and merged buffs for player '..player.name..' with ID '..tostring(player.id))
		
		player:updateBuffs(self.tempBuffs[player.id], self.buffFilters)
		self.tempBuffs[player.id] = nil
	end
end

function model:findPlayer(name, id)
	local foundPlayer

	-- look in players list
	for p in self.players:it() do
		if (name ~= nil and p.name == name) or (id ~= nil and p.id == id) then
			foundPlayer = p
			break
		end
	end
	
	-- look in temp players list
	if not foundPlayer then
		for tp in self.tempPlayers:it() do
			if (name ~= nil and tp.name == name) or (id ~= nil and tp.id == id) then
				foundPlayer = tp
			end
		end
	end
	
	return foundPlayer
end

-- finds player by name OR id, create new if not found and add to temp list
function model:findOrCreateTempPlayer(name, id)
	local foundPlayer = self:findPlayer(name, id)
	
	if not foundPlayer then
		local displayName = name
		if not displayName then displayName = '???' end
		utils:log('Creating temp player for '..displayName..' with ID '..tostring(id))
		
		foundPlayer = player:init()
		foundPlayer.name = name
		foundPlayer.id = id
		self.tempPlayers:append(foundPlayer)
	end
	
	return foundPlayer
end

return model