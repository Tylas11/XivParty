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
local jobs = require('jobs')
local buffOrder = require('buffOrder')
local const= require('const')
local utils = require('utils')

-- create the class
local player = classes.class()

-- either parameter name or id can be nil, but not both
-- model can be nil, only required for party leader lookup for trust levels
function player:init(name, id, model)
	if not name and not id then
		utils:log('player:init missing parameter name or id!', 4)
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

	self.name = name
	self.id = id
	self.model = model
end

-- merges data from other player into self
function player:merge(other)
	utils:log('Merging player ' .. utils:toString(other.name) .. '(' .. utils:toString(other.id) .. ')' ..
			  ' into ' .. utils:toString(self.name) .. '(' .. utils:toString(self.id) .. ')', 2)

	if other.name ~= nil then self.name = other.name end
	if other.id ~= nil and other.id > 0 then self.id = other.id end

	if other.hp ~= nil then self.hp = other.hp end
	if other.mp ~= nil then self.mp = other.mp end
	if other.tp ~= nil then self.tp = other.tp end
	if other.hpp ~= nil then self.hpp = other.hpp end
	if other.mpp ~= nil then self.mpp = other.mpp end
	if other.tpp ~= nil then self.tpp = other.tpp end

	if other.isSelected ~= nil then self.isSelected = other.isSelected end
	if other.isSubTarget ~= nil then self.isSubTarget = other.isSubTarget end
	if other.distance ~= nil then self.distance = other.distance end
	if other.zone ~= nil then self.zone = other.zone end
	if other.isOutsideZone ~= nil then self.isOutsideZone = other.isOutsideZone end
	if other.isInCastingRange ~= nil then self.isInCastingRange = other.isInCastingRange end
	if other.isInTargetingRange ~= nil then self.isInTargetingRange = other.isInTargetingRange end

	if other.isTrust ~= nil then self.isTrust = other.isTrust end

	if other.job ~= nil then self.job = other.job end
	if other.jobLvl ~= nil then self.jobLvl = other.jobLvl end
	if other.subJob ~= nil then self.subJob = other.subJob end
	if other.subJobLvl ~= nil then self.subJobLvl = other.subJobLvl end

	if other.buffs ~= nil then self.buffs = other.buffs end
	if other.filteredBuffs ~= nil then self.filteredBuffs = other.filteredBuffs end

	if other.isLeader ~= nil then self.isLeader = other.isLeader end
	if other.isAllianceLeader ~= nil then self.isAllianceLeader = other.isAllianceLeader end
	if other.isQuarterMaster ~= nil then self.isQuarterMaster = other.isQuarterMaster end

	return self
end

function player:update(member, target, subtarget)
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
	self.isOutsideZone = self.zone and self.zone ~= windower.ffxi.get_info().zone

	self.distance = nil

	if member.mob then
		self.id = member.mob.id
		self.isTrust = member.mob.is_npc

		if member.mob.distance then
			self.distance = member.mob.distance:sqrt()
		end

		if self.isTrust and (self.job == nil or self.jobLvl == nil or self.jobLvl == 0) then -- optimization: only update if job/lvl not set
			local trustInfo = jobs:getTrustInfo(self.name, member.mob.models[1])
			if trustInfo then
				self.job = trustInfo.job
				self.subJob = trustInfo.subJob

				if self.model then
					local partyLeader = self.model:findPartyLeader() -- get leader of main party
					if partyLeader and partyLeader.jobLvl then
						self.jobLvl = partyLeader.jobLvl
						self.subJobLvl = math.max(1, math.floor(partyLeader.jobLvl / 2))
					end
				end
			end
		end
	end

	self.isInCastingRange = self.distance and self.distance < const.castRange
	self.isInTargetingRange = self.distance and self.distance < const.targetRange

	local mainPlayer = windower.ffxi.get_player()
	self.isMainPlayer = self.name == mainPlayer.name

	if self.isMainPlayer then -- set buffs and job info for main player
		self:updateBuffs(mainPlayer.buffs)
		self.job = res.jobs[mainPlayer.main_job_id].ens
		self.jobLvl = mainPlayer.main_job_level

		if mainPlayer.sub_job_id then -- only if subjob is set
			self.subJob = res.jobs[mainPlayer.sub_job_id].ens
			self.subJobLvl = mainPlayer.sub_job_level
		end
	end
end

local function buffOrderCompare(a, b)
	local orderA = buffOrder[a]
	local orderB = buffOrder[b]

	if not orderA then
		return false
	elseif not orderB then
		return true
	end

	return buffOrder[a] < buffOrder[b]
end

function player:updateBuffs(buffs)
	self.buffs = buffs -- list of all buffs this player has
	self.filteredBuffs = T{} -- list of filtered buffs to be displayed

	if not buffs then return end

	for i = 1, const.maxBuffs do
		local buff = buffs[i]

		if (Settings.buffs.filterMode == 'blacklist' and Settings.buffFilters[buff]) or
		   (Settings.buffs.filterMode == 'whitelist' and not Settings.buffFilters[buff]) then
			buff = nil
		end

		if buff then
			self.filteredBuffs:append(buff)
		end
	end

	if Settings.buffs.customOrder then
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

function player:createSetupData(job, subJob, isMainParty)
	self.hp = math.random(500,2500)
	self.mp = math.random(500,1500)
	self.tp = math.random(0,3000)
	self.hpp = self.hp / 2500 * 100
	self.mpp = math.random(50, 100)
	self.tpp = math.min(self.tp / 1000 * 100, 100)

	self.zone = windower.ffxi.get_info().zone

	self.isSelected = false
	self.isSubTarget = false
	self.distance = math.random(0, 25)
	self.isInCastingRange = self.distance < const.castRange
	self.isInTargetingRange = self.distance < const.targetRange
	self.isTrust = false

	self.job = job
	self.jobLvl = 99
	self.subJob = subJob
	self.subJobLvl = 49

	self.buffs = {}

	if isMainParty then
		for i = 1, const.maxBuffs do
			self.buffs[i] = math.random(1, 631)
		end
	end

	self:updateBuffs(self.buffs)
end

return player