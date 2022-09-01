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
local uiBackground = require('uiBackground')
local uiListItem = require('uiListItem')
local uiImage = require('uiImage')

-- create the class
local partylist = classes.class()

function partylist:init(party, partySettings, layout)
    if not party then
		utils:log('partylist:init missing parameter party!', 4)
		return
	end

    if not partySettings then
		utils:log('partylist:init missing parameter partySettings!', 4)
		return
	end

    utils:log('Initializing partylist')

	self.party = party -- list of party members from model.party (or one of the alliances)
    self.partySettings = partySettings
	self.layout = layout

    self.listItems = T{} -- ordered list by party list position, index range 0..5
    self.setupParty = nil -- list of party members used in setup mode
    self.isSetupEnabled = false
    self.isCtrlDown = false
    self.hidden = false
	
	self.background = uiBackground.new(layout.bg, layout.scale)
	
	self.dragImage = uiImage.create(nil, self.background.size.width, self.background.size.height)
	self.dragImage:alpha(0)
	self.dragImage:show()
    self.dragged = nil
	
	self.posX = partySettings.posX
	self.posY = partySettings.posY
	
    -- register windower event handlers
    self.keyboardHandlerId = windower.register_event('keyboard', function(key, down)
        self:handleWindowerKeyboard(key, down)
    end)
    
    self.mouseHandlerId = windower.register_event('mouse', function(type, x, y, delta, blocked)
        return self:handleWindowerMouse(type, x, y, delta, blocked)
    end)
end

function partylist:dispose()
	utils:log('Disposing partylist')
	
    windower.unregister_event(self.keyboardHandlerId)
    windower.unregister_event(self.mouseHandlerId)

	self.isSetupEnabled = false
	
	self.background:dispose()
	self.dragImage:dispose()
	
	for item in self.listItems:it() do
		item:dispose()
	end
	self.listItems:clear()
end

function partylist:setupEnabled(enable, setupParty)
	if enable ~= nil then
		if enable ~= self.isSetupEnabled then
			self.isSetupEnabled = enable
            self.setupParty = setupParty
		end
	end
	
	return self.isSetupEnabled
end

function partylist:pos(x, y)
	-- top/left corner, when aligned to bottom: bottom/left corner
	self.posX = x
	self.posY = y

	if self.partySettings.alignBottom then
		self.background:pos(x, y - self.background.size.height)
		self.dragImage:pos(x, y - self.background.size.height)
	else
		self.background:pos(x, y)
		self.dragImage:pos(x, y)
	end
	
	local count = self.listItems:length()
	
	for i = 0, 5 do
		local item = self.listItems[i]
		
		local row = math.floor(i / self.layout.partyList.columns)
    	local column = i % self.layout.partyList.columns

		if item then
			if self.partySettings.alignBottom then
				item:pos(
					x, 
					y - (count - i) * (self.layout.partyList.rowHeight + self.partySettings.itemSpacing) + self.partySettings.itemSpacing)
			else
				item:pos(
					x + column * (self.layout.partyList.columnWidth + self.partySettings.itemSpacing), 
					y + row * (self.layout.partyList.rowHeight + self.partySettings.itemSpacing))
			end
		end
	end
end

function partylist:update(force)
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
				item = uiListItem.new(self.layout)
				self.listItems[i] = item
				if not self.hidden then
					item:show()
				end
			end
			
			item:update(player)
		elseif item then
			item:dispose()
			self.listItems[i] = nil
		end
	end
	
	if count ~= self.listItems:length() or force then
		local rowCount = math.floor((self.listItems:length() - 1) / self.layout.partyList.columns) + 1
		local contentHeight = rowCount * self.layout.partyList.rowHeight + (rowCount - 1) * self.partySettings.itemSpacing
		
		self.background:update(contentHeight)
		self:updateBackgroundVisibility()

		self.dragImage:size(self.background.size.width, self.background.size.height)
		
		self:pos(self.posX, self.posY)
	end
end

function partylist:updateBackgroundVisibility()
	if not self.hidden and self.listItems:length() > 0 then
		self.background:show()
	else
		self.background:hide()
	end
end

function partylist:show()
	self.hidden = false
	
	self:updateBackgroundVisibility()
	self.dragImage:show()
	
	for item in self.listItems:it() do
		item:show()
	end
end

function partylist:hide()
	self.hidden = true
	
	self:updateBackgroundVisibility()
	self.dragImage:hide()
	
	for item in self.listItems:it() do
		item:hide()
	end
end

function partylist:handleWindowerKeyboard(key, down)
    if key == 29 then -- ctrl
        self.isCtrlDown = down
    end
end

-- handle drag and drop
function partylist:handleWindowerMouse(type, x, y, delta, blocked)
    if blocked then
        return 
    end

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
                    self:pos(posX, posY + self.dragImage.height)
                else
                    self:pos(posX, posY)
                end
                return true
            end
        
        -- mouse left click
        elseif type == 1 then
            if self.dragImage:hover(x, y) then
				self.dragged = { x = x - self.dragImage.posX, y = y - self.dragImage.posY }
                return true
            end
        
        -- mouse left release
        elseif type == 2 then
            if self.dragged then
                self.partySettings.posX = self.posX
                self.partySettings.posY = self.posY
                
                utils:log('Saving position: ' .. self.posX .. ', ' .. self.posY)
                settings:save()
                
                self.dragged = nil
                return true
            end
        
        -- mouse scroll
        elseif type == 10 then
            if self.dragImage:hover(x, y) then
                self.partySettings.itemSpacing = math.max(0, self.partySettings.itemSpacing + delta)
                settings:save()
                
                self:update(true) -- force a redraw
            end
        end
    end

    return false
end

return partylist