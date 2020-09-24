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

local player = {}
player.__index = player

function player:init()
	utils:log('Initializing player', 1)

	local p = {}
	setmetatable(p, player) -- make handle lookup

	p.name = '???'
	p.zone = ''
	p.id = -1
	
	p:clear()
	
	return p
end

function player:clear()
	self.hp = -1 -- not set: UI will show '?' instead of the number
	self.mp = -1
	self.tp = -1
	
	-- percentages
	self.hpp = 0
	self.mpp = 0
	self.tpp = 0
	
	self.isSelected = false
	self.isSubTarget = false
	
	self.job = '???'
	self.jobLvl = 0
	self.subJob = '???'
	self.subJobLvl = 0
	
	self.distance = 99999
	
	self.buffs = {} -- list of all buffs this player has
	self.filteredBuffs = T{} -- list of filtered buffs to be displayed
end

function player:updateBuffs(buffs, filters)
	self.buffs = buffs
	self.filteredBuffs = T{}
	
	for i = 1, 32 do
		buff = buffs[i]
		
		if (settings.buffs.filterMode == 'blacklist' and filters[buff]) or 
		   (settings.buffs.filterMode == 'whitelist' and not filters[buff]) then
			buff = nil
		end
		
		if buff then
			self.filteredBuffs:append(buff)
		end
	end
	
	if settings.buffs.customOrder then
		self.filteredBuffs:sort(buffOrderCompare)
	else
		self.filteredBuffs:sort()
	end
end

function buffOrderCompare(a, b)
	local orderA = buffOrder[a]
	local orderB = buffOrder[b]

	if not orderA then
		return false
	elseif not orderB then
		return true
	end
	
	return buffOrder[a] < buffOrder[b]
end

function player:dispose()
	local displayName = '???'
	if (self.name) then
		displayName = self.name
	end
	utils:log('Disposing player '..displayName, 1)
	
	setmetatable(self, nil)
end

return player