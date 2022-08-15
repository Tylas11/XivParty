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
local texts = require('texts')

-- imports
local classes = require('classes')
local uiBase = require('uiBase')
local utils = require('utils')

-- create the class, derive from uiBase
local uiText = classes.class(uiBase)

function uiText:init(textLayout)
    if self.super.init(self, textLayout) then
        local alignRight = textLayout.alignRight
        if alignRight == nil then alignRight = false end -- 'alignRight' might not exist in the layout for this text

        self.alignRight = alignRight

        local textSettings = {
            flags = {
                draggable = false,
                right = alignRight
            }
        }

        self.wrappedText = texts.new(textSettings)
        self.wrappedText:bg_visible(false)

        self.wrappedText:font(textLayout.font, 'Arial') -- Arial is the fallback font
	    self.wrappedText:size(textLayout.size)
        
        local color = utils:colorFromHex(textLayout.color)
        local stroke = utils:colorFromHex(textLayout.stroke)
        
        self.wrappedText:color(color.r, color.g, color.b)
        self.wrappedText:alpha(color.a)
        self.wrappedText:stroke_color(stroke.r, stroke.g, stroke.b)
        self.wrappedText:stroke_alpha(stroke.a)
        
        self.wrappedText:stroke_width(textLayout.strokeWidth)

        self.text = nil
        self.textColor = {}
        self.textAlpha = nil
    end
end

function uiText:dispose()
    if not self.enabled then return end

    texts.destroy(self.wrappedText)
    self.super.dispose(self)
end

function uiText:applyPos()
    if not self.enabled then return end

    -- apply offset
    local x = self.posX + self.offsetX
    local y = self.posY + self.offsetY

    if self.alignRight then
        -- right aligned text coordinates start at the right side of the screen
        x = x - windower.get_windower_settings().ui_x_res
    end
    
    self.wrappedText:pos(x, y)
end

function uiText:update(text)
    if not self.enabled then return end

	if text ~= self.text then
		self.text = text
		self.wrappedText:text(text)
	end
end

function uiText:color(r,g,b)
    if not self.enabled then return end

    local a = nil

    -- color object returned by utils:colorFromHex
    if type(r) == 'table' and r.r and r.g and r.b and r.a then
        a = r.a
        b = r.b
        g = r.g
        r = r.r
    end

    if self.textColor.r ~= r or self.textColor.g ~= g or self.textColor.b ~= b then
        self.textColor.r = r
        self.textColor.g = g
        self.textColor.b = b

        self.wrappedText:color(r,g,b)
    end

    if a then
        self:alpha(a)
    end
end

function uiText:alpha(a)
    if not self.enabled then return end

    if self.textAlpha ~= a then
	    self.textAlpha = a
	    self.wrappedText:alpha(a)
    end
end

function uiText:show()
    if not self.enabled then return end

	self.wrappedText:show()
end

function uiText:hide()
    if not self.enabled then return end

	self.wrappedText:hide()
end

return uiText