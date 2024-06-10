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

-- imports
local classes = require('classes')
local uiContainer = require('uiContainer')
local uiImage = require('uiImage')
local utils = require('utils')

-- create the class, derive from uiContainer
local uiBackground = classes.class(uiContainer)

local isDebug = false

function uiBackground:init(layout, contentHeight)
    if self.super:init(layout) then
        self.layout = layout

        if not contentHeight then contentHeight = 0 end
        self.contentHeight = contentHeight

        self.imgTop = self:addChild(uiImage.new(layout.imgTop))
        self.imgMid = self:addChild(uiImage.new(layout.imgMid))
        self.imgBottom = self:addChild(uiImage.new(layout.imgBottom))

        self.sizeMid = utils:coord(layout.imgMid.size)

        if isDebug then -- debug background
            self.imgTop:path('')
            self.imgMid:path('')
            self.imgBottom:path('')

            self.imgTop:color(255,0,0)
            self.imgMid:color(0,255,0)
            self.imgBottom:color(0,0,255)

            self.imgTop:alpha(32)
            self.imgMid:alpha(32)
            self.imgBottom:alpha(32)
        end
    end
end

function uiBackground:setContentHeight(contentHeight)
    self.contentHeight = contentHeight
end

-- sets the height of the content area (excludes top and bottom tiles)
function uiBackground:update()
    if not self.isEnabled then return end

    local contentHeight = self.contentHeight / self.scaleY -- negate vertical scaling, we want to set the height directly

    self.imgMid:size(self.sizeMid.x, contentHeight)
    self.imgMid:repeat_xy(1, math.floor(contentHeight / self.sizeMid.y))
    self.imgBottom:pos(self.imgBottom.posX, self.imgMid.posY + contentHeight)

    self.super:update()
end

return uiBackground