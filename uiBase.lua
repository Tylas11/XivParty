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
local uiBase = classes.class()

-- constructor
-- NOTE: always call this using super.init(self) instead of super:init(), otherwise self will refer to super and you cannot read any variables set on self!
-- @param baseLayout optional: layout table defining this UI element. should contain an 'enabled' flag (bool) and an 'offset' (L{ x, y } from windower lists library)
-- @return true if the UI element is enabled
function uiBase:init(baseLayout)
    self.parent = nil
    self.children = T{}

    self.enabled = true
    if baseLayout and baseLayout.enabled ~= nil then
        self.enabled = baseLayout.enabled
    end

    self.offsetX = 0
    self.offsetY = 0
    if baseLayout and baseLayout.offset then
        local offset = utils:coord(baseLayout.offset)
        self.offsetX = offset.x
        self.offsetY = offset.y
    end

    self.posX = 0
    self.posY = 0

    return self.enabled
end

-- disposes and removes all children
-- override this to free any resources created during init (also call super:dispose!)
function uiBase:dispose()
    if not self.enabled then return end

    for child in self.children:it() do
        child:dispose()
    end
    self:clearChildren()
end

-- adds a child UI element
-- @param child UI element derived from uiBase
-- @return the added child element
function uiBase:addChild(child)
    if not self.enabled then return end

    if not child:instanceOf(uiBase) then
        utils:log('Failed to add UI child. Class must derive from uiBase!', 4)
        return nil
    end

    self.children:append(child)
    child.parent = self

    return child
end

-- removes a child UI element
-- @param child UI element that has been added using uiBase:addChild() before
function uiBase:removeChild(child)
    if not self.enabled then return end

    if not self.children:delete(child) then
        utils:log('Failed to remove UI child, not found!', 4)
        return
    end

    child.parent = nil
end

-- removes all child UI elements
function uiBase:clearChildren()
    if not self.enabled then return end

    for child in self.children:it() do
        child.parent = nil
    end

    self.children:clear()
end

-- sets the position of this UI element. children will have their position set relative to their parent
-- @param x horizontal position in screen coordinates (origin: left)
-- @param y vertical position in screen coordinates (origin: top)
function uiBase:pos(x, y)
    if not self.enabled then return end

    if self.posX ~= x or self.posY ~= y then
        self.posX = x
	    self.posY = y

        self:applyPos()
    end
end

-- sets the offset of this UI element. children will have their position set relative to their parent
-- @param x horizontal offset in screen coordinates (origin: left)
-- @param y vertical offset in screen coordinates (origin: top)
function uiBase:offset(x, y)
    if not self.enabled then return end

    if self.offsetX ~= x or self.offsetY ~= y then
        self.offsetX = x
	    self.offsetY = y

        self:applyPos()
    end
end

-- applies the position and offset to all children
-- should not be called directly as it doesn't filter for unchanged positions, can be useful to force a reposition though
-- override this method if you need to set positions of custom elements that are not derived from uiBase
function uiBase:applyPos()
    if not self.enabled then return end

    -- apply the UI element's position offset
    local x = self.posX + self.offsetX
    local y = self.posY + self.offsetY

    for child in self.children:it() do
        child:pos(x, y)
    end
end

-- TODO: maybe the update method isnt a good idea, what about image and text elements? they usually dont need the "player" as input

-- updates the UI element and all its children. to be called during pre-render
-- @param ... parameters to be passed on to child elements. children must use the same parameters as their parent
function uiBase:update(...)
    if not self.enabled then return end

    for child in self.children:it() do
        child:update(...)
    end
end

-- shows the UI element and all its children
function uiBase:show()
    if not self.enabled then return end

    for child in self.children:it() do
        child:show()
    end
end

-- hides the UI element and all its children
function uiBase:hide()
    if not self.enabled then return end

    for child in self.children:it() do
        child:hide()
    end
end

return uiBase