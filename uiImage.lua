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

-- windower library imports
local images = require('images')

-- imports
local classes = require('classes')
local uiBase = require('uiBase')
local utils = require('utils')

-- create the class, derive from uiBase
local uiImage = classes.class(uiBase)

-- alternative constructor
function uiImage.create(path, sizeX, sizeY, scale)
	if not sizeX then
		sizeX = 0
		sizeY = 0
	end
	if not scale then
		scale = 1
	end

	local imageLayout = {}
	imageLayout.enabled = true
	imageLayout.offset = L{ 0, 0 }
	imageLayout.path = path
	imageLayout.size = L{ sizeX, sizeY }

	return uiImage.new(imageLayout, scale)
end

function uiImage:init(imgLayout, scale)
    if self.super.init(self, imgLayout) then
		self.wrappedImage = images.new()
		self.wrappedImage:draggable(false)
    	self.wrappedImage:fit(false) -- scaling only works when 'fit' is false
		
		self.currentAlpha = 255
		self.currentOpacity = 1.0

		self.currentScale = 1
		if scale then
			self.currentScale = scale
		end

		if imgLayout and imgLayout.path and imgLayout.path ~= '' then
			self:path(imgLayout.path)
		end

		if imgLayout and imgLayout.size then
			local size = utils:coord(imgLayout.size)
			self:size(size.x, size.y)
		else
			self:size(0, 0)
		end
        
        if imgLayout and imgLayout.color then
            self:color(utils:colorFromHex(imgLayout.color))
        end
    end
end

function uiImage:dispose()
    if not self.enabled then return end

    images.destroy(self.wrappedImage)
    self.super.dispose(self) -- TODO: this class doesnt have any children and actually shouldnt even support them. might want an additional base class to solve this
end

-- apply the UI element's position and offset
function uiImage:applyPos()
	if not self.enabled then return end

	self.wrappedImage:pos(self.posX + self.offsetX, self.posY + self.offsetY)
end

-- sets the image file path
-- @param path a file path relative to the addon's directory
function uiImage:path(path)
    if not self.enabled then return end
	
	self.wrappedImage:path(windower.addon_path .. path)
end

-- sets the unscaled image size, if a scale is set it will be applied on top of this
function uiImage:size(w, h)
	if not self.enabled then return end

	if self.width ~= w or self.height ~= h then
		self.width = w;
		self.height = h;
		self.scaledWidth = self.width * self.currentScale;
		self.scaledHeight = self.height * self.currentScale;
		
		self.wrappedImage:size(self.scaledWidth, self.scaledHeight)
	end
end

function uiImage:scale(s)
	if not self.enabled then return end

	if self.currentScale ~= s then
		self.currentScale = s
		self:size(self.sizeX, self.sizeY) -- apply the new scale
	end
end

function uiImage:repeat_xy(x, y)
	if not self.enabled then return end

	self.wrappedImage:repeat_xy(x, y)
end

-- returns true if the specified absolute screen coordinates are inside the image
function uiImage:hover(x ,y)
	if not self.enabled then return false end

	return self.wrappedImage:hover(x, y)
end

function uiImage:color(r, g, b)
	if not self.enabled then return false end

	-- color object returned by utils:colorFromHex
	if type(r) == 'table' and r.r and r.g and r.b and r.a then
		self.wrappedImage:color(r.r, r.g, r.b)
		self:alpha(r.a)
	else
		self.wrappedImage:color(r, g, b)
	end
end

-- sets image alpha
-- @param a alpha value as integer in range 0 .. 255
function uiImage:alpha(a)
    if not self.enabled then return end
	
	if self.currentAlpha ~= a then
		self.currentAlpha = a
		self.wrappedImage:alpha(self.currentAlpha * self.currentOpacity)
	end
end

-- sets a secondary multiplicative alpha value, allows for temporarily changing alpha while preserving the value set via layout colors
-- @param o opacity value as double in range 0.0 .. 1.0
function uiImage:opacity(o)
    if not self.enabled then return end

	if self.currentOpacity ~= o then
		self.currentOpacity = o
		self.wrappedImage:alpha(self.currentAlpha * self.currentOpacity)
	end
end

function uiImage:show()
    if not self.enabled then return end

	self.wrappedImage:show()
end

function uiImage:hide()
    if not self.enabled then return end

	self.wrappedImage:hide()
end

return uiImage