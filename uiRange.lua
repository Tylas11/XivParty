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

-- imports
local classes = require('classes')
local uiBase = require('uiBase')
local uiImage = require('uiImage')

-- create the class, derive from uiBase
local uiRange = classes.class(uiBase)

function uiRange:init(rangeLayout, scale)
	if self.super.init(self, rangeLayout) then
		self.rangeLayout = rangeLayout
		self.scale = scale

		self.imgNear = self:addChild(uiImage.new(rangeLayout.imgNear, scale))
		self.imgNear:opacity(0)

		self.imgFar = self:addChild(uiImage.new(rangeLayout.imgFar, scale))
		self.imgFar:opacity(0)
	end
end

function uiRange:update(player, isOutsideZone)
	if not self.enabled then return end

	local opacity = 0
	local opacityFar = 0

	if player.distance and not isOutsideZone then
		if settings.rangeIndicator > 0 and player.distance:sqrt() <= settings.rangeIndicator then
			opacity = 1
			opacityFar = 0
		elseif settings.rangeIndicatorFar > 0 and player.distance:sqrt() <= settings.rangeIndicatorFar then
			opacity = 0
			opacityFar = 1
		end
	end
	
	self.imgNear:opacity(opacity)
	self.imgFar:opacity(opacityFar)
end

return uiRange