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
local uiLeader = classes.class(uiBase)

function uiLeader:init(leaderLayout, scale)
	if self.super.init(self, leaderLayout) then
		self.leaderLayout = leaderLayout
		self.scale = scale

		self.imgParty = self:addChild(uiImage.new(leaderLayout.imgParty, scale))
		self.imgParty:opacity(0)

		self.imgAlliance = self:addChild(uiImage.new(leaderLayout.imgAlliance, scale))
		self.imgAlliance:opacity(0)

        self.imgQuarterMaster = self:addChild(uiImage.new(leaderLayout.imgQuarterMaster, scale))
		self.imgQuarterMaster:opacity(0)
	end
end

function uiLeader:update(player)
	if player.isLeader then
		self.imgParty:opacity(1)
	else
		self.imgParty:opacity(0)
	end
	
	if player.isAllianceLeader then
		self.imgAlliance:opacity(1)
	else
		self.imgAlliance:opacity(0)
	end
	
	if player.isQuarterMaster then
		self.imgQuarterMaster:opacity(1)
	else
		self.imgQuarterMaster:opacity(0)
	end
end

return uiLeader