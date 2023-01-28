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

local classes = {}

-- Baseclass of all objects.
classes.Object = {}
classes.Object.class = classes.Object

--- Nullary constructor.
function classes.Object:init(...)
end

--- Base alloc method.
function classes.Object.alloc(mastertable)
	return setmetatable({}, {__index = classes.Object, __newindex = mastertable})
end

--- Base new method.
function classes.Object.new(...)
	return classes.Object.alloc({}):init(...)
end

--- Checks if this object is an instance of class.
-- @param class The class object to check.
-- @return Returns true if this object is an instance of class, false otherwise.
function classes.Object:instanceOf(class)
	-- Recurse up the supertypes until class is found, or until the supertype is not part of the inheritance tree.
	if self.class == class then
		return true
	end
	if self.super then
		return self.super.__base:instanceOf(class)
	end
	return false
end

--- Creates a new class.
-- @param baseclass The Baseclass of this class, or nil.
-- @return A new class reference.
function classes.class(baseclass)
	-- Create the class definition and metatable.
	local classdef = {}

	-- Find the super class, either Object or user-defined.
	baseclass = baseclass or classes.Object

	-- If this class definition does not know of a function, it will 'look up' to the Baseclass via the __index of the metatable.
	setmetatable(classdef, {__index = baseclass})

	-- All class instances have a reference to the class object.
	classdef.class = classdef

	-- Looks up a key 'k' by traversing up the inheritance tree until a match is found.
	local function lookup(t, k, rootInstance, fromSuper)
		-- Quick value lookup, usually anything that is not a function will be set on the root instance.
		local val = rawget(rootInstance, k)
		if val ~= nil then return val end

		-- When calling via the 'super' reference, we start traversing from that superclass.
		-- Otherwise always start at the root of the inheritance tree.
		local current
		if fromSuper then
			current = rawget(t, '__base')
		else
			current = rootInstance
		end
		repeat
			val = rawget(current.class, k)
			if val ~= nil then
				if type(val) == 'function' and val ~= classes.Object.instanceOf then
					-- Instead of returning the found function (which would be run with the original instance as self),
					-- we pack it in another function which calls it with the 'current' level of the inheritance tree.
					return function(tt, ...)
						return val(current, ...)
					end
				else -- When calling instanceOf (which requires the root instance to work) or anything that's not function.
					return val
				end
			end

			-- We did not find the function in the class definition so we repeat the lookup on super.
			if current.super then
				current = rawget(current.super, '__base')
			else
				current = nil
			end
		until val ~= nil or current == nil
	end

	--- Recursively allocates the inheritance tree of the instance.
	-- @param rootInstance The root of the inheritance tree.
	-- @return Returns the instance with the allocated inheritance tree.
	function classdef.alloc(rootInstance)
		local instance = {
			class = classdef,
			super = { __base = baseclass.alloc(rootInstance) }
		}

		setmetatable(instance.super, {__index = function(t, k) return lookup(t, k, rootInstance, true) end, __newindex = rootInstance})
		setmetatable(instance, {__index = function(t, k) return lookup(t, k, rootInstance, false) end, __newindex = rootInstance})

		return instance
	end

	--- Constructs a new instance from this class definition.
	-- @param arg Arguments to this class' constructor
	-- @return Returns a new instance of this class.
	function classdef.new(...)
		-- Create the empty object.
		local instance = {}
		instance.class = classdef

		-- Store the reference to the superclass instance in a separate table with its own metatable.
		-- This way we can tell accesses via self.super apart (e.g. self:function() vs. self.super:function()).
		instance.super = { __base = baseclass.alloc(instance) }

		-- Accesses/reads (__index) get redirected to a lookup function which will traverse up the inheritance tree.
		-- Assignment/writes (__newindex) get directed to the root instance itself.
		setmetatable(instance.super, { __index = function(t, k) return lookup(t, k, instance, true) end })
		setmetatable(instance, {__index = function(t, k) return lookup(t, k, instance, false) end})

		-- Finally, init the object, it is up to the programmer to choose to call the super init method.
		instance:init(...)

		return instance
	end

	-- Finally, return the class we created.
	return classdef
end

return classes

-- CREDITS: based on Paul Moore's classes library

--[[
    The classes library enables simple OOP constructs using prototypes and meta-tables.
   
    @author Paul Moore
   
    Copyright (C) 2011 by Strange Ideas Software
   
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
   
    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
   
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
]]