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
local uiElement = require('uiElement')
local utils = require('utils')

-- create the class, derive from uiElement
local uiContainer = classes.class(uiElement)

-- constructor
-- @param layout optional: layout table defining this UI element. should contain an 'enabled' flag (bool) and a 'pos' (L{ x, y } from windower lists library)
-- @return true if the UI element is enabled
function uiContainer:init(layout)
    self.super:init(layout)

    self.children = T{}

    return self.isEnabled
end

-- disposes and removes all children
-- override this to free any resources created during init (also call super:dispose!)
function uiContainer:dispose()
    if not self.isEnabled then return end

    self:clearChildren(true)

    self.super:dispose()
end

-- adds a child UI element
-- @param child UI element derived from uiElement
-- @return the added child element
function uiContainer:addChild(child)
    if not self.isEnabled then return end

    if not child:instanceOf(uiElement) then
        utils:log('Failed to add UI child. Class must derive from uiElement!', 4)
        return nil
    end

    self.children:append(child)
    child.parent = self

    child:layoutElement()
    if self.isCreated then
        child:createPrimitives()
    end

    return child
end

-- removes a child UI element
-- @param child UI element that has been added using addChild() before
function uiContainer:removeChild(child)
    if not self.isEnabled then return end

    if not self.children:delete(child) then return end

    child.parent = nil
    child:layoutElement()
end

-- removes all child UI elements
-- @param dispose when true, children are also disposed
function uiContainer:clearChildren(dispose)
    if not self.isEnabled then return end

    for child in self.children:it() do
        child.parent = nil

        if dispose then
            child:dispose()
        else
            child:layoutElement()
        end
    end

    self.children:clear()
end

-- creates the windower primitives of all child UI elements in their z-order.
-- design convention: add all children that require z-ordering before calling this. 
-- adding children afterwards will always place primitives on top of existing ones regardless of configured z-order.
function uiContainer:createPrimitives()
    if not self.isEnabled then return end

    -- sort children by z-order ascending
    utils:insertionSort(self.children, function(a, b) return a.zOrder > b.zOrder end)

    for child in self.children:it() do
        child:createPrimitives()
    end

    self.super:createPrimitives()
end

-- calculates the element's and its children's absolute position and scale based on its parent
function uiContainer:layoutElement()
    if not self.isEnabled then return end

    self.super:layoutElement()

    for child in self.children:it() do
        child:layoutElement()
    end
end

function uiContainer:update()
    if not self.isEnabled then return end

    self.super:update()

    for child in self.children:it() do
        child:update()
    end
end

return uiContainer