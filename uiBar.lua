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
local uiBar = classes.class(uiContainer)

function uiBar:init(layout)
	if self.super:init(layout) then
		self.layout = layout

		self.imgBg = self:addChild(uiImage.new(layout.imgBg))
		self.imgBar = self:addChild(uiImage.new(layout.imgBar))
		self.imgFg = self:addChild(uiImage.new(layout.imgFg))

		self.imgGlow = self:addChild(uiImage.new(layout.imgGlow))
		self.imgGlowLeft = self:addChild(uiImage.new(layout.imgGlowSides))
		self.imgGlowRight = self:addChild(uiImage.new(layout.imgGlowSides))

		self.imgGlow:hide(const.visFeature)
		self.imgGlowLeft:hide(const.visFeature)
		self.imgGlowRight:hide(const.visFeature)

		self.isDimmed = false
		self.value = 1
		self.exactValue = 1

		self.sizeBar = utils:coord(layout.imgBar.size)
		self.sizeGlow = utils:coord(layout.imgGlow.size)
		self.sizeGlowSides = utils:coord(layout.imgGlowSides.size)

		-- flip horizontally, this will move the image origin to the top-right corner
		self.imgGlowRight:size(-self.sizeGlowSides.x, self.sizeGlowSides.y)
	end
end

-- must be called every frame for a smooth animation
function uiBar:update(targetValue)
	if not self.isEnabled then return end

	if self.value ~= targetValue then
		self.exactValue = self.exactValue + (targetValue - self.exactValue) * self.layout.animSpeed
		self.exactValue = math.min(math.max(self.exactValue, 0), 1) -- clamp to 0..1
		self.value = utils:round(self.exactValue, 3)

		local multiplier
		if self.isDimmed or not self.imgGlow.isEnabled then -- animate bar, glow hidden while dimmed or when glow disabled
			multiplier = self.value
		else -- instantly move the bar, the glow will be animated instead
			multiplier = targetValue
		end

		self.imgBar:size(self.sizeBar.x * multiplier, self.sizeBar.y)
	end

	self:updateGlow(targetValue)
end

function uiBar:updateGlow(targetValue)
	if not self.isDimmed and math.abs(targetValue - self.value) > 0.01 then
		local glowWidth = self.sizeBar.x * math.abs(targetValue - self.value)
		local glowPosX = self.imgBar.posX + self.sizeBar.x * math.min(targetValue, self.value)
		local glowLeftPosX = glowPosX - self.sizeGlowSides.x
		local glowRightPosX = glowPosX + glowWidth + self.sizeGlowSides.x

		self.imgGlow:show(const.visFeature)
		self.imgGlowLeft:show(const.visFeature)
		self.imgGlowRight:show(const.visFeature)

		self.imgGlow:size(glowWidth, self.sizeGlow.y)
		self.imgGlow:pos(glowPosX, self.imgGlow.posY)

		self.imgGlowLeft:pos(glowLeftPosX, self.imgGlowLeft.posY)
		self.imgGlowRight:pos(glowRightPosX, self.imgGlowRight.posY)
	else
		self.imgGlow:hide(const.visFeature)
		self.imgGlowLeft:hide(const.visFeature)
		self.imgGlowRight:hide(const.visFeature)
	end
end

function uiBar:opacity(o)
	if not self.isEnabled then return end

	self.isDimmed = o < 1
	self.imgBar:opacity(o)
end

return uiBar