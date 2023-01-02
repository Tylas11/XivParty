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

function uiPartyList:init(party, partySettings, layout, isMainParty)
    if not party then
		utils:log('uiPartyList:init missing parameter party!', 4)
		return
	end

    if not partySettings then
		utils:log('uiPartyList:init missing parameter partySettings!', 4)
		return
	end

	-- TODO: validate layout, rows * columns must always equal 6! (is this technically necessary?)

	if self.super:init(layout) then
		self.party = party -- list of party members from model.party (or one of the alliances)
		self.partySettings = partySettings
		self.layout = layout

		self.listItems = T{} -- ordered list by party list position, index range 0..5
		self.setupParty = nil -- list of party members used in setup mode
		self.isSetupEnabled = false
		self.isCtrlDown = false
		self.hidden = false

		local scale = utils:coord(partySettings.scale)
		local pos = utils:coord(partySettings.pos)

		-- initialize the UI position and scale based on the screen resolution
		if scale.x == 0 and scale.y == 0 then
			local resY = windower.get_windower_settings().ui_y_res
			scale.x = utils:round(resY / const.baseResY, 2)
			scale.y = scale.x

			pos.x = pos.x * scale.x
			pos.y = pos.y * scale.y

			if isMainParty then
				log('Initializing UI scale: ' .. scale.x)
				log('Type "//xp setup" to change UI position and scale using drag & drop and the mouse wheel.')
			end

			partySettings.scale = L{ scale.x, scale.y }
			Settings:save()
		end

        self.posX = pos.x
        self.posY = pos.y
		self.scaleX = scale.x
		self.scaleY = scale.y

		self.background = self:addChild(uiBackground.new(layout.background))
		self.bgPos = utils:coord(layout.background.pos)

		self.dragImage = self:addChild(uiImage.create())
		self.dragImage:alpha(0)
		self.dragImage:show()
		self.dragged = nil

		-- register windower event handlers
		self.keyboardHandlerId = windower.register_event('keyboard', function(key, down)
			self:handleWindowerKeyboard(key, down)
		end)

		self.mouseHandlerId = windower.register_event('mouse', function(type, x, y, delta, blocked)
			return self:handleWindowerMouse(type, x, y, delta, blocked)
		end)

		-- initialize UI, as there is no parent element to call these for us
		self.layoutElement()
		self:createPrimitives()
	end
end

function uiPartyList:dispose()
    windower.unregister_event(self.keyboardHandlerId)
    windower.unregister_event(self.mouseHandlerId)

	self.isSetupEnabled = false
	self.listItems:clear()

	self.super:dispose()
end

function uiPartyList:setupEnabled(enable, setupParty)
	if enable ~= nil then
		if enable ~= self.isSetupEnabled then
			self.isSetupEnabled = enable
            self.setupParty = setupParty
		end
	end

	return self.isSetupEnabled
end

function uiPartyList:update(force)
	local count = self.listItems:length()

	for i = 0, 5 do
		local player
		if self.isSetupEnabled then
			player = self.setupParty[i]
		else
			player = self.party[i]
		end

		local item = self.listItems[i]

		if player then
			if not item then
				item = self:addChild(uiListItem.new(self.layout.listItem))

				self.listItems[i] = item
				if not self.hidden then
					item:show()
				end
			end

			item:update(player)
		elseif item then
			item:dispose()
			self:removeChild(item)
			self.listItems[i] = nil
		end
	end

	if count ~= self.listItems:length() or force then
		local rowCount = math.floor((self.listItems:length() - 1) / self.layout.columns) + 1
		local contentHeight = rowCount * self.layout.rowHeight + (rowCount - 1) * self.partySettings.itemSpacing

		self.background:update(contentHeight)
		self:updateBackgroundVisibility()

		self.dragImage:size(self.layout.columns * self.layout.columnWidth, rowCount * self.layout.rowHeight)

		self:updateGrid(rowCount)
	end
end

function uiPartyList:updateGrid(rowCount)
	-- TODO: refactor this so we dont need to mess with these image positions
	if self.partySettings.alignBottom then
		self.background:pos(self.bgPos.x, self.bgPos.y - rowCount * self.layout.rowHeight)
		self.dragImage:pos(0, -rowCount * self.layout.rowHeight)
	else
		self.background:pos(self.bgPos.x, self.bgPos.y)
		self.dragImage:pos(0, 0)
	end

	local count = self.listItems:length()

	for i = 0, 5 do
		local item = self.listItems[i]
		if item then
			local row = math.floor(i / self.layout.columns)
    		local column = i % self.layout.columns

			local x = column * (self.layout.columnWidth + self.partySettings.itemSpacing)
			local y = row * (self.layout.rowHeight + self.partySettings.itemSpacing)
			if self.partySettings.alignBottom then
				y = y - rowCount * self.layout.rowHeight
			end

			item:pos(x, y)
		end
	end
end

function uiPartyList:updateBackgroundVisibility()
	if not self.hidden and self.listItems:length() > 0 then
		self.background:show()
	else
		self.background:hide()
	end
end

function uiPartyList:show()
	self.hidden = false

	self:updateBackgroundVisibility()
	self.dragImage:show()

	for item in self.listItems:it() do
		item:show()
	end
end

function uiPartyList:hide()
	self.hidden = true

	self:updateBackgroundVisibility()
	self.dragImage:hide()

	for item in self.listItems:it() do
		item:hide()
	end
end

function uiPartyList:handleWindowerKeyboard(key, down)
    if key == 29 then -- ctrl
        self.isCtrlDown = down
    end
end

-- handle drag and drop
function uiPartyList:handleWindowerMouse(type, x, y, delta, blocked)
    if blocked then return end

    if self.isSetupEnabled then
        -- mouse drag
        if type == 0 then
            if self.dragged then
                local posX = x - self.dragged.x
                local posY = y - self.dragged.y

                if self.isCtrlDown then -- grid snap
                    posX = math.floor(posX / 10) * 10
                    posY = math.floor(posY / 10) * 10
                end

                if self.partySettings.alignBottom then
                    self:pos(posX, posY + self.dragImage.height) -- TODO: re-test this
                else
                    self:pos(posX, posY)
                end
                return true
            end

        -- mouse left click
        elseif type == 1 then
            if self.dragImage:hover(x, y) then
				self.dragged = { x = x - self.dragImage.absolutePos.x, y = y - self.dragImage.absolutePos.y }
                return true
            end

        -- mouse left release
        elseif type == 2 then
            if self.dragged then
                self.partySettings.pos = L{ self.posX, self.posY }

                log('Position: ' .. self.posX .. ', ' .. self.posY)
                Settings:save()

                self.dragged = nil
                return true
            end

        -- mouse scroll
        elseif type == 10 then
            if self.dragImage:hover(x, y) then
				local sx = math.max(0.25, self.scaleX + delta / 100)
				local sy = math.max(0.25, self.scaleY + delta / 100)
				self:scale(sx, sy)

				self.partySettings.scale = L{ sx, sy }

				log('Scale: ' .. sx .. ', ' .. sy)
                Settings:save()

				return true
            end
        end
    end

    return false
end

return uiPartyList