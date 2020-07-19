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

local bar = require('bar')

local listitem = {}
listitem.__index = listitem

function listitem:init()
	utils:log('Initializing party list element', 1)

	local obj = {}
	setmetatable(obj, listitem) -- make handle lookup
	
	obj.hidden = false
	
	obj.hpBar = bar:init()
	obj.mpBar = bar:init()
	obj.tpBar = bar:init()
	
	obj.hpText = utils:createText(layout.text.numbers.font, layout.text.numbers.size, true)
	obj.mpText = utils:createText(layout.text.numbers.font, layout.text.numbers.size, true)
	obj.tpText = utils:createText(layout.text.numbers.font, layout.text.numbers.size, true)
	
	obj.nameText = utils:createText(layout.text.name.font, layout.text.name.size)
	obj.zoneText = utils:createText(layout.text.zone.font, layout.text.zone.size)
	
	obj.jobText = utils:createText(layout.text.job.font, layout.text.job.size)
	obj.subJobText = utils:createText(layout.text.subJob.font, layout.text.subJob.size)
	
	obj.rangeInd = utils:createImage(layout.range.imgPath)
	obj.rangeInd:alpha(0)
	obj.rangeInd:show()
	obj.isInRange = false
	
	obj.cursor = utils:createImage(layout.cursor.imgPath)
	obj.cursor:alpha(0)
	obj.cursor:show()
	obj.isSelected = false
	obj.isSubTarget = false
	
	obj.buffImages = {}
	for i = 1, 32 do
		obj.buffImages[i] = utils:createImage(nil, false)
		obj.buffImages[i]:alpha(0)
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
	
	images.destroy(self.rangeInd)
	images.destroy(self.cursor)
	
	for i = 1, 32 do
		images.destroy(self.buffImages[i])
	end

	setmetatable(self, nil)
end

function listitem:pos(x, y)
	local hpPosX = x + layout.bar.offsetX
	local mpPosX = hpPosX + self.hpBar.size.width + layout.bar.spacingX
	local tpPosX = mpPosX + self.mpBar.size.width + layout.bar.spacingX
	
	self.hpBar:pos(hpPosX, y + layout.bar.offsetY)
	self.mpBar:pos(mpPosX, y + layout.bar.offsetY)
	self.tpBar:pos(tpPosX, y + layout.bar.offsetY)

	self.cursor:pos(hpPosX - layout.cursor.imgWidth + layout.cursor.offsetX, y + layout.cursor.offsetY)
	
	-- right aligned text coordinates start at the right side of the screen
	local screenResX = windower.get_windower_settings().x_res
	
    self.hpText:pos(hpPosX - screenResX + self.hpBar.size.width + layout.text.numbers.offsetX, y + layout.text.numbers.offsetY)
	self.mpText:pos(mpPosX - screenResX + self.hpBar.size.width + layout.text.numbers.offsetX, y + layout.text.numbers.offsetY)
	self.tpText:pos(tpPosX - screenResX + self.hpBar.size.width + layout.text.numbers.offsetX, y + layout.text.numbers.offsetY)
	
	self.nameText:pos(hpPosX + layout.text.name.offsetX, y + layout.text.name.offsetY)
	self.zoneText:pos(tpPosX + layout.text.zone.offsetX, y + layout.text.zone.offsetY)
	self.jobText:pos(hpPosX + layout.text.job.offsetX, y + layout.text.job.offsetY)
	self.subJobText:pos(hpPosX + layout.text.subJob.offsetX, y + layout.text.subJob.offsetY)
	
	self.rangeInd:pos(hpPosX + layout.range.offsetX, y + layout.range.offsetY)
	
	for i = 1, 32 do
		if i < 20 then -- wrap buffs to next line
			self.buffImages[i]:pos(tpPosX + (i - 1) * (layout.buffIcons.width + layout.buffIcons.spacingX) + layout.buffIcons.offsetX, 
			y + layout.buffIcons.offsetY)
		else
			self.buffImages[i]:pos(tpPosX + (i - 14) * (layout.buffIcons.width + layout.buffIcons.spacingX) + layout.buffIcons.offsetX, 
			y + layout.buffIcons.offsetY + layout.buffIcons.height + 1)
		end
	end
end

function listitem:update(player)
	if player then
		self:updateBarAndText(self.hpBar, self.hpText, player.hp, player.hpp, player.distance, false)
		self:updateBarAndText(self.mpBar, self.mpText, player.mp, player.mpp, player.distance, false)
		self:updateBarAndText(self.tpBar, self.tpText, player.tp, player.tpp, player.distance, true)
		
		self.nameText:text(player.name)
		self.zoneText:text(player.zone)
		
		self:select(player.isSelected, player.isSubTarget)
		self:updateBuffs(player.filteredBuffs)
		
		self.isInRange = settings.rangeIndicator > 0 and player.distance:sqrt() <= settings.rangeIndicator
		self:updateRange()
		
		if player.jobLvl > 0 then
			self.jobText:text(player.job..' '..tostring(player.jobLvl))
		else
			self.jobText:text('')
		end
		
		if player.subJobLvl > 0 then
			self.subJobText:text(player.subJob..' '..tostring(player.subJobLvl))
		else
			self.subJobText:text('')
		end
	end
end

function listitem:updateBarAndText(bar, text, val, valPercent, distance, isTp)
	bar:update(valPercent / 100)
	
	if val < 0 then
		text:text('?')
	else
		text:text(tostring(val))
	end
	
	if isTp and val >= 1000 then
		text:color(layout.text.fullTpColor.red, layout.text.fullTpColor.green, layout.text.fullTpColor.blue)
		text:alpha(layout.text.fullTpColor.alpha)
	else
		text:color(layout.text.color.red, layout.text.color.green, layout.text.color.blue)
		text:alpha(layout.text.color.alpha)
	end
	
	-- distance indication
	if distance:sqrt() > 50 then -- cannot target, over 50 distance, mob table not set
		bar:alpha(64)
	elseif distance:sqrt() > 20.79 then -- out of heal range
		bar:alpha(128)
	else
		bar:alpha(255)
	end
end

function listitem:select(isSel, isSub)
	if self.isSelected == isSel and self.isSubTarget == isSub then return end

	self.isSelected = isSel
	self.isSubTarget = isSub
	
	self:updateCursor()
end

function listitem:updateRange()
	if self.isInRange then
		self.rangeInd:alpha(255)
	else
		self.rangeInd:alpha(0)
	end
end

function listitem:updateCursor()
	if self.isSelected then
		self.cursor:alpha(255)
	elseif self.isSubTarget then
		self.cursor:alpha(128)
	else
		self.cursor:alpha(0)
	end
end

function listitem:updateBuffs(buffs)
	for i = 1, 32 do
		local image = self.buffImages[i]
		local buff = buffs[i]
		local current = self.currentBuffs[i]
	
		if current ~= buff then -- only update if actually changed
			if not buff or buff == 1000 or buff == 255 then
				image:path('')
				image:alpha(0)
			else
				image:path(layout.buffIcons.path .. tostring(buff) .. '.png')
				image:size(layout.buffIcons.width, layout.buffIcons.height)
				image:alpha(255)
			end
			
			self.currentBuffs[i] = buff
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
	
	self.rangeInd:show()
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
	
	self.rangeInd:hide()
	self.cursor:hide()
	
	for i = 1, 32 do
		self.buffImages[i]:hide()
	end
end

return listitem