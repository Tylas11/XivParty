--[[
	Copyright © 2021, Tylas
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

local jobs = require('jobs')

local jobIcon = {}
jobIcon.__index = jobIcon

function jobIcon:init()
	local obj = {}
	setmetatable(obj, jobIcon) -- make handle lookup
	
	obj.jobHighlight = utils:createImage(layout.jobIcon.imgHighlight, layout.scale)
	obj.jobHighlight:opacity(0)
	obj.jobHighlight:show()
	
	obj.jobBg = utils:createImage(layout.jobIcon.imgBg, layout.scale)
	obj.jobBg:opacity(0)
	obj.jobBg:show()
	
	obj.jobGradient = utils:createImage(layout.jobIcon.imgGradient, layout.scale)
	obj.jobGradient:opacity(0)
	obj.jobGradient:show()
	
	obj.jobIcon = utils:createImage(layout.jobIcon.imgIcon, layout.scale)
	obj.jobIcon:opacity(0)
	obj.jobIcon:show()
	
	obj.jobFrame = utils:createImage(layout.jobIcon.imgFrame, layout.scale)
	obj.jobFrame:opacity(0)
	obj.jobFrame:show()
	
	obj.highlightOffset = utils:coord(layout.jobIcon.imgHighlight.offset)
	obj.bgOffset = utils:coord(layout.jobIcon.imgBg.offset)
	obj.gradientOffset = utils:coord(layout.jobIcon.imgGradient.offset)
	obj.iconOffset = utils:coord(layout.jobIcon.imgIcon.offset)
	obj.frameOffset = utils:coord(layout.jobIcon.imgFrame.offset)
	
	return obj
end

function jobIcon:dispose()
	self.jobHighlight:dispose()
	self.jobBg:dispose()
	self.jobGradient:dispose()
	self.jobIcon:dispose()
	self.jobFrame:dispose()
	
	setmetatable(self, nil)
end

function jobIcon:update(player, isOutsideZone)
	local opacity = 0
	local highlightOpacity = 0
	
	if not isOutsideZone and player.job then
		self.jobIcon:path(windower.addon_path .. layout.jobIcon.path .. player.job .. '.png')
		self.jobBg:color(jobs:getRoleColor(player.job, layout.jobIcon.colors))
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

function jobIcon:pos(x, y)
	self.jobHighlight:pos(x + self.highlightOffset.x, y + self.highlightOffset.y)
	self.jobBg:pos(x + self.bgOffset.x, y + self.bgOffset.y)
	self.jobGradient:pos(x + self.gradientOffset.x, y + self.gradientOffset.y)
	self.jobIcon:pos(x + self.iconOffset.x, y + self.iconOffset.y)
	self.jobFrame:pos(x + self.frameOffset.x, y + self.frameOffset.y)
end

function jobIcon:show()
	self.jobHighlight:show()
	self.jobBg:show()
	self.jobGradient:show()
	self.jobIcon:show()
	self.jobFrame:show()
end

function jobIcon:hide()
	self.jobHighlight:hide()
	self.jobBg:hide()
	self.jobGradient:hide()
	self.jobIcon:hide()
	self.jobFrame:hide()
end

return jobIcon