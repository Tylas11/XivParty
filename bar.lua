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

local bar = {}
bar.__index = bar

function bar:init(barInfo)
	utils:log('Initializing bar', 1)

	local obj = {}
	setmetatable(obj, bar) -- make handle lookup
	
	obj.imgBg = utils:createImage(barInfo.imgBg, layout.scale)
	obj.imgFg = utils:createImage(barInfo.imgFg, layout.scale)
	
	obj.imgGlowMid = utils:createImage(layout.bar.imgGlowMid, layout.scale)
	obj.imgGlowLeft = utils:createImage(layout.bar.imgGlowSides, layout.scale)
	obj.imgGlowRight = utils:createImage(layout.bar.imgGlowSides, layout.scale)
	
	obj.imgGlowMid:color(utils:colorFromHex(barInfo.imgFg.color))
	obj.imgGlowLeft:color(utils:colorFromHex(barInfo.imgFg.color))
	obj.imgGlowRight:color(utils:colorFromHex(barInfo.imgFg.color))
	
	obj.value = 1
	obj.exactValue = 1
	
	obj.sizeBg = utils:coord(barInfo.imgBg.size)
	obj.sizeFg = utils:coord(barInfo.imgFg.size)
	obj.sizeGlow = utils:coord(layout.bar.imgGlowMid.size)
	obj.sizeGlowSides = utils:coord(layout.bar.imgGlowSides.size)
	
	-- flip horizontally, this will move the image origin to the top-right corner
	obj.imgGlowRight:size(-obj.sizeGlowSides.x, obj.sizeGlowSides.y)
	
	obj.size = {}
	obj.size.width = obj.imgBg:scaledSize().width -- this assumes the BG is larger than the FG
	obj.size.height = obj.imgBg:scaledSize().height
	
	return obj
end

function bar:dispose()
	utils:log('Disposing bar', 1)

	self.imgBg:dispose()
	self.imgFg:dispose()
	self.imgGlowMid:dispose()
	self.imgGlowLeft:dispose()
	self.imgGlowRight:dispose()

	setmetatable(self, nil)
end

function bar:pos(x, y)
	-- this centers the foreground image inside the background image, background assumed to be larger
	local fgOffsetX = (self.sizeBg.x - self.sizeFg.x) / 2 * layout.scale
	local fgOffsetY = (self.sizeBg.y - self.sizeFg.y) / 2 * layout.scale
	
	self.imgBg:pos(x, y)
	self.imgFg:pos(x + fgOffsetX, y + fgOffsetY)
end

-- must be called every frame for a smooth animation
function bar:update(targetValue)
	if self.value ~= targetValue then
		self.exactValue = self.exactValue + (targetValue - self.exactValue) * layout.bar.animSpeed
		self.exactValue = math.min(math.max(self.exactValue, 0), 1) -- clamp to 0..1
		self.value = utils:round(self.exactValue, 3)
	    
		-- instantly move the bar, the glow will be animated instead
		self.imgFg:size(self.sizeFg.x * targetValue, self.sizeFg.y)
	end
	
	self:updateGlow(targetValue)
end

function bar:updateGlow(targetValue)
	if math.abs(targetValue - self.value) > 0.01 then
		local glowWidth = self.sizeFg.x * math.abs(targetValue - self.value)
		
		-- center glow vertically on the bar foreground image
		local glowMidPosY = self.imgFg:pos().y + (self.sizeFg.y / 2 - self.sizeGlow.y / 2) * layout.scale
		local glowSidesPosY = self.imgFg:pos().y + (self.sizeFg.y / 2 - self.sizeGlowSides.y / 2) * layout.scale
	
		self.imgGlowMid:opacity(1)
		self.imgGlowLeft:opacity(1)
		self.imgGlowRight:opacity(1)
	
		self.imgGlowMid:size(glowWidth, self.sizeGlow.y)
		self.imgGlowMid:pos(self.imgFg:pos().x + self.sizeFg.x * math.min(targetValue, self.value) * layout.scale, glowMidPosY)
			
		self.imgGlowLeft:pos(self.imgGlowMid:pos().x - self.sizeGlowSides.x * layout.scale, glowSidesPosY)
		self.imgGlowRight:pos(self.imgGlowMid:pos().x + (glowWidth + self.sizeGlowSides.x) * layout.scale, glowSidesPosY)
	else
		self.imgGlowMid:opacity(0)
		self.imgGlowLeft:opacity(0)
		self.imgGlowRight:opacity(0)
	end
end

function bar:opacity(o)
	self.imgFg:opacity(o)
end

function bar:show()
	self.imgBg:show()
	self.imgFg:show()
	self.imgGlowMid:show()
	self.imgGlowLeft:show()
	self.imgGlowRight:show()
end

function bar:hide()
	self.imgBg:hide()
	self.imgFg:hide()
	self.imgGlowMid:hide()
	self.imgGlowLeft:hide()
	self.imgGlowRight:hide()
end

return bar