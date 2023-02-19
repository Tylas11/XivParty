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

function uiStatusBar:init(layout, barType, player)
	if self.super:init(layout) then
		self.layout = layout
		self.barType = barType
		self.player = player

		self.bar = self:addChild(uiBar.new(layout.bar))
		self.txtValue = self:addChild(uiText.new(layout.txtValue))

		if self.barType == const.barTypeHp then
			self.hpYellowColor = utils:colorFromHex(layout.hpYellowColor)
			self.hpOrangeColor = utils:colorFromHex(layout.hpOrangeColor)
			self.hpRedColor = utils:colorFromHex(layout.hpRedColor)

			self.hpYellowBarColor = utils:colorFromHex(layout.hpYellowBarColor)
			self.hpOrangeBarColor = utils:colorFromHex(layout.hpOrangeBarColor)
			self.hpRedBarColor = utils:colorFromHex(layout.hpRedBarColor)
		elseif self.barType == const.barTypeTp then
			self.tpFullColor = utils:colorFromHex(layout.tpFullColor)
			self.tpFullBarColor = utils:colorFromHex(layout.tpFullBarColor)
		end

		self.textColor = utils:colorFromHex(layout.txtValue.color)
	end
end

function uiStatusBar:setPlayer(player)
	self.player = player
end

function uiStatusBar:update()
	if not self.isEnabled then return end

	local val = nil
	local valPercent = nil

	if not self.player.isOutsideZone then
		if self.barType == const.barTypeHp then
			val = self.player.hp
			valPercent = self.player.hpp
		elseif self.barType == const.barTypeMp then
			val = self.player.mp
			valPercent = self.player.mpp
		elseif self.barType == const.barTypeTp then
			val = self.player.tp
			valPercent = self.player.tpp
		end

		self:show(const.visOutsideZone)
	elseif self.layout.hideOutsideZone then
		self:hide(const.visOutsideZone)
	end

	if not val then val = -1 end
	if not valPercent then valPercent = 0 end

	self.bar:setValue(valPercent / 100)

	if val < 0 then
		self.txtValue:update('?')
	else
		self.txtValue:update(tostring(val))
	end

	local color = self.textColor
	local barColor = nil
	if self.barType == const.barTypeHp then
		if val >= 0 then
			if valPercent < 25 then
				color = self.hpRedColor
				barColor = self.hpRedBarColor
			elseif valPercent < 50 then
				color = self.hpOrangeColor
				barColor = self.hpOrangeBarColor
			elseif valPercent < 75 then
				color = self.hpYellowColor
				barColor = self.hpYellowBarColor
			end
		end
	elseif self.barType == const.barTypeTp then
		if val >= 1000 then
			color = self.tpFullColor
			barColor = self.tpFullBarColor
		end
	end

	self.txtValue:color(color)
	self.bar:setColor(barColor)

	-- distance indication
	if self.player.isInCastingRange then
		self.bar:opacity(1)
	elseif self.player.isInTargetingRange then
		self.bar:opacity(0.5)
	else
		self.bar:opacity(0.25)
	end

	self.super:update()
end

return uiStatusBar