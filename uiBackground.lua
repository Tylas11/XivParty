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
local uiImage = require('uiImage')

-- create the class, derive from uiContainer
local uiBackground = classes.class(uiContainer)

local isDebug = false

function uiBackground:init(bgLayout)
	if self.super:init(bgLayout) then
		self.bgLayout = bgLayout

		self.size = {}
		self.size.width = 0
		self.size.height = 0

		self.sizeMid = utils:coord(bgLayout.imgMid.size)

		self.top = self:addChild(uiImage.new(bgLayout.imgTop))
		self.mid = self:addChild(uiImage.new(bgLayout.imgMid))
		self.bottom = self:addChild(uiImage.new(bgLayout.imgBottom))

		if isDebug then -- debug background
			self.top:path('')
			self.mid:path('')
			self.bottom:path('')
			
			self.top:color(255,0,0)
			self.mid:color(0,255,0)
			self.bottom:color(0,0,255)
		end
	end
end

-- sets the height of the content area (excludes top and bottom tiles)
function uiBackground:update(contentHeight)
	if not self.isEnabled then return end

	contentHeight = contentHeight / self.scaleY -- negate vertical scaling, we want to set the height directly

	self.mid:size(self.sizeMid.x, contentHeight)
	self.mid:repeat_xy(1, math.floor(contentHeight / self.sizeMid.y))

	self.bottom:pos(self.bottom.posX, self.mid.posY + self.mid.height)
	
	-- visible size of the whole background area
	self.size.width = math.max(math.max(self.top.absoluteWidth, self.bottom.absoluteWidth), self.mid.absoluteWidth)
	self.size.height = self.top.absoluteHeight + self.mid.absoluteHeight + self.bottom.absoluteHeight
end

return uiBackground