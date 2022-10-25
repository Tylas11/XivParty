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
require('tables')

-- imports
local classes = require('classes')
local utils = require('utils')

-- create the class
local uiElement = classes.class()

-- constructor
-- @param baseLayout optional: layout table defining this UI element. should contain an 'enabled' flag (bool) and an 'offset' (L{ x, y } from windower lists library)
-- @return true if the UI element is enabled
function uiElement:init(baseLayout)
    self.parent = nil

    self.enabled = true
    if baseLayout and baseLayout.enabled ~= nil then
        self.enabled = baseLayout.enabled
    end

    self.posX = 0
    self.posY = 0
    if baseLayout and baseLayout.offset then
        local offset = utils:coord(baseLayout.offset) -- TODO: rename to pos in layout
        self.posX = offset.x
        self.posY = offset.y
    end
    
    self.scaleX = 1
    self.scaleY = 1
    if baseLayout and baseLayout.scale then
        local scale = utils:coord(baseLayout.scale)
        self.scaleX = scale.x
        self.scaleY = scale.y
    end

    -- absolute screen position and scale, based on own and parent's coords and dimensions
    self.absolutePos = { x = 0, y = 0 }
    self.absoluteScale = { x = 1, y = 1 }

    return self.enabled
end

-- override this to free any resources created during init (also call super:dispose!)
function uiElement:dispose()
    self.enabled = false -- disposed elements are not meant to be reused, so deactivate them
end

-- calculates the element's absolute position and scale based on its parent
function uiElement:layoutElement()
    if not self.enabled then return end

    if self.parent then
        self.absolutePos.x = self.parent.absolutePos.x + self.posX * self.parent.absoluteScale.x
        self.absolutePos.y = self.parent.absolutePos.y + self.posY * self.parent.absoluteScale.y
        self.absoluteScale.x = self.parent.absoluteScale.x * self.scaleX
        self.absoluteScale.y = self.parent.absoluteScale.y * self.scaleY
    else
        self.absolutePos.x = self.posX
        self.absolutePos.y = self.posY
        self.absoluteScale.x = self.scaleX
        self.absoluteScale.y = self.scaleY
    end

    self:applyLayout()
end

-- applies the absolute position and dimensions to windower primitives
function uiElement:applyLayout()
    -- abstract function, must be overridden
end

-- sets the position of this UI element. children will have their position set relative to their parent
-- @param x horizontal position in screen coordinates (origin: left)
-- @param y vertical position in screen coordinates (origin: top)
function uiElement:pos(x, y)
    if not self.enabled then return end

    if self.posX ~= x or self.posY ~= y then
        self.posX = x
	    self.posY = y

        self:layoutElement()
    end
end

-- scales the UI element. scaling affects the offset and size of all children of this element
-- @param x horizontal scale factor
-- @param y vertical scale factor
function uiElement:scale(x, y)
    if not self.enabled then return end

    if self.scaleX ~= x or self.scaleY ~= y then
        self.scaleX = x
	    self.scaleY = y

        self:layoutElement()
    end
end

-- sets windower primitives visible
function uiElement:show()
    -- abstract function, must be overridden
end

-- sets windower primitives invisible
function uiElement:hide()
    -- abstract function, must be overridden
end

return uiElement