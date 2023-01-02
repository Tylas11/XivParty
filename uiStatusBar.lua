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
local uiBar = require('uiBar')
local uiText = require('uiText')
local const = require('const')
local utils = require('utils')

-- create the class, derive from uiContainer
local uiStatusBar = classes.class(uiContainer)

function uiStatusBar:init(layout, barType)
	if self.super:init(layout) then
		self.layout = layout
		self.barType = barType

		self.bar = self:addChild(uiBar.new(layout.bar))
		self.text = self:addChild(uiText.new(layout.text))

		if self.barType == const.barTypeHp then
			self.hpYellowColor = utils:colorFromHex(layout.hpYellowColor)
			self.hpOrangeColor = utils:colorFromHex(layout.hpOrangeColor)
			self.hpRedColor = utils:colorFromHex(layout.hpRedColor)
		elseif self.barType == const.barTypeTp then
			self.tpFullColor = utils:colorFromHex(layout.tpFullColor)
		end

		self.textColor = utils:colorFromHex(layout.text.color)
	end
end

function uiStatusBar:update(player)
	if not self.isEnabled then return end

	local val = nil
	local valPercent = nil
	local distance = nil

	if not player.isOutsideZone then
		if self.barType == const.barTypeHp then
			val = player.hp
			valPercent = player.hpp
		elseif self.barType == const.barTypeMp then
			val = player.mp
			valPercent = player.mpp
		elseif self.barType == const.barTypeTp then
			val = player.tp
			valPercent = player.tpp
		end
		distance = player.distance

		self:show(const.visOutsideZone)
	elseif self.layout.hideOutsideZone then
		self:hide(const.visOutsideZone)
	end

	if not val then val = -1 end
	if not valPercent then valPercent = 0 end

	self.bar:update(valPercent / 100)

	if val < 0 then
		self.text:update('?')
	else
		self.text:update(tostring(val))
	end

	local color = self.textColor
	if self.barType == const.barTypeHp then
		if val >= 0 then
			if valPercent < 25 then
				color = self.hpRedColor
			elseif valPercent < 50 then
				color = self.hpOrangeColor
			elseif valPercent < 75 then
				color = self.hpYellowColor
			end
		end
	elseif self.barType == const.barTypeTp then
		if val >= 1000 then
			color = self.tpFullColor
		end
	end

	self.text:color(color)

	-- distance indication
	if distance and distance:sqrt() < 20.79 then -- in cast range
		self.bar:opacity(1)
	elseif distance and distance:sqrt() < 50 then -- in targeting range
		self.bar:opacity(0.5)
	else
		self.bar:opacity(0.25)
	end
end

return uiStatusBar