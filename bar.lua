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

local bar = {}
bar.__index = bar

function bar:init(barInfo)
	utils:log('Initializing bar', 1)

	local obj = {}
	setmetatable(obj, bar) -- make handle lookup
	
	obj.imgBg = utils:createImage(barInfo.imgBg, layout.scale)
	obj.imgFg = utils:createImage(barInfo.imgFg, layout.scale)
	
	obj.value = 1
	obj.exactValue = 1
	
	obj.sizeBg = utils:coord(barInfo.imgBg.size)
	obj.sizeFg = utils:coord(barInfo.imgFg.size)
	
	obj.size = {}
	obj.size.width = obj.imgBg:scaledSize().width -- this assumes the BG is larger than the FG
	obj.size.height = obj.imgBg:scaledSize().height
	
	return obj
end

function bar:dispose()
	utils:log('Disposing bar', 1)

	self.imgBg:dispose()
	self.imgFg:dispose()

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
	
		self.imgFg:size(self.sizeFg.x * self.value, self.sizeFg.y)
	end
end

function bar:opacity(o)
	self.imgFg:opacity(o)
end

function bar:show()
	self.imgBg:show()
	self.imgFg:show()
end

function bar:hide()
	self.imgBg:hide()
	self.imgFg:hide()
end

return bar