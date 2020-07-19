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

local bg = {}

local isInitialized = false

function bg:init()
	utils:log('Initializing bg')

	bg.top = utils:createImage(layout.bg.imgTopPath)
	bg.mid = utils:createImage(layout.bg.imgMidPath, false) -- allow the mid section to stretch
	bg.bottom = utils:createImage(layout.bg.imgBottomPath)
	
	bg.contentHeight = 0
	bg.size = {}
	bg.size.width = 0
	bg.size.height = 0
	bg.posX = 0
	bg.posY = 0
	
	isInitialized = true
end

function bg:dispose()
	utils:log('Disposing bg')
	isInitialized = false

	images.destroy(self.top)
	images.destroy(self.mid)
	images.destroy(self.bottom)
end

function bg:pos(x, y)
	self.posX = x
	self.posY = y

	self.top:pos(x, y)
	self.mid:pos(x, y + layout.bg.imgTopBottomHeight)
	self.bottom:pos(x, y + layout.bg.imgTopBottomHeight + self.contentHeight)
end

function bg:resize(rowCount)
	utils:log('BG setting row count: ' .. rowCount)

	-- height of the content area (excludes top and bottom tiles)
	self.contentHeight = rowCount * settings.rowSpacingY
	
	self.mid:size(layout.bg.imgWidth, self.contentHeight)
	self:pos(self.posX, self.posY) -- refresh position of bottom tile
	
	-- visible size of the whole background area
	self.size.width = layout.bg.imgWidth
	self.size.height = layout.bg.imgTopBottomHeight * 2 + self.contentHeight
end

function bg:hide()
	if not isInitialized then return end

	self.top:hide()
	self.mid:hide()
	self.bottom:hide()
end

function bg:show()
	if not isInitialized then return end
	
	self.top:show()
	self.mid:show()
	self.bottom:show()
end

return bg