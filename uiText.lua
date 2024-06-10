--[[
    Copyright © 2024, Tylas
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
require('strings')

-- imports
local classes = require('classes')
local uiElement = require('uiElement')
local utils = require('utils')

-- create the class, derive from uiElement
local uiText = classes.class(uiElement)

-- static storage for private variables, access using private[self] to keep separate values for each instance
local private = {}

function uiText:init(layout)
    if self.super:init(layout) then
        private[self] = {}

        private[self].alignRight = false
        if layout and layout.alignRight ~= nil then
            private[self].alignRight = layout.alignRight
        end

        private[self].maxChars = 0
        if layout and layout.maxChars ~= nil then
            private[self].maxChars = layout.maxChars
        end

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

        private[self].stroke = {}
        private[self].stroke.r = 255
        private[self].stroke.g = 255
        private[self].stroke.b = 255
        private[self].stroke.a = 255
        if layout and layout.stroke then
            local s = utils:colorFromHex(layout.stroke)
            if s then
                private[self].stroke = s
            end
        end

        private[self].font = layout.font
        private[self].fontSize = layout.size
        private[self].strokeWidth = layout.strokeWidth
    end
end

function uiText:dispose()
    if not self.isEnabled then return end

    if self.isCreated then
        texts.destroy(self.wrappedText)
        RefCountText = RefCountText - 1
    end
    private[self] = nil

    self.super:dispose()
end

local function setTrimmedText(wrappedText, text, maxChars)
    if text and maxChars > 0 then
        if #text > maxChars then
            text = text:slice(1, math.max(1, maxChars - 1)) .. '...'
        end
    end

    wrappedText:text(text)
end

-- NOTE: z-ordering for texts works, but only relative to other texts. windower seems to always place texts above images!
function uiText:createPrimitives()
    if not self.isEnabled or self.isCreated then return end

    local textSettings = {
        flags = {
            draggable = false,
            right = private[self].alignRight
        }
    }

    self.wrappedText = texts.new(textSettings)
    RefCountText = RefCountText + 1
    self.wrappedText:bg_visible(false)
    self.wrappedText:font(private[self].font, 'Arial') -- Arial is the fallback font
    setTrimmedText(self.wrappedText, private[self].text, private[self].maxChars)

    self.wrappedText:color(private[self].color.r, private[self].color.g, private[self].color.b)
    self.wrappedText:alpha(private[self].color.a)
    self.wrappedText:stroke_color(private[self].stroke.r, private[self].stroke.g, private[self].stroke.b)
    self.wrappedText:stroke_alpha(private[self].stroke.a)

    self.super:createPrimitives() -- this will call applyLayout()
end

function uiText:applyLayout()
    if not self.isEnabled or not self.isCreated then return end

    local x = self.absolutePos.x
    local y = self.absolutePos.y

    if private[self].alignRight then
        -- right aligned text coordinates start at the right side of the screen
        x = x - windower.get_windower_settings().ui_x_res
    end

    self.wrappedText:pos(x, y)
    self.wrappedText:size(private[self].fontSize * self.absoluteScale.y)
    self.wrappedText:stroke_width(private[self].strokeWidth * self.absoluteScale.x)
    self.wrappedText:visible(self.absoluteVisibility)
end

function uiText:update(text)
    if not self.isEnabled then return end

    if private[self].text ~= text then
        private[self].text = text

        if self.isCreated then
            setTrimmedText(self.wrappedText, private[self].text, private[self].maxChars)
        end
    end
end

function uiText:color(r,g,b)
    if not self.isEnabled then return end
    if r == nil then utils:log('uiText:color missing parameter r!', 4) return end

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
            self.wrappedText:color(r,g,b)
        end
    end

    if a then
        self:alpha(a)
    end
end

function uiText:alpha(a)
    if not self.isEnabled then return end
    if a == nil then utils:log('uiText:alpha missing parameter a!', 4) return end

    if private[self].color.a ~= a then
        private[self].color.a = a

        if self.isCreated then
            self.wrappedText:alpha(a)
        end
    end
end

return uiText