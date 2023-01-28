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
local jobs = require('jobs')
local const = require('const')

-- create the class, derive from uiContainer
local uiJobIcon = classes.class(uiContainer)

function uiJobIcon:init(layout, player)
	if self.super:init(layout) then
		self.layout = layout
		self.player = player

		self.jobHighlight = self:addChild(uiImage.new(layout.imgHighlight))
		self.jobHighlight:hide(const.visFeature)

		self.jobBg = self:addChild(uiImage.new(layout.imgBg))
		self.jobBg:hide(const.visFeature)

		self.jobGradient = self:addChild(uiImage.new(layout.imgGradient))
		self.jobGradient:hide(const.visFeature)

		self.jobIcon = self:addChild(uiImage.new(layout.imgIcon))
		self.jobIcon:hide(const.visFeature)

		self.jobFrame = self:addChild(uiImage.new(layout.imgFrame))
		self.jobFrame:hide(const.visFeature)
	end
end

function uiJobIcon:setPlayer(player)
	self.player = player
end

function uiJobIcon:update()
	if not self.isEnabled then return end

	local visibility = false
	local highlightVisibility = false

	if not self.player.isOutsideZone and self.player.job then
		self.jobIcon:path(self.layout.path .. self.player.job .. '.png')
		self.jobBg:color(jobs:getRoleColor(self.player.job, self.layout.colors))
		visibility = true

		if self.player.isSelected then
			highlightVisibility = true
		end
	end

	self.jobHighlight:visible(highlightVisibility, const.visFeature)
	self.jobBg:visible(visibility, const.visFeature)
	self.jobGradient:visible(visibility, const.visFeature)
	self.jobIcon:visible(visibility, const.visFeature)
	self.jobFrame:visible(visibility, const.visFeature)

	self.super:update()
end

return uiJobIcon