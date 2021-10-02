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

local jobIcon = require('jobIcon')
local bar = require('bar')

local listitem = {}
listitem.__index = listitem

function listitem:init()
	utils:log('Initializing party list element', 1)

	local obj = {}
	setmetatable(obj, listitem) -- make handle lookup
	
	obj.hidden = false
	
	-- order of creation determines Z-order
	obj.jobIcon = jobIcon:init()
	
	obj.cursor = utils:createImage(layout.cursor.img, layout.scale)
	obj.cursor:opacity(0)
	obj.cursor:show()
	
	obj.hpBar = bar:init(layout.bar.hp)
	obj.mpBar = bar:init(layout.bar.mp)
	obj.tpBar = bar:init(layout.bar.tp)
	
	obj.hpText = utils:createText(layout.text.numbers, true)
	obj.mpText = utils:createText(layout.text.numbers, true)
	obj.tpText = utils:createText(layout.text.numbers, true)
	
	obj.nameText = utils:createText(layout.text.name)
	obj.zoneText = utils:createText(layout.text.zone, layout.text.zone.alignRight)
	
	obj.jobText = utils:createText(layout.text.job)
	obj.subJobText = utils:createText(layout.text.subJob)
	
	obj.leader = utils:createImage(layout.leader.img, layout.scale)
	obj.leader:opacity(0)
	obj.leader:show()
	
	obj.allianceLeader = utils:createImage(layout.leader.img, layout.scale)
	obj.allianceLeader:color(utils:colorFromHex(layout.leader.allianceColor))
	obj.allianceLeader:opacity(0)
	obj.allianceLeader:show()
	
	obj.quarterMaster = utils:createImage(layout.leader.img, layout.scale)
	obj.quarterMaster:color(utils:colorFromHex(layout.leader.quarterMasterColor))
	obj.quarterMaster:opacity(0)
	obj.quarterMaster:show()
	
	obj.rangeInd = utils:createImage(layout.range.img, layout.scale)
	obj.rangeInd:opacity(0)
	obj.rangeInd:show()
	
	obj.rangeIndFar = utils:createImage(layout.rangeFar.img, layout.scale)
	obj.rangeIndFar:opacity(0)
	obj.rangeIndFar:show()
	
	obj.numbersColor = utils:colorFromHex(layout.text.numbers.color)
	obj.tpFullColor = utils:colorFromHex(layout.text.tpFullColor)
	obj.hpYellowColor = utils:colorFromHex(layout.text.hpYellowColor)
	obj.hpOrangeColor = utils:colorFromHex(layout.text.hpOrangeColor)
	obj.hpRedColor = utils:colorFromHex(layout.text.hpRedColor)
	
	obj.barOffset = utils:coord(layout.bar.offset)
	obj.leaderOffset = utils:coord(layout.leader.offset)
	obj.rangeOffset = utils:coord(layout.range.offset)
	obj.rangeFarOffset = utils:coord(layout.rangeFar.offset)
	obj.cursorOffset = utils:coord(layout.cursor.offset)
	obj.buffOffset = utils:coord(layout.buffIcons.offset)
	obj.buffSpacing = utils:coord(layout.buffIcons.spacing)
	obj.buffSize = utils:coord(layout.buffIcons.size)
	
	obj.numbersOffset = utils:coord(layout.text.numbers.offset)
	obj.nameOffset = utils:coord(layout.text.name.offset)
	obj.zoneOffset = utils:coord(layout.text.zone.offset)
	obj.jobOffset = utils:coord(layout.text.job.offset)
	obj.subJobOffset = utils:coord(layout.text.subJob.offset)
	obj.jobIconOffset = utils:coord(layout.jobIcon.offset)
	
	obj.buffImages = {}
	for i = 1, 32 do
		obj.buffImages[i] = img:init('', obj.buffSize.x, obj.buffSize.y, layout.scale)
		obj.buffImages[i]:opacity(0)
		obj.buffImages[i]:show()
	end
	obj.currentBuffs = {}
	
	return obj
end

function listitem:dispose()
	utils:log('Disposing party list element', 1)
	
	self.hpBar:dispose()
	self.mpBar:dispose()
	self.tpBar:dispose()
	
	texts.destroy(self.hpText)
	texts.destroy(self.mpText)
	texts.destroy(self.tpText)
	
	texts.destroy(self.nameText)
	texts.destroy(self.zoneText)
	
	texts.destroy(self.jobText)
	texts.destroy(self.subJobText)
	
	self.jobIcon:dispose()
	
	self.leader:dispose()
	self.allianceLeader:dispose()
	self.quarterMaster:dispose()
	
	self.rangeInd:dispose()
	self.rangeIndFar:dispose()
	self.cursor:dispose()
	
	for i = 1, 32 do
		self.buffImages[i]:dispose()
	end

	setmetatable(self, nil)
end

function listitem:pos(x, y)
	local hpPosX = x + self.barOffset.x
	local mpPosX = hpPosX + self.hpBar.size.width + layout.bar.spacingX
	local tpPosX = mpPosX + self.mpBar.size.width + layout.bar.spacingX
	
	self.hpBar:pos(hpPosX, y + self.barOffset.y)
	self.mpBar:pos(mpPosX, y + self.barOffset.y)
	self.tpBar:pos(tpPosX, y + self.barOffset.y)

	self.cursor:pos(x + self.cursorOffset.x, y + self.cursorOffset.y)
	
	-- right aligned text coordinates start at the right side of the screen
	local screenResX = windower.get_windower_settings().ui_x_res
	
	self.hpText:pos(hpPosX - screenResX + self.hpBar.size.width + self.numbersOffset.x, y + self.numbersOffset.y)
	self.mpText:pos(mpPosX - screenResX + self.mpBar.size.width + self.numbersOffset.x, y + self.numbersOffset.y)
	self.tpText:pos(tpPosX - screenResX + self.tpBar.size.width + self.numbersOffset.x, y + self.numbersOffset.y)
	
	self.nameText:pos(hpPosX + self.nameOffset.x, y + self.nameOffset.y)
	self.jobText:pos(hpPosX + self.jobOffset.x, y + self.jobOffset.y)
	self.subJobText:pos(hpPosX + self.subJobOffset.x, y + self.subJobOffset.y)
	
	self.jobIcon:pos(x + self.jobIconOffset.x, y + self.jobIconOffset.y)
	
	if layout.text.zone.alignRight then
		self.zoneText:pos(tpPosX + self.tpBar.size.width - screenResX + self.zoneOffset.x, y + self.zoneOffset.y)
	else
		self.zoneText:pos(tpPosX + self.zoneOffset.x, y + self.zoneOffset.y)
	end
	
	self.leader:pos(hpPosX + self.leaderOffset.x, y + self.leaderOffset.y)
	self.allianceLeader:pos(self.leader:pos().x, self.leader:pos().y - self.allianceLeader:scaledSize().height)
	self.quarterMaster:pos(self.allianceLeader:pos().x, self.allianceLeader:pos().y - self.quarterMaster:scaledSize().height)
	
	self.rangeInd:pos(hpPosX + self.rangeOffset.x, y + self.rangeOffset.y)
	self.rangeIndFar:pos(hpPosX + self.rangeFarOffset.x, y + self.rangeFarOffset.y)
	
	local direction = 1
	if layout.buffIcons.alignRight then
		direction = -1
	end
	
	for i = 1, 32 do
		if i <= layout.buffIcons.wrap then -- wrap buffs to next line
			self.buffImages[i]:pos(
				tpPosX + direction * (i - 1) * (self.buffImages[i]:scaledSize().width + self.buffSpacing.x) + self.buffOffset.x, 
				y + self.buffOffset.y)
		else
			self.buffImages[i]:pos(
				tpPosX + direction * (i - layout.buffIcons.wrap + layout.buffIcons.wrapOffset - 1) * 
				(self.buffImages[i]:scaledSize().width + self.buffSpacing.x) + self.buffOffset.x, 
				y + self.buffOffset.y + self.buffImages[i]:scaledSize().height + self.buffSpacing.y)
		end
	end
end

function listitem:update(player)
	if player then
		local isOutsideZone = player.zone and player.zone ~= windower.ffxi.get_info().zone
	
		self:updateBarAndText(self.hpBar, self.hpText, player.hp, player.hpp, player.distance, isOutsideZone, 'hp')
		self:updateBarAndText(self.mpBar, self.mpText, player.mp, player.mpp, player.distance, isOutsideZone, 'mp')
		self:updateBarAndText(self.tpBar, self.tpText, player.tp, player.tpp, player.distance, isOutsideZone, 'tp')
		
		if player.name then
			self.nameText:text(player.name)
		else
			self.nameText:text('???')
		end
		
		self.jobIcon:update(player, isOutsideZone)
		self:updateZone(player, isOutsideZone)
		self:updateJob(player, isOutsideZone)
		self:updateLeader(player)
		self:updateRange(player, isOutsideZone)
		self:updateCursor(player, isOutsideZone)
		self:updateBuffs(player.filteredBuffs, isOutsideZone)
	end
end

function listitem:updateBarAndText(bar, text, val, valPercent, distance, isOutsideZone, barType)
	if isOutsideZone then
		val = nil
		valPercent = nil
		distance = nil
	end

	if not val then val = -1 end
	if not valPercent then valPercent = 0 end
	
	bar:update(valPercent / 100)
	
	if val < 0 then
		text:text('?')
	else
		text:text(tostring(val))
	end
	
	local color = self.numbersColor
	if barType == 'hp' then
		if val >= 0 then
			if valPercent < 25 then
				color = self.hpRedColor
			elseif valPercent < 50 then
				color = self.hpOrangeColor
			elseif valPercent < 75 then
				color = self.hpYellowColor
			end
		end
	elseif barType == 'tp' then
		if val >= 1000 then
			color = self.tpFullColor
		end	
	end
	
	text:color(color.r, color.g, color.b)
	text:alpha(color.a)
	
	-- distance indication
	if distance and distance:sqrt() > 50 then -- cannot target, over 50 distance, mob table not set
		bar:opacity(0.25)
	elseif distance and distance:sqrt() > 20.79 then -- out of heal range
		bar:opacity(0.5)
	else
		bar:opacity(1)
	end
end

function listitem:updateZone(player, isOutsideZone)
	local zoneString = ''
	
	if player.zone and isOutsideZone then
		if layout.text.zone.short then
			zoneString = '('..res.zones[player.zone]['search']..')'
		else
			zoneString = '('..res.zones[player.zone].name..')'
		end
	end
	
	self.zoneText:text(zoneString)
end

function listitem:updateJob(player, isOutsideZone)
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
	
	self.jobText:text(jobString)
	self.subJobText:text(subJobString)
end

function listitem:updateLeader(player)
	if player.isLeader then
		self.leader:opacity(1)
	else
		self.leader:opacity(0)
	end
	
	if player.isAllianceLeader then
		self.allianceLeader:opacity(1)
	else
		self.allianceLeader:opacity(0)
	end
	
	if player.isQuarterMaster then
		self.quarterMaster:opacity(1)
	else
		self.quarterMaster:opacity(0)
	end
end

function listitem:updateRange(player, isOutsideZone)
	local opacity = 0
	local opacityFar = 0

	if player.distance and not isOutsideZone then
		if settings.rangeIndicator > 0 and player.distance:sqrt() <= settings.rangeIndicator then
			opacity = 1
			opacityFar = 0
		elseif settings.rangeIndicatorFar > 0 and player.distance:sqrt() <= settings.rangeIndicatorFar then
			opacity = 0
			opacityFar = 1
		end
	end
	
	self.rangeInd:opacity(opacity)
	self.rangeIndFar:opacity(opacityFar)
end

function listitem:updateCursor(player, isOutsideZone)
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

function listitem:updateBuffs(buffs, isOutsideZone)
	if not buffs or isOutsideZone then
		buffs = T{}
	end

	if table.equals(buffs, self.currentBuffs) then return end
	self.currentBuffs = table.copy(buffs)
	
	for i = 1, 32 do
		local buff = buffs[i]
		
		local image = nil
		if layout.buffIcons.alignRight then
			local count = buffs:length()
			if count > layout.buffIcons.wrap then -- more buffs than the top line
				if i <= layout.buffIcons.wrap then -- top line
					image = self.buffImages[layout.buffIcons.wrap - i + 1]
				elseif i <= count then -- bottom line
					image = self.buffImages[count - i + layout.buffIcons.wrap + 1]
				end
			else
				image = self.buffImages[count - i + 1]
			end
		end
		
		if not image then
			image = self.buffImages[i]
		end
		
		if buff then
			image:path(windower.addon_path .. layout.buffIcons.path .. tostring(buff) .. '.png')
			image:opacity(1)
		else
			image:path('')
			image:opacity(0)
		end
	end
end

function listitem:show()
	self.hpBar:show()
	self.mpBar:show()
	self.tpBar:show()
	
	self.hpText:show()
	self.mpText:show()
	self.tpText:show()
	
	self.nameText:show()
	self.zoneText:show()
	
	self.jobText:show()
	self.subJobText:show()
	
	self.jobIcon:show()
	
	self.leader:show()
	self.allianceLeader:show()
	self.quarterMaster:show()
	
	self.rangeInd:show()
	self.rangeIndFar:show()
	self.cursor:show()
	
	for i = 1, 32 do
		self.buffImages[i]:show()
	end
end

function listitem:hide()
	self.hpBar:hide()
	self.mpBar:hide()
	self.tpBar:hide()
	
	self.hpText:hide()
	self.mpText:hide()
	self.tpText:hide()
	
	self.nameText:hide()
	self.zoneText:hide()
	
	self.jobText:hide()
	self.subJobText:hide()
	
	self.jobIcon:hide()
	
	self.leader:hide()
	self.allianceLeader:hide()
	self.quarterMaster:hide()
	
	self.rangeInd:hide()
	self.rangeIndFar:hide()
	self.cursor:hide()
	
	for i = 1, 32 do
		self.buffImages[i]:hide()
	end
end

return listitem