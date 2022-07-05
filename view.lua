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

local pl = require('partylist')
local player = require('player')

local view = {}

local isInitialized = false
local isSetupEnabled = false

local partyLists = T{} -- UI elements for each party
local setupParties = T{} -- setup data for each party

function view:init(model)
	if isInitialized then return end

	if not model then
		utils:log('view:init missing parameter model!', 4)
		return
	end
	
	utils:log('Initializing view')

	for i = 0, 2 do
		partyLists[i] = pl:init(model.parties[i], self:getSettingsByIndex(i))
	end

	isInitialized = true
end

function view:dispose()
	if not isInitialized then return end

	utils:log('Disposing view')

	for i = 0, 2 do
		if setupParties[i] then
			for sp in setupParties[i]:it() do
				sp:dispose()
			end
		end
		partyLists[i]:dispose()
	end
	setupParties:clear()
	partyLists:clear()

	isInitialized = false
end

function view:getSettingsByIndex(index)
	if index == 0 then return settings.party end
	if index == 1 then return settings.alliance1 end
	if index == 2 then return settings.alliance2 end

	utils:log('getSettingsByIndex: index ' .. tostring(index) .. 'not found!', 4)
	return nil
end

function view:setupEnabled(enable)
	if not isInitialized then return end
	if enable == nil then return isSetupEnabled end

	isSetupEnabled = enable

	for i = 0, 2 do
		if enable and not setupParties[i] then
			setupParties[i] = self:createSetupData(i == 0)
		end
		partyLists[i]:setupEnabled(enable, setupParties[i])
	end
end

-- creates party and buffs for setup mode
function view:createSetupData(isMainParty)
	local setupParty = T{}

	for i = 0, 5 do
		local j = res.jobs[math.random(1,22)].ens
		local sj = res.jobs[math.random(1,22)].ens
	
		local p = player:init('Player' .. tostring(i + 1), (i + 1))
		p:createSetupData(j, sj, isMainParty)
		setupParty[i] = p
	end
	
	setupParty[0].isLeader = true
	if isMainParty then
		setupParty[math.random(0,5)].isSelected = true
	end

	return setupParty
end

function view:update(force)
	if not isInitialized then return end
	
	for i = 0, 2 do
		partyLists[i]:update(force)
	end
end

function view:show()
	if not isInitialized then return end
	
	for i = 0, 2 do
		partyLists[i]:show()
	end
end

function view:hide()
	if not isInitialized then return end

	for i = 0, 2 do
		partyLists[i]:hide()
	end
end

return view