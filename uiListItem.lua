--[[
	Copyright © 2022, Tylas
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

-- imports
local classes = require('classes')
local uiContainer = require('uiContainer')
local uiJobIcon = require('uiJobIcon')
local uiStatusBar = require('uiStatusBar')
local uiLeader= require('uiLeader')
local uiRange = require('uiRange')
local uiBuffIcons = require('uiBuffIcons')
local uiText = require('uiText')
local uiImage = require('uiImage')
local const = require('const')

-- create the class, derive from uiContainer
local uiListItem = classes.class(uiContainer)

function uiListItem:init(layout)
	if self.super:init(layout.listItem) then
		self.layout = layout

		self.cursor = self:addChild(uiImage.new(layout.cursor))
		self.cursor:opacity(0)

		self.hpBar = self:addChild(uiStatusBar.new(layout.hp, const.barTypeHp))
		self.mpBar = self:addChild(uiStatusBar.new(layout.mp, const.barTypeMp))
		self.tpBar = self:addChild(uiStatusBar.new(layout.tp, const.barTypeTp))

		self.jobIcon = self:addChild(uiJobIcon.new(layout.jobIcon))

		self.nameText = self:addChild(uiText.new(layout.text.name))
		self.zoneText = self:addChild(uiText.new(layout.text.zone))

		self.jobText = self:addChild(uiText.new(layout.text.job))
		self.subJobText = self:addChild(uiText.new(layout.text.subJob))

		self.leader = self:addChild(uiLeader.new(layout.leader))

		self.range = self:addChild(uiRange.new(layout.range))
		self.buffIcons = self:addChild(uiBuffIcons.new(layout.buffIcons))
	end
end

function uiListItem:update(player)
	if not self.isEnabled or not player then return end

	local isOutsideZone = player.zone and player.zone ~= windower.ffxi.get_info().zone -- TODO: this is needed quite often, maybe it should be a property of player

	self.hpBar:update(player, isOutsideZone)
	self.mpBar:update(player, isOutsideZone)
	self.tpBar:update(player, isOutsideZone)

	if player.name then
		self.nameText:update(player.name)
	else
		self.nameText:update('???')
	end

	self.jobIcon:update(player, isOutsideZone)
	self:updateZone(player, isOutsideZone)
	self:updateJob(player, isOutsideZone)
	self.leader:update(player)
	self.range:update(player, isOutsideZone)
	self:updateCursor(player, isOutsideZone)
	self.buffIcons:update(player, isOutsideZone)
end

function uiListItem:updateZone(player, isOutsideZone)
	local zoneString = ''
	
	if player.zone and isOutsideZone then
		if self.layout.text.zone.short then
			zoneString = '('..res.zones[player.zone]['search']..')'
		else
			zoneString = '('..res.zones[player.zone].name..')'
		end
	end
	
	self.zoneText:update(zoneString)
end

function uiListItem:updateJob(player, isOutsideZone)
	local jobString = ''
	local subJobString = ''
	
	if not isOutsideZone then
		if player.job then
			jobString = player.job
			if player.jobLvl then
				jobString = jobString .. ' ' .. tostring(player.jobLvl)
			end
		end
		
		if player.subJob and player.subJob ~= 'MON' then
			subJobString = player.subJob
			if player.subJobLvl then
				subJobString = subJobString .. ' ' .. tostring(player.subJobLvl)
			end
		end
	end
	
	self.jobText:update(jobString)
	self.subJobText:update(subJobString)
end

function uiListItem:updateCursor(player, isOutsideZone)
	local opacity = 0
	
	if not isOutsideZone then
		if player.isSelected then
			opacity = 1
		elseif player.isSubTarget then
			opacity = 0.5
		end
	end
	
	self.cursor:opacity(opacity)
end

return uiListItem