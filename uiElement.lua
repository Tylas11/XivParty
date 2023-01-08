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
require('tables')

-- imports
local classes = require('classes')
local utils = require('utils')
local const = require('const')

-- create the class
local uiElement = classes.class()

-- static storage for private variables, access using private[self] to keep separate values for each instance
local private = {}

-- constructor
-- @param layout optional: layout table defining this UI element. should contain an 'enabled' flag (bool) and a 'pos' (L{ x, y } from windower lists library)
-- @return true if the UI element is enabled
function uiElement:init(layout)
    private[self] = {}
    private[self].visibility = {}
    private[self].visibility[const.visDefault] = true
    self.absoluteVisibility = true

    self.parent = nil
    self.isCreated = false

    self.isEnabled = true
    if layout and layout.enabled ~= nil then
        self.isEnabled = layout.enabled
    end

    self.posX = 0
    self.posY = 0
    if layout and layout.pos then
        local pos = utils:coord(layout.pos)
        self.posX = pos.x
        self.posY = pos.y
    end

    self.scaleX = 1
    self.scaleY = 1
    if layout and layout.scale then
        local scale = utils:coord(layout.scale)
        self.scaleX = scale.x
        self.scaleY = scale.y
    end

    -- absolute screen position and scale, based on own and parent's coords and dimensions
    self.absolutePos = { x = 0, y = 0 }
    self.absoluteScale = { x = 1, y = 1 }

    self.zOrder = 0
    if layout and layout.zOrder then
        self.zOrder = layout.zOrder
    end

    self.snapToRaster = false
    if layout and layout.snapToRaster ~= nil then
        self.snapToRaster = layout.snapToRaster
    end

    return self.isEnabled
end

-- override this to free any resources created during init or createPrimitives (also call super:dispose!)
function uiElement:dispose()
    self.isEnabled = false -- disposed elements are not meant to be reused, so deactivate them
    self.isCreated = false

    private[self] = nil
end

-- override this function to create the windower primitives of this element
-- design convention: derived classes shall store all values that need to be set on the primitives,
-- even if they havent been created yet, and apply them on creation. this function must be safe
-- to be called multiple times without creating duplicate primitives.
function uiElement:createPrimitives()
    self.isCreated = true
    self:applyLayout()
end

-- updates and applies the layout
function uiElement:layoutElement()
    if not self.isEnabled then return end

    self:updateLayout()
    self:applyLayout()
end

-- calculates the element's absolute position and scale based on its parent
-- override this to calculate more values like sizes, etc
function uiElement:updateLayout()
    if not self.isEnabled then return end

    if self.parent then
        self.absolutePos.x = self.parent.absolutePos.x + self.posX * self.parent.absoluteScale.x
        self.absolutePos.y = self.parent.absolutePos.y + self.posY * self.parent.absoluteScale.y
        self.absoluteScale.x = self.parent.absoluteScale.x * self.scaleX
        self.absoluteScale.y = self.parent.absoluteScale.y * self.scaleY

        self.absoluteVisibility = self.parent.absoluteVisibility and self:getVisibility()
    else
        self.absolutePos.x = self.posX
        self.absolutePos.y = self.posY
        self.absoluteScale.x = self.scaleX
        self.absoluteScale.y = self.scaleY

        self.absoluteVisibility = self:getVisibility()
    end

    if self.snapToRaster then
        self.absolutePos.x = math.floor(self.absolutePos.x)
        self.absolutePos.y = math.floor(self.absolutePos.y)
    end
end

-- applies the absolute position and dimensions to windower primitives
-- should be overridden in classes that create primitives
function uiElement:applyLayout()
    -- nothing to do
end

-- called every frame (prerender) for every element
function uiElement:update()
    -- nothing to do
end

-- sets the position of this UI element. children will have their position set relative to their parent
-- @param x horizontal position in screen coordinates (origin: left)
-- @param y vertical position in screen coordinates (origin: top)
function uiElement:pos(x, y)
    if not self.isEnabled then return end

    if self.posX ~= x or self.posY ~= y then
        self.posX = x
	    self.posY = y

        self:layoutElement()
    end
end

-- scales the UI element. scaling affects the pos and size of all children of this element
-- @param x horizontal scale factor
-- @param y vertical scale factor
function uiElement:scale(x, y)
    if not self.isEnabled then return end

    if self.scaleX ~= x or self.scaleY ~= y then
        self.scaleX = x
	    self.scaleY = y

        self:layoutElement()
    end
end

-- sets windower primitives visible
-- @param flagId an integer identifying a boolean flag. only when all flags are true, the primitive will be come visible
function uiElement:show(flagId)
    self:visible(true, flagId)
end

-- sets windower primitives invisible
-- @param flag an integer identifying a boolean flag. only when all flags are true, the primitive will be come visible
function uiElement:hide(flagId)
    self:visible(false, flagId)
end

-- sets windower primitives' visibility
-- @param isVisible true to set visible, false to set invisible. defaults to false
-- @param flag an integer identifying a boolean flag. only when all flags are true, the primitive will be come visible
function uiElement:visible(isVisible, flagId)
    if not self.isEnabled then return end
    if not isVisible then isVisible = false end
    if not flagId then flagId = const.visDefault end

    if private[self].visibility[flagId] ~= isVisible then
        private[self].visibility[flagId] = isVisible

        self:layoutElement()
    end
end

-- returns the overall visibility based on all visibility flags
function uiElement:getVisibility()
    return utils:all(private[self].visibility)
end

return uiElement