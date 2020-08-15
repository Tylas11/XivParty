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

local view = {}

local bg = require('bg')
local listitem = require('listitem')

local listItems = T{} -- ordered list by party list position, index range 0..5
local dragImage
local dragged
local isInitialized = false
local isMoveEnabled = false
local hidden = false

function view:init()
	if isInitialized then return end

	utils:log('Initializing view')
	bg:init()
	
	dragImage = img:init('', bg.size.width, bg.size.height)
	dragImage:alpha(0)
	dragImage:show()
	
	self.posX = 0
	self.posY = 0
	self.listOffset = utils:coord(layout.list.offset)
	
	isInitialized = true
end

function view:dispose()
	if not isInitialized then return end

	utils:log('Disposing view')
	isInitialized = false

	bg:dispose()
	dragImage:dispose()
	
	for item in listItems:it() do
		item:dispose()
	end
	listItems:clear()
end

function view:moveEnabled(enable)
	if enable ~= nil then
		if enable ~= isMoveEnabled then
			isMoveEnabled = enable
		end
	end
	
	return isMoveEnabled
end

function view:pos(x, y)
	if not isInitialized then return end

	self.posX = x
	self.posY = y

	bg:pos(x, y)
	dragImage:pos(x, y)
	
	for i = 0, 5 do
		local item = listItems[i]
		
		if item then
			item:pos(
				x + self.listOffset.x, 
				y + self.listOffset.y + bg.top:scaledSize().height + i * (layout.list.itemHeight + settings.spacingY))
		end
	end
end

function view:update(force)
	if not isInitialized then return end
	
	local count = listItems:length()
	
	for i = 0, 5 do
		local player = model.players[i]
		local item = listItems[i]
		
		if player then
			if not item then
				item = listitem:init()
				listItems[i] = item
				if not hidden then
					item:show()
				end
			end
			
			item:update(player)
		elseif item then
			item:dispose()
			listItems[i] = nil
		end
	end
	
	if count ~= listItems:length() or force then
		bg:resize(listItems:length())
		dragImage:size(bg.size.width, bg.size.height)
		
		self:pos(self.posX, self.posY)
	end
end

function view:show()
	if not isInitialized then return end
	
	hidden = false
	
	bg:show()
	dragImage:show()
	
	for item in listItems:it() do
		item:show()
	end
end

function view:hide()
	if not isInitialized then return end

	hidden = true
	
	bg:hide()
	dragImage:hide()
	
	for item in listItems:it() do
		item:hide()
	end
end

-- handle drag and drop
windower.register_event('mouse', function(type, x, y, delta, blocked)
    if blocked then
		return 
	end

	if isMoveEnabled then
		-- mouse drag
		if type == 0 then
			if dragged then
				view:pos(x - dragged.x, y - dragged.y)
				return true
			end
		
		-- mouse left click
		elseif type == 1 then
			if dragImage.image:hover(x, y) then
				dragged = {image = dragImage.image, x = x - dragImage:pos().x, y = y - dragImage:pos().y}
				return true
			end
		
		-- mouse left release
		elseif type == 2 then
			if dragged then
				settings.posX = view.posX
				settings.posY = view.posY
				
				utils:log('Saving position: ' .. view.posX .. ', ' .. view.posY)
				settings:save()
				
				dragged = nil
				return true
			end
		
		-- mouse scroll
		elseif type == 10 then
			if dragImage.image:hover(x, y) then
				settings.spacingY = math.max(0, settings.spacingY + delta)
				settings:save()
				
				view:update(true) -- force a redraw
			end
		end
	end

    return false
end)

return view