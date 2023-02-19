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
local uiBackground = require('uiBackground')
local uiListItem = require('uiListItem')
local uiImage = require('uiImage')
local const = require('const')
local utils = require('utils')

-- create the class
local uiPartyList = classes.class(uiContainer)

local isDebug = false

local resX = windower.get_windower_settings().ui_x_res
local resY = windower.get_windower_settings().ui_y_res

function uiPartyList:init(layout, partyIndex, model, isUiLocked)
	if self.super:init() then
		self.layout = layout
		self.partyIndex = partyIndex
		self.model = model
		self.isUiLocked = isUiLocked -- blocks mouse drag and scale

		self.listItems = T{} -- ordered list by party list position, index range 0..5

		local scale = Settings:getUiScale(self.partyIndex)
		local pos = Settings:getUiPosition(self.partyIndex)

		local saveSettings = false
		local isMainParty = partyIndex == 0

		-- initialize the UI scale based on the screen resolution
		if scale.x == 0 and scale.y == 0 then
			scale.x = utils:round(resY / const.baseResY, 2)
			scale.y = scale.x

			if isMainParty then
				log('Initializing UI scale: ' .. scale.x)
				log('Type "//xp setup" to change UI position and scale using drag & drop and the mouse wheel.')
			end

			Settings:setUiScale(scale.x, scale.y, self.partyIndex)
			saveSettings = true
		end

		-- UI out of bounds check
		if pos.x >= resX then
			pos.x = resX - layout.columns * layout.columnWidth * scale.x

			log('UI out of bounds! Adjusting \'' .. Settings:partyIndexToName(self.partyIndex) .. '\' X position to ' .. tostring(pos.x))
			Settings:setUiPosition(pos.x, pos.y, self.partyIndex)
			saveSettings = true
		end

		if pos.y >= resY then
			pos.y = resY - layout.rows * layout.rowHeight * scale.y

			log('UI out of bounds! Adjusting \'' .. Settings:partyIndexToName(self.partyIndex) .. '\' Y position to ' .. tostring(pos.y))
			Settings:setUiPosition(pos.x, pos.y, self.partyIndex)
			saveSettings = true
		end

		if saveSettings then
			Settings:save()
		end

        self.posX = pos.x
        self.posY = pos.y
		self.scaleX = scale.x
		self.scaleY = scale.y

		self.background = self:addChild(uiBackground.new(layout.background))
		self.bgPos = utils:coord(layout.background.pos)

		self.imgMouse = self:addChild(uiImage.create())
		self.imgMouse:alpha(isDebug and 32 or 0)
		self.dragged = nil

		self.isCtrlDown = false

		-- register windower event handlers
		self.keyboardHandlerId = windower.register_event('keyboard', function(key, down)
			self:handleWindowerKeyboard(key, down)
		end)

		self.mouseHandlerId = windower.register_event('mouse', function(type, x, y, delta, blocked)
			return self:handleWindowerMouse(type, x, y, delta, blocked)
		end)
	end
end

function uiPartyList:dispose()
	if not self.isEnabled then return end

    windower.unregister_event(self.keyboardHandlerId)
    windower.unregister_event(self.mouseHandlerId)

	self.listItems:clear()

	self.super:dispose()
end

function uiPartyList:setModel(model)
	self.model = model
end

function uiPartyList:setUiLocked(isUiLocked)
	if not self.isEnabled then return end

	self.isUiLocked = isUiLocked
	for item in self.listItems:it() do
		item:setUiLocked(isUiLocked)
	end
end

function uiPartyList:update()
	if not self.isEnabled then return end

	local index = self.partyIndex
	if self.partyIndex > 0 and Settings.swapSingleAlliance and not self.model:hasAlliance2Members() then
		if self.partyIndex == 1 then -- swap index 1 and 2
			index = 2
		else
			index = 1
		end
	end

	-- update list items
	for i = 0, 5 do
		local player = self.model.parties[index][i]
		local item = self.listItems[i]

		if player then
			if not item then
				item = self:addChild(uiListItem.new(self.layout.listItem, player, self.isUiLocked, self.layout.columnWidth, self.layout.rowHeight))
				self.listItems[i] = item
			else
				item:setPlayer(player)
			end
		elseif item then
			item:dispose()
			self:removeChild(item)
			self.listItems[i] = nil
		end
	end

	local partySettings = Settings:getPartySettings(self.partyIndex)

	-- update the background
	local count = self.listItems:length()
	local rowCount = math.floor((count - 1) / self.layout.columns) + 1
	if partySettings.showEmptyRows then
		rowCount = self.layout.rows
	end
	local contentHeight = rowCount * self.layout.rowHeight + (rowCount - 1) * partySettings.itemSpacing

	self.background:setContentHeight(contentHeight)
	self.background:visible(count > 0, const.visFeature)
	self.imgMouse:size(self.layout.columns * self.layout.columnWidth, rowCount * self.layout.rowHeight)

	-- bottom alignment
	local alignBottomAdjustY = 0
	if partySettings.alignBottom then
		alignBottomAdjustY = -rowCount * self.layout.rowHeight
	end

	self.background:pos(self.bgPos.x, self.bgPos.y + alignBottomAdjustY)
	self.imgMouse:pos(0, alignBottomAdjustY)

	-- update the grid
	for i = 0, 5 do
		local item = self.listItems[i]
		if item then
			local row = math.floor(i / self.layout.columns)
    		local column = i % self.layout.columns

			local x = column * (self.layout.columnWidth + partySettings.itemSpacing)
			local y = row * (self.layout.rowHeight + partySettings.itemSpacing)

			item:pos(x, y + alignBottomAdjustY)
		end
	end

	self.super:update()
end

function uiPartyList:handleWindowerKeyboard(key, down)
    if key == 29 then -- ctrl
        self.isCtrlDown = down
    end
end

-- handle mouse interaction
function uiPartyList:handleWindowerMouse(type, x, y, delta, blocked)
    if blocked then return end

    if not self.isUiLocked then
        -- mouse drag
        if type == 0 then
            if self.dragged then
                local posX = x - self.dragged.x
                local posY = y - self.dragged.y

                if self.isCtrlDown then -- grid snap
                    posX = math.floor(posX / 10) * 10
                    posY = math.floor(posY / 10) * 10
                end

                if Settings:getPartySettings(self.partyIndex).alignBottom then
                    self:pos(posX, posY + self.imgMouse.height)
                else
                    self:pos(posX, posY)
                end
                return true
            end

        -- mouse left click
        elseif type == 1 then
            if self.imgMouse:hover(x, y) then
				self.dragged = { x = x - self.imgMouse.absolutePos.x, y = y - self.imgMouse.absolutePos.y }
                return true
            end

        -- mouse left release
        elseif type == 2 then
            if self.dragged then
				Settings:setUiPosition(self.posX, self.posY, self.partyIndex)

                log('\'' .. Settings:partyIndexToName(self.partyIndex) .. '\' position: ' .. self.posX .. ', ' .. self.posY)
                Settings:save()

                self.dragged = nil
                return true
            end

        -- mouse scroll
        elseif type == 10 then
            if self.imgMouse:hover(x, y) then
				local sx = math.max(0.25, self.scaleX + delta / 100)
				local sy = math.max(0.25, self.scaleY + delta / 100)
				self:scale(sx, sy)

				Settings:setUiScale(sx, sy, self.partyIndex)

				log('\'' .. Settings:partyIndexToName(self.partyIndex) .. '\' scale: ' .. sx .. ', ' .. sy)
                Settings:save()

				return true
            end
        end
    end

    return false
end

return uiPartyList