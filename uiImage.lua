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

-- windower library imports
local images = require('images')

-- imports
local classes = require('classes')
local uiElement = require('uiElement')
local utils = require('utils')
local const = require('const')

-- create the class, derive from uiElement
local uiImage = classes.class(uiElement)

-- static storage for private variables, access using private[self] to keep separate values for each instance
local private = {}

-- alternative constructor
function uiImage.create(path, sizeX, sizeY, posX, posY, scaleX, scaleY)
	if not sizeX then
		sizeX = 0
		sizeY = 0
	end
	if not posX then
		posX = 0
		posY = 0
	end
	if not scaleX then
		scaleX = 1
		scaleY = 1
	end

	local imageLayout = {}
	imageLayout.enabled = true
	imageLayout.path = path
	imageLayout.size = L{ sizeX, sizeY }
	imageLayout.pos = L{ posX, posY }
	imageLayout.scale = L{ scaleX, scaleY }

	return uiImage.new(imageLayout)
end

function uiImage:init(layout)
    if self.super:init(layout) then
		private[self] = {}

		if layout and layout.path and layout.path ~= '' then
			private[self].path = layout.path
		end

		self.width = 0
		self.height = 0
		if layout and layout.size then
			local size = utils:coord(layout.size)
			self.width = size.x
			self.height = size.y
		end

		self.absoluteWidth = 0
		self.absoluteHeight = 0

		private[self].color = {}
		private[self].color.r = 255
		private[self].color.g = 255
		private[self].color.b = 255
		private[self].color.a = 255
		if layout and layout.color then
			local c = utils:colorFromHex(layout.color)
			if c then
				private[self].color = c
			end
		end

		private[self].opacity = 1.0
		private[self].initFrames = -1
		private[self].initShown = false
    end
end

function uiImage:dispose()
    if not self.isEnabled then return end

	if self.isCreated then
    	images.destroy(self.wrappedImage)
		RefCountImage = RefCountImage - 1
	end
	private[self] = nil

	self.super:dispose()
end

local function setPath(image, path)
	image.wrappedImage:path(windower.addon_path .. path)

	-- this is a workaround for image primitives showing up before their texture is loaded
	-- only needed when switching from no texture to texture
	if not path or path == '' then
		private[image].initShown = false
	elseif not private[image].initShown then
		image:hide(const.visInit)
		private[image].initFrames = 2 -- delay showing for 2 frames
	end
end

function uiImage:createPrimitives()
	if not self.isEnabled or self.isCreated then return end

	self.wrappedImage = images.new()
	RefCountImage = RefCountImage + 1
	self.wrappedImage:draggable(false)
	self.wrappedImage:fit(false) -- scaling only works when 'fit' is false

	self.wrappedImage:repeat_xy(private[self].repeatX, private[self].repeatY)
	self.wrappedImage:color(private[self].color.r, private[self].color.g, private[self].color.b)
	self.wrappedImage:alpha(private[self].color.a * private[self].opacity)

	if private[self].path then
		setPath(self, private[self].path)
	end

	self.super:createPrimitives() -- this will call applyLayout()
end

function uiImage:updateLayout()
	if not self.isEnabled then return end

	self.super:updateLayout()

	self.absoluteWidth = self.width * self.absoluteScale.x
	self.absoluteHeight = self.height * self.absoluteScale.y
end

function uiImage:update()
	if not self.isEnabled then return end

	-- this is a workaround for image primitives showing up before their texture is loaded
	if private[self].initFrames >= 0 then
		if private[self].initFrames == 0 then
			self:show(const.visInit)
			private[self].initShown = true
		end
		private[self].initFrames = private[self].initFrames - 1
	end
end

function uiImage:applyLayout()
	if not self.isEnabled then return end

	if self.isCreated then
		self.wrappedImage:pos(self.absolutePos.x, self.absolutePos.y)
		self.wrappedImage:size(self.absoluteWidth, self.absoluteHeight)
		self.wrappedImage:visible(self.absoluteVisibility)
	end
end

-- sets the image file path
-- @param path a file path relative to the addon's directory
function uiImage:path(path)
    if not self.isEnabled then return end

	if private[self].path ~= path then
		private[self].path = path

		if self.isCreated then
			setPath(self, private[self].path)
		end
	end
end

-- sets the unscaled image size, if a scale is set it will be applied on top of this
function uiImage:size(w, h)
	if not self.isEnabled then return end

	if self.width ~= w or self.height ~= h then
		self.width = w;
		self.height = h;

		self:layoutElement()
	end
end

function uiImage:repeat_xy(x, y)
	if not self.isEnabled then return end

	if private[self].repeatX ~= x or private[self].repeatY ~= y then
		private[self].repeatX = x
		private[self].repeatY = y

		if self.isCreated then
			self.wrappedImage:repeat_xy(x, y)
		end
	end
end

-- returns true if the specified absolute screen coordinates are inside the image
function uiImage:hover(x ,y)
	if not self.isEnabled or not self.isCreated then return false end

	return self.wrappedImage:hover(x, y)
end

-- sets image color (and alpha when color table is passed)
-- @param r red color value 0..255 or color table (rgba)
-- @param g green color value 0..255
-- @param b blue color value 0..255
function uiImage:color(r, g, b)
	if not self.isEnabled then return end
	if r == nil then utils:log('uiImage:color missing parameter r!', 4) return end

	local a = nil

    -- color table returned by utils:colorFromHex
    if type(r) == 'table' and r.r and r.g and r.b and r.a then
        a = r.a
        b = r.b
        g = r.g
        r = r.r
    end

    if private[self].color.r ~= r or private[self].color.g ~= g or private[self].color.b ~= b then
		private[self].color.r = r
		private[self].color.g = g
		private[self].color.b = b

        if self.isCreated then
			self.wrappedImage:color(r, g, b)
		end
    end

    if a then
        self:alpha(a)
    end
end

-- sets image alpha
-- @param a alpha value as integer in range 0 .. 255
function uiImage:alpha(a)
    if not self.isEnabled then return end
	if a == nil then utils:log('uiImage:alpha missing parameter a!', 4) return end

	if private[self].color.a ~= a then
		private[self].color.a = a

		if self.isCreated then
			self.wrappedImage:alpha(private[self].color.a * private[self].opacity)
		end
	end
end

-- sets a secondary multiplicative alpha value, allows for temporarily changing alpha while preserving the value set via layout colors
-- @param o opacity value as double in range 0.0 .. 1.0
function uiImage:opacity(o)
    if not self.isEnabled then return end
	if o == nil then utils:log('uiImage:opacity missing parameter o!', 4) return end

	if private[self].opacity ~= o then
		private[self].opacity = o

		if self.isCreated then
			self.wrappedImage:alpha(private[self].color.a * private[self].opacity)
		end
	end
end

return uiImage