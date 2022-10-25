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
local uiElement = require('uiElement')
local utils = require('utils')

-- create the class, derive from uiElement
local uiContainer = classes.class(uiElement)

-- constructor
-- @param baseLayout optional: layout table defining this UI element. should contain an 'enabled' flag (bool) and an 'offset' (L{ x, y } from windower lists library)
-- @return true if the UI element is enabled
function uiContainer:init(baseLayout)
    self.super:init(baseLayout)

    self.children = T{}

    return self.enabled
end

-- disposes and removes all children
-- override this to free any resources created during init (also call super:dispose!)
function uiContainer:dispose()
    if not self.enabled then return end

    for child in self.children:it() do
        child:dispose()
    end
    self:clearChildren()

    self.super:dispose()
end

-- adds a child UI element
-- @param child UI element derived from uiElement
-- @return the added child element
function uiContainer:addChild(child)
    if not self.enabled then return end

    if not child:instanceOf(uiElement) then
        utils:log('Failed to add UI child. Class must derive from uiElement!', 4)
        return nil
    end

    self.children:append(child)
    child.parent = self
    child:layoutElement()

    return child
end

-- removes a child UI element
-- @param child UI element that has been added using addChild() before
function uiContainer:removeChild(child)
    if not self.enabled then return end

    if not self.children:delete(child) then return end

    child.parent = nil
    child:layoutElement()
end

-- removes all child UI elements
function uiContainer:clearChildren()
    if not self.enabled then return end

    for child in self.children:it() do
        child.parent = nil
        child:layoutElement()
    end

    self.children:clear()
end

-- calculates the element's and its children's absolute position and scale based on its parent
function uiContainer:layoutElement()
    if not self.enabled then return end

    self.super:layoutElement()

    for child in self.children:it() do
        child:layoutElement()
    end
end

-- shows the UI element and all its children
function uiContainer:show()
    if not self.enabled then return end

    for child in self.children:it() do
        child:show()
    end
end

-- hides the UI element and all its children
function uiContainer:hide()
    if not self.enabled then return end

    for child in self.children:it() do
        child:hide()
    end
end

return uiContainer