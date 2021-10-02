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

local jobs = require('jobs')

local player = {}
player.__index = player

-- either parameter can be nil, but not both
function player:init(name, id, mdl)
	if not name and not id then
		utils:log('Cannot init player without name or ID!', 4)
		return nil
	end
	
	if not mdl then
		utils:log('Cannot init player without model!', 4)
		return
	end

	local initText = ''
	if name then
		initText = initText .. '. Name = ' .. name
	end
	if id then
		initText = initText .. '. ID = ' .. tostring(id)
	end
	utils:log('Initializing player' .. initText, 2)

	local obj = {}
	setmetatable(obj, player) -- make handle lookup

	obj.name = name
	obj.id = id
	obj.model = mdl
	
	return obj
end

function player:dispose()
	local displayName = '???'
	if (self.name) then
		displayName = self.name
	end
	utils:log('Disposing player '..displayName, 2)
	
	setmetatable(self, nil)
end

-- merges data from other player into self
function player:merge(other)
	utils:log('Merging player ' .. utils:toString(other.name) .. '(' .. utils:toString(other.id) .. ')' ..
			  ' into ' .. utils:toString(self.name) .. '(' .. utils:toString(self.id) .. ')', 2)

	if other.name then self.name = other.name end
	if other.id and other.id > 0 then self.id = other.id end
	
	if other.hp then self.hp = other.hp end
	if other.mp then self.mp = other.mp end
	if other.tp then self.tp = other.tp end
	if other.hpp then self.hpp = other.hpp end
	if other.mpp then self.mpp = other.mpp end
	if other.tpp then self.tpp = other.tpp end
	
	if other.isSelected ~= nil then self.isSelected = other.isSelected end
	if other.isSubTarget ~= nil then self.isSubTarget = other.isSubTarget end
	if other.distance then self.distance = other.distance end
	
	if other.isTrust ~= nil then self.isTrust = other.isTrust end
	
	if other.job then self.job = other.job end
	if other.jobLvl then self.jobLvl = other.jobLvl end
	if other.subJob then self.subJob = other.subJob end
	if other.subJobLvl then self.subJobLvl = other.subJobLvl end
	
	if other.buffs then self.buffs = other.buffs end
	if other.filteredBuffs then self.filteredBuffs = other.filteredBuffs end
	
	if other.isLeader ~= nil then self.isLeader = other.isLeader end
	if other.isAllianceLeader ~= nil then self.isAllianceLeader = other.isAllianceLeader end
	if other.isQuarterMaster ~= nil then self.isQuarterMaster = other.isQuarterMaster end
	
	return self
end

function player:update(member, zone, target, subtarget)
	self.name = member.name

	self.hp = member.hp
	self.mp = member.mp
	self.tp = member.tp
	self.hpp = member.hpp
	self.mpp = member.mpp
	self.tpp = math.min(member.tp / 10, 100)

	self.isSelected = target and member.mob and target.id == member.mob.id
	self.isSubTarget = subtarget and member.mob and subtarget.id == member.mob.id
	
	self.zone = member.zone
	
	if member.mob then
		self.id = member.mob.id
		self.distance = member.mob.distance
		self.isTrust = member.mob.is_npc
		
		if self.isTrust and (self.job == nil or self.jobLvl == nil or self.jobLvl == 0) then -- optimization: only update if job/lvl not set
			local trustInfo = jobs:getTrustInfo(self.name, member.mob.models[1])
			if trustInfo then
				self.job = trustInfo.job
				self.subJob = trustInfo.subJob
				
				local partyLeader = self.model:getPartyLeader()
				if partyLeader and partyLeader.jobLvl then
					self.jobLvl = partyLeader.jobLvl
					self.subJobLvl = math.max(1, math.floor(partyLeader.jobLvl / 2))
				end
			else
				utils:log('Failed to get trust info for ' .. self.name, 4)
			end
		end
	else
		self.distance = 99999 -- no mob means player too far to target
	end
	
	local mainPlayer = windower.ffxi.get_player()
	if member.name == mainPlayer.name then -- set buffs and job info for main player
		self:updateBuffs(mainPlayer.buffs)
		self.job = res.jobs[mainPlayer.main_job_id].ens
		self.jobLvl = mainPlayer.main_job_level
		
		if mainPlayer.sub_job_id then -- only if subjob is set
			self.subJob = res.jobs[mainPlayer.sub_job_id].ens
			self.subJobLvl = mainPlayer.sub_job_level
		end
	end
end

function player:updateBuffs(buffs)
	self.buffs = buffs -- list of all buffs this player has
	self.filteredBuffs = T{} -- list of filtered buffs to be displayed
	
	if not buffs then return end
	
	for i = 1, 32 do
		buff = buffs[i]
		
		if (settings.buffs.filterMode == 'blacklist' and settings.buffFilters[buff]) or 
		   (settings.buffs.filterMode == 'whitelist' and not settings.buffFilters[buff]) then
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

function player:refreshFilteredBuffs()
	self:updateBuffs(self.buffs)
end

function player:updateLeaderFromFlags(flags)
	self.isLeader = utils:bitAnd(flags, 4) > 0
	self.isAllianceLeader = utils:bitAnd(flags, 8) > 0
	self.isQuarterMaster = utils:bitAnd(flags, 16) > 0
end

function player:updateJobFromPacket(packet)
	-- these can contain NON 0 / NON 0 when the party member is out of zone
	-- seem to always get NON 0 / NON 0 if character has no SJ
	local mJob = packet['Main job']
	local mJobLvl = packet['Main job level']
	local sJob =  packet['Sub job']
	local sJobLvl = packet['Sub job level']
	
	if (mJob and mJobLvl and sJob and sJobLvl and mJobLvl > 0) then
		self.job = res.jobs[mJob].ens
		self.jobLvl = mJobLvl
		self.subJob = res.jobs[sJob].ens
		self.subJobLvl = sJobLvl
		
		utils:log('Set job info: '.. self.job ..tostring(mJobLvl)..'/'.. self.subJob ..tostring(sJobLvl), 0)
	else
		utils:log('Unusable job info. Dropping.', 0)
	end
end

function player:createSetupData(job, subJob)
	self.hp = math.random(500,2500)
	self.mp = math.random(500,1500)
	self.tp = math.random(0,3000)
	self.hpp = self.hp / 2500 * 100
	self.mpp = math.random(50, 100)
	self.tpp = math.min(self.tp / 1000 * 100, 100)
	
	self.zone = windower.ffxi.get_info().zone
	
	self.isSelected = false
	self.isSubTarget = false
	self.distance = math.random(0, 400)
	self.isTrust = false
	
	self.job = job
	self.jobLvl = 99
	self.subJob = subJob
	self.subJobLvl = 49
	
	self.buffs = {}
	
	for i = 1, 32 do
		self.buffs[i] = math.random(1, 629)
	end
	
	self:updateBuffs(self.buffs)
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

return player