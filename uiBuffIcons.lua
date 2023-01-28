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

-- imports
local classes = require('classes')
local uiContainer = require('uiContainer')
local uiImage = require('uiImage')
local const = require('const')
local utils = require('utils')

-- create the class, derive from uiContainer
local uiBuffIcons = classes.class(uiContainer)

function uiBuffIcons:init(layout, player)
	if self.super:init(layout) then
		self.layout = layout
		self.player = player

		self.spacing = utils:coord(layout.spacing)
		self.size = utils:coord(layout.size)

		self.currentBuffs = {}
        self.buffImages = {}

		if not self:validateLayout(self.layout) then
			self.isEnabled = false
			return
		end

		self.maxBuffCount = self:getMaxBuffCount()

		for i = 1, self.maxBuffCount do
			-- row and column start at index 1
			local row = self:getRow(i)
			if not row then break end -- cut off any icons that exceed row definitions from the layout

			local column = self:getColumn(i, row)
			local iconOffset = tonumber(layout.offsetByRow[row]) * (self.size.x + self.spacing.x)

			local posX = iconOffset + (column - 1) * (self.size.x + self.spacing.x)
			if self.layout.alignRight then
				posX = posX - self.maxBuffCount * (self.size.x + self.spacing.x)
			end

			local posY = (row - 1) * self.size.y + (row - 1) * self.spacing.y
			local size = utils:coord(layout.size)
			local color = utils:colorFromHex(layout.color)

			self.buffImages[i] = self:addChild(uiImage.create('', size.x, size.y, posX, posY))
			self.buffImages[i]:color(color)
			self.buffImages[i]:hide(const.visFeature)
        end
	end
end

function uiBuffIcons:setPlayer(player)
	self.player = player
end

function uiBuffIcons:validateLayout(layout)
	-- the config library loads lists with single entires as numbers, apply a fix here as the rest of the code expects a list
	local singleEntry = false
	if type(layout.numIconsByRow) == 'number' then
		layout.numIconsByRow = L{ layout.numIconsByRow }
		singleEntry = true
	end
	if type(layout.offsetByRow) == 'number' then
		layout.offsetByRow = L{ layout.offsetByRow }
		singleEntry = true
	end
	if singleEntry then
		warning('To prevent the addon load warning when using a single buff icon row, add an empty row at the end. Example: 32,0')
	end

	-- check that number of rows in both lists is equal
	if layout.numIconsByRow:length() ~= layout.offsetByRow:length() then
		error('Layout invalid! Lists numIconsByRow and offsetByRow must have the same number of entries!')
		return false
	end

	return true
end

-- gets the row index for the specified icon index, returns nil if the icon won't fit in the defined rows
function uiBuffIcons:getRow(iconIndex)
	for row = 1, self.layout.numIconsByRow:length() do
		local numIcons = tonumber(self.layout.numIconsByRow[row]) -- numbers in L{} lists are loaded as strings by the config library

		if iconIndex <= numIcons then return row end
		iconIndex = iconIndex - numIcons
	end

	return nil
end

-- gets the column for the specified icon index, correct row must be set for this icon
function uiBuffIcons:getColumn(iconIndex, row)
	if not row then return nil end

	local column = iconIndex - self:getSumOfPreviousRows(row)
	return column
end

-- gets the sum of all icons in the rows before the specified row
function uiBuffIcons:getSumOfPreviousRows(row)
	local sum = 0
	if row > 1 then
		for r = 1, row - 1 do
			sum = sum + tonumber(self.layout.numIconsByRow[r])
		end
	end

	return sum
end

 -- maximum number of icons we can display, either capped by row definitions or the game's limit of 32
function uiBuffIcons:getMaxBuffCount()
	local count = 0
	for row = 1, self.layout.numIconsByRow:length() do
		local numIcons = tonumber(self.layout.numIconsByRow[row])
		count = count + numIcons
	end

	return math.min(const.maxBuffs, count)
end

function uiBuffIcons:update()
	if not self.isEnabled then return end

	local buffs = self.player.filteredBuffs
	if not buffs or self.player.isOutsideZone then
		buffs = T{}
	end

	if not table.equals(buffs, self.currentBuffs) then
		self.currentBuffs = table.copy(buffs)

		for i = 1, self.maxBuffCount do -- iterate through all images
			local buff
			local image = self.buffImages[i]

			-- right aligned: find the index of the buff to place in the current image
			if self.layout.alignRight then
				local row = self:getRow(i)
				if not row then break end -- cut off any icons that exceed row definitions from the layout

				local numIcons = self.layout.numIconsByRow[row] -- maximum number of icons that fit in this row
				local sumPreviousRows = self:getSumOfPreviousRows(row)

				local totalBuffCount = math.min(buffs:length(), self.maxBuffCount) -- total number of active buffs to display
				local buffCountInRow = math.min(totalBuffCount - sumPreviousRows, numIcons) -- number of active buffs to display in current row

				local indexOffset = buffCountInRow - numIcons -- offset between image index and buff index
				local index = i + indexOffset

				if index - sumPreviousRows > 0 then -- make sure that the indexOffset doesn't push us to the previous rows
					buff = buffs[index]
				else
					buff = nil -- clear the image
				end
			else -- left aligned: buff index = image index
				buff = buffs[i]
			end

			if buff then
				image:path(self.layout.path .. tostring(buff) .. '.png')
				image:show(const.visFeature)
			else
				image:path('')
				image:hide(const.visFeature)
			end
		end
	end

	self.super:update()
end

return uiBuffIcons