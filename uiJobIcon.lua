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
local uiContainer = require('uiContainer')
local uiImage = require('uiImage')
local jobs = require('jobs')

-- create the class, derive from uiContainer
local uiJobIcon = classes.class(uiContainer)

function uiJobIcon:init(jobIconLayout)
	if self.super:init(jobIconLayout) then
		self.jobIconLayout = jobIconLayout

		self.jobHighlight = self:addChild(uiImage.new(jobIconLayout.imgHighlight))
		self.jobHighlight:opacity(0)
		
		self.jobBg = self:addChild(uiImage.new(jobIconLayout.imgBg))
		self.jobBg:opacity(0)
		
		self.jobGradient = self:addChild(uiImage.new(jobIconLayout.imgGradient))
		self.jobGradient:opacity(0)
		
		self.jobIcon = self:addChild(uiImage.new(jobIconLayout.imgIcon))
		self.jobIcon:opacity(0)
		
		self.jobFrame = self:addChild(uiImage.new(jobIconLayout.imgFrame))
		self.jobFrame:opacity(0)
	end
end

function uiJobIcon:update(player, isOutsideZone)
	if not self.enabled then return end

	local opacity = 0
	local highlightOpacity = 0
	
	if not isOutsideZone and player.job then
		self.jobIcon:path(self.jobIconLayout.path .. player.job .. '.png')
		self.jobBg:color(jobs:getRoleColor(player.job, self.jobIconLayout.colors))
		opacity = 1
		
		if player.isSelected then
			highlightOpacity = 1
		end
	end
	
	self.jobHighlight:opacity(highlightOpacity)
	self.jobBg:opacity(opacity)
	self.jobGradient:opacity(opacity)
	self.jobIcon:opacity(opacity)
	self.jobFrame:opacity(opacity)
end

return uiJobIcon