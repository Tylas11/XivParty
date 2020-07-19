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

function bar:init()
	utils:log('Initializing bar', 1)

	local obj = {}
	setmetatable(obj, bar) -- make handle lookup
	
	obj.imgBg = utils:createImage(layout.bar.imgBgPath)
	obj.imgFg = utils:createImage(layout.bar.imgFgPath)
	
	obj.value = nil
	obj.exactValue = 1
	
	obj.size = {}
	obj.size.width = layout.bar.imgBgWidth
	obj.size.height = layout.bar.imgBgHeight
	
	return obj
end

function bar:dispose()
	utils:log('Disposing bar', 1)

	images.destroy(self.imgBg)
	images.destroy(self.imgFg)

	setmetatable(self, nil)
end

function bar:pos(x, y)
	local fgOffsetX = (layout.bar.imgBgWidth - layout.bar.imgFgWidth) / 2
	local fgOffsetY = (layout.bar.imgBgHeight - layout.bar.imgFgHeight) / 2

	self.imgBg:pos(x, y)
	self.imgFg:pos(x + fgOffsetX, y + fgOffsetY)
end

-- must be called every frame for a smooth animation
function bar:update(targetValue)
	if self.value ~= targetValue then
		self.exactValue = self.exactValue + (targetValue - self.exactValue) * 0.1
		self.exactValue = math.min(math.max(self.exactValue, 0), 1) -- clamp to 0..1
		self.value = utils:round(self.exactValue, 3)
	
		-- NOTE: image size changes before the image is shown seem to be ignored
		self.imgFg:size(layout.bar.imgFgWidth * self.value, layout.bar.imgFgHeight)
		--utils:log('target: ' .. targetValue .. ' value: ' .. self.value .. ' exact: ' .. self.exactValue)
	end
end

function bar:alpha(alpha)
	self.imgFg:alpha(alpha)
end

function bar:show()
	self.imgBg:show()
	self.imgFg:show()
end

function bar:hide()
	self.imgBg:hide();
	self.imgFg:hide();
end

return bar