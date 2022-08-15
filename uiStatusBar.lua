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
local uiBar = require('uiBar')
local uiText = require('uiText')
local const = require('const')

-- create the class, derive from uiBase
local uiStatusBar = classes.class(uiBase)

function uiStatusBar:init(statusBarLayout, barType, scale)
	if self.super.init(self, statusBarLayout) then
		self.statusBarLayout = statusBarLayout
		self.barType = barType
		self.scale = scale

		self.bar = self:addChild(uiBar.new(statusBarLayout.bar, scale))
		self.text = self:addChild(uiText.new(statusBarLayout.text))

		if self.barType == const.barTypeHp then
			self.hpYellowColor = utils:colorFromHex(statusBarLayout.hpYellowColor)
			self.hpOrangeColor = utils:colorFromHex(statusBarLayout.hpOrangeColor)
			self.hpRedColor = utils:colorFromHex(statusBarLayout.hpRedColor)
		elseif self.barType == const.barTypeTp then
			self.tpFullColor = utils:colorFromHex(statusBarLayout.tpFullColor)
		end

		self.textColor = utils:colorFromHex(statusBarLayout.text.color)
	end
end

function uiStatusBar:update(player, isOutsideZone)
	if not self.enabled then return end

	local val = nil
	local valPercent = nil
	local distance = nil

	if not isOutsideZone then
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
	if distance and distance:sqrt() > 50 then -- cannot target, over 50 distance, mob table not set
		self.bar:opacity(0.25)
	elseif distance and distance:sqrt() > 20.79 then -- out of heal range
		self.bar:opacity(0.5)
	else
		self.bar:opacity(1)
	end
end

return uiStatusBar