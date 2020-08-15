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

local img = {}
img.__index = img

-- a wrapper class for windower image primitives with scaling support
function img:init(path, width, height, scaleX, scaleY)
	if not path then
		width = 0
		height = 0
		scale = 1.0
	elseif not width or not height then
		-- the image primitive cannot return the texture's size, so width and height must always be set or the image will collapse to its default size 0,0
		utils:log('Error: Must also set image width and height when path is set!', 4)
		return nil
	elseif not scaleX then
		scaleX = 1.0
		scaleY = 1.0
	elseif not scaleY then -- uniform scale
		scaleY = scaleX
	end

	local obj = {}
	setmetatable(obj, img) -- make handle lookup

	-- private data fields, do not change from outside the class!
	obj.data = {}
	obj.data.alpha = 255
	obj.data.opacity = 1.0
	obj.data.pos = {}
	obj.data.pos.x = 0
	obj.data.pos.y = 0
	obj.data.scale = {}
	obj.data.scale.x = scaleX
	obj.data.scale.y = scaleY
	obj.data.size = {}
	obj.data.size.width = width
	obj.data.size.height = width
	obj.data.scaledSize = {}
	obj.data.scaledSize.width = width * scaleX
	obj.data.scaledSize.height = width * scaleY
	
	obj.image = images.new()
	obj.image:draggable(false)
    obj.image:fit(false) -- scaling only works when 'fit' is false
	
	if path then
		obj.image:path(path)
	end
	
	obj:size(width, height)
	
	return obj
end

function img:dispose()
	images.destroy(self.image)
	
	setmetatable(self, nil)
end

function img:path(path)
	if not path then
		return self.image:path()
	end
	
	self.image:path(path)
end

function img:pos(x, y)
	if not x then
		return self.data.pos
	end
	
	self.data.pos.x = x
	self.data.pos.y = y
	
	self.image:pos(x, y)
end

function img:size(w, h)
	if not w then
		return self.data.size
	end

	self.data.size.width = w;
	self.data.size.height = h;
	self.data.scaledSize.width = self.data.size.width * self.data.scale.x;
	self.data.scaledSize.height = self.data.size.height * self.data.scale.y;
	
	self.image:size(self.data.scaledSize.width, self.data.scaledSize.height)
end

function img:scaledSize()
	return self.data.scaledSize
end

-- scale center is the top left corner of the image (pos)
function img:scale(sx, sy)
	if not sx then
		return self.data.scale
	end
	
	if not sy then -- uniform scale
		sy = sx
	end
	
	self.data.scale.x = sx
	self.data.scale.y = sy
	self.data.scaledSize.width = self.data.size.width * self.data.scale.x;
	self.data.scaledSize.height = self.data.size.height * self.data.scale.y;
	
	self.image:size(self.data.scaledSize.width, self.data.scaledSize.height)
end

function img:color(r,g,b)
	if not r then
		return self.image:color()
	end
	
	self.image:color(r,g,b)
end

function img:alpha(a)
	if not a then
		return self.data.alpha
	end
	
	self.data.alpha = a
	self.image:alpha(self.data.alpha * self.data.opacity)
end

-- an additional alpha value, because image alphas are now customizable via layouts. type double 0.0 .. 1.0
function img:opacity(o)
	if not o then
		return self.data.opacity
	end
	
	self.data.opacity = o
	self.image:alpha(self.data.alpha * self.data.opacity)
end

function img:show()
	self.image:show()
end

function img:hide()
	self.image:hide()
end

function img:visible(v)
	if not v then
		return self.image:visible()
	end
	
	self.image:visible(v)
end

return img