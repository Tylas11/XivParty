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
local utils = require('utils')

-- create the class, derive from uiContainer
local uiBar = classes.class(uiContainer)

function uiBar:init(barLayout)
	if self.super:init(barLayout) then
		self.barLayout = barLayout

		self.imgBg = self:addChild(uiImage.new(barLayout.imgBg))
		self.imgBar = self:addChild(uiImage.new(barLayout.imgBar))
		self.imgFg = self:addChild(uiImage.new(barLayout.imgFg))

		self.imgGlowMid = self:addChild(uiImage.new(barLayout.imgGlowMid))
		self.imgGlowLeft = self:addChild(uiImage.new(barLayout.imgGlowSides))
		self.imgGlowRight = self:addChild(uiImage.new(barLayout.imgGlowSides))
		
		self.isDimmed = false
		self.value = 1
		self.exactValue = 1
		
		self.sizeBar = utils:coord(barLayout.imgBar.size)
		self.sizeGlow = utils:coord(barLayout.imgGlowMid.size)
		self.sizeGlowSides = utils:coord(barLayout.imgGlowSides.size)
		
		-- flip horizontally, this will move the image origin to the top-right corner
		self.imgGlowRight:size(-self.sizeGlowSides.x, self.sizeGlowSides.y)
	end
end

-- must be called every frame for a smooth animation
function uiBar:update(targetValue)
	if self.value ~= targetValue then
		self.exactValue = self.exactValue + (targetValue - self.exactValue) * self.barLayout.animSpeed
		self.exactValue = math.min(math.max(self.exactValue, 0), 1) -- clamp to 0..1
		self.value = utils:round(self.exactValue, 3)
	    
		local multiplier
		if self.isDimmed then -- animate bar, glow hidden while dimmed
			multiplier = self.value
		else -- instantly move the bar, the glow will be animated instead
			multiplier = targetValue
		end

		self.imgBar:size((self.sizeBar.x - 2 * self.barLayout.barOverlap) * multiplier + self.barLayout.barOverlap, self.sizeBar.y)
	end
	
	self:updateGlow(targetValue)
end

function uiBar:updateGlow(targetValue)
	if not self.isDimmed and math.abs(targetValue - self.value) > 0.01 then
		local glowWidth = (self.sizeBar.x - 2 * self.barLayout.barOverlap) * math.abs(targetValue - self.value)
		local glowPosX = self.imgBar.posX + (self.sizeBar.x - 2 * self.barLayout.barOverlap) * math.min(targetValue, self.value) + self.barLayout.barOverlap

		self.imgGlowMid:opacity(1)
		self.imgGlowLeft:opacity(1)
		self.imgGlowRight:opacity(1)
	
		self.imgGlowMid:size(glowWidth, self.sizeGlow.y)

		self.imgGlowMid:pos(glowPosX, self.imgGlowMid.posY)
		self.imgGlowLeft:pos(self.imgGlowMid.posX - self.sizeGlowSides.x, self.imgGlowMid.posY)
		self.imgGlowRight:pos(self.imgGlowMid.posX + (glowWidth + self.sizeGlowSides.x), self.imgGlowMid.posY)
	else
		self.imgGlowMid:opacity(0)
		self.imgGlowLeft:opacity(0)
		self.imgGlowRight:opacity(0)
	end
end

function uiBar:opacity(o)
	self.isDimmed = o < 1
	self.imgBar:opacity(o)
end

return uiBar