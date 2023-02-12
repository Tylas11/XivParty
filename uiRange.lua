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

-- imports
local classes = require('classes')
local uiContainer = require('uiContainer')
local uiImage = require('uiImage')
local uiText = require('uiText')
local const = require('const')

-- create the class, derive from uiContainer
local uiRange = classes.class(uiContainer)

function uiRange:init(layout, player)
	if self.super:init(layout) then
		self.layout = layout
		self.player = player

		self.imgNear = self:addChild(uiImage.new(layout.imgNear))
		self.imgNear:hide(const.visFeature)

		self.imgFar = self:addChild(uiImage.new(layout.imgFar))
		self.imgFar:hide(const.visFeature)

		self.txtDistance = self:addChild(uiText.new(layout.txtDistance))
	end
end

function uiRange:setPlayer(player)
	self.player = player
end

function uiRange:update()
	if not self.isEnabled then return end

	self:updateIndicators()
	self:updateNumeric()

	self.super:update()
end

function uiRange:updateIndicators()
	local visibility = false
	local visibilityFar = false

	if not Settings.rangeNumeric and self.player.distance and not self.player.isOutsideZone then
		if Settings.rangeIndicator > 0 and self.player.distance <= Settings.rangeIndicator then
			visibility = true
			visibilityFar = false
		elseif Settings.rangeIndicatorFar > 0 and self.player.distance <= Settings.rangeIndicatorFar then
			visibility = false
			visibilityFar = true
		end
	end

	self.imgNear:visible(visibility, const.visFeature)
	self.imgFar:visible(visibilityFar, const.visFeature)
end

function uiRange:updateNumeric()
	local distanceString = ''

	if Settings.rangeNumeric and not self.player.isMainPlayer and not self.player.isOutsideZone then
		if self.player.distance then
			distanceString = string.format("%.2f", self.player.distance)
		else
			distanceString = '?'
		end
	end

	self.txtDistance:update(distanceString)
end

return uiRange