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

local bg = {}
bg.__index = bg

local isDebug = false

function bg:init(ptySet)
	if not ptySet then
		utils:log('partylist:init missing parameter ptySet!', 4)
		return
	end

	utils:log('Initializing bg')

	local obj = {}
	setmetatable(obj, bg) -- make handle lookup

	obj.partySettings = ptySet

	obj.hidden = true
	obj.rowCount = 0
	obj.contentHeight = 0 -- height of the content area (excludes top and bottom tiles)
	obj.size = {}
	obj.size.width = 0
	obj.size.height = 0
	obj.posX = 0
	obj.posY = 0
	obj.sizeMid = utils:coord(layout.bg.imgMid.size)
	
	obj.top = utils:createImage(layout.bg.imgTop, layout.scale)
	obj.mid = utils:createImage(layout.bg.imgMid, layout.scale)
	obj.bottom = utils:createImage(layout.bg.imgBottom, layout.scale)
		
	if isDebug then -- debug background
		obj.top:path('')
		obj.mid:path('')
		obj.bottom:path('')
		
		obj.top:color(255,0,0)
		obj.mid:color(0,255,0)
		obj.bottom:color(0,0,255)
	end
	
	return obj
end

function bg:dispose()
	utils:log('Disposing bg')

	self.top:dispose()
	self.mid:dispose()
	self.bottom:dispose()

	setmetatable(self, nil)
end

function bg:pos(x, y)
	self.posX = x
	self.posY = y

	self.top:pos(x, y)
	self.mid:pos(x, y + self.top:scaledSize().height)
	self.bottom:pos(x, y + self.top:scaledSize().height + self.mid:scaledSize().height)
end

function bg:resize(rowCount)
	utils:log('BG setting row count: ' .. rowCount, 1)

	self.rowCount = rowCount

	self.contentHeight = (rowCount * (layout.list.itemHeight) + (rowCount - 1) * self.partySettings.itemSpacing) / layout.scale
	self.mid:size(self.sizeMid.x, self.contentHeight)
	self.mid.image:repeat_xy(1, math.floor(self.contentHeight / self.sizeMid.y))
	self:pos(self.posX, self.posY) -- refresh position of bottom tile
	
	-- visible size of the whole background area
	self.size.width = math.max(math.max(self.top:scaledSize().width, self.bottom:scaledSize().width), self.mid:scaledSize().width)
	self.size.height = self.top:scaledSize().height + self.mid:scaledSize().height + self.bottom:scaledSize().height

	self:updateVisibility()
end

function bg:updateVisibility()
	if not self.hidden and self.rowCount > 0 then
		self.top:show()
		self.mid:show()
		self.bottom:show()
	else
		self.top:hide()
		self.mid:hide()
		self.bottom:hide()
	end
end

function bg:show()
	self.hidden = false
	self:updateVisibility()
end

function bg:hide()
	self.hidden = true
	self:updateVisibility()
end

return bg