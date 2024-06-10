--[[
    Copyright © 2024, Tylas
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

-- windower library imports
local res = require('resources')

-- imports
local classes = require('classes')
local uiContainer = require('uiContainer')
local uiJobIcon = require('uiJobIcon')
local uiStatusBar = require('uiStatusBar')
local uiLeader= require('uiLeader')
local uiRange = require('uiRange')
local uiBuffIcons = require('uiBuffIcons')
local uiText = require('uiText')
local uiImage = require('uiImage')
local const = require('const')

-- create the class, derive from uiContainer
local uiListItem = classes.class(uiContainer)

local isDebug = false

function uiListItem:init(layout, player, isUiLocked, itemWidth, itemHeight)
    if self.super:init(layout) then
        self.layout = layout
        self.player = player
        self.isUiLocked = isUiLocked

        self.hover = self:addChild(uiImage.new(layout.hover))
        self.hover:hide(const.visFeature)

        self.cursor = self:addChild(uiImage.new(layout.cursor))
        self.cursor:opacity(0)

        self.hpBar = self:addChild(uiStatusBar.new(layout.hp, const.barTypeHp, player))
        self.mpBar = self:addChild(uiStatusBar.new(layout.mp, const.barTypeMp, player))
        self.tpBar = self:addChild(uiStatusBar.new(layout.tp, const.barTypeTp, player))

        self.jobIcon = self:addChild(uiJobIcon.new(layout.jobIcon, player))

        self.txtName = self:addChild(uiText.new(layout.txtName))
        self.txtZone = self:addChild(uiText.new(layout.txtZone))

        self.txtJob = self:addChild(uiText.new(layout.txtJob))
        self.txtSubJob = self:addChild(uiText.new(layout.txtSubJob))

        self.leader = self:addChild(uiLeader.new(layout.leader, player))

        self.range = self:addChild(uiRange.new(layout.range, player))
        self.buffIcons = self:addChild(uiBuffIcons.new(layout.buffIcons, player))

        self.imgMouse = self:addChild(uiImage.create())
        self.imgMouse:size(math.max(0, itemWidth - 1), math.max(0, itemHeight - 1)) -- reduce size by 1 to prevent hovering over two neighboring items at the same time
        self.imgMouse:alpha(isDebug and 32 or 0)

        self.mouseHandlerId = windower.register_event('mouse', function(type, x, y, delta, blocked)
            return self:handleWindowerMouse(type, x, y, delta, blocked)
        end)
    end
end

function uiListItem:dispose()
    if not self.isEnabled then return end

    if self.mouseHandlerId then
        windower.unregister_event(self.mouseHandlerId)
        self.mouseHandlerId = nil
    end

    self.super:dispose()
end

function uiListItem:setPlayer(player)
    if not self.isEnabled then return end
    if self.player == player then return end

    self.player = player

    self.hpBar:setPlayer(player)
    self.mpBar:setPlayer(player)
    self.tpBar:setPlayer(player)

    self.jobIcon:setPlayer(player)
    self.leader:setPlayer(player)
    self.range:setPlayer(player)
    self.buffIcons:setPlayer(player)
end

function uiListItem:setUiLocked(isUiLocked)
    if not self.isEnabled then return end

    self.isUiLocked = isUiLocked

    if not isUiLocked then
        self.hover:hide(const.visFeature)
    end
end

function uiListItem:update()
    if not self.isEnabled or not self.player then return end

    if self.player.name then
        self.txtName:update(self.player.name)
    else
        self.txtName:update('???')
    end

    self:updateZone()
    self:updateJob()
    self:updateCursor()

    self.super:update()
end

function uiListItem:updateZone()
    local zoneString = ''

    if self.player.zone and self.player.isOutsideZone then
        if self.layout.txtZone.short then
            zoneString = '('..res.zones[self.player.zone]['search']..')'
        else
            zoneString = '('..res.zones[self.player.zone].name..')'
        end
    end

    self.txtZone:update(zoneString)
end

function uiListItem:updateJob()
    local jobString = ''
    local subJobString = ''

    if not self.player.isOutsideZone then
        if self.player.job then
            jobString = self.player.job
            if self.player.jobLvl then
                jobString = jobString .. ' ' .. tostring(self.player.jobLvl)
            end
        end

        if self.player.subJob and self.player.subJob ~= 'MON' then
            subJobString = self.player.subJob
            if self.player.subJobLvl then
                subJobString = subJobString .. ' ' .. tostring(self.player.subJobLvl)
            end
        end
    end

    self.txtJob:update(jobString)
    self.txtSubJob:update(subJobString)
end

function uiListItem:updateCursor()
    local opacity = 0

    if not self.player.isOutsideZone then
        if self.player.isSelected then
            opacity = 1
        elseif self.player.isSubTarget then
            opacity = 0.5
        end
    end

    self.cursor:opacity(opacity)
end

-- handle mouse interaction
function uiListItem:handleWindowerMouse(type, x, y, delta, blocked)
    if blocked then return end

    if self.isUiLocked and Settings.mouseTargeting then
        if self.imgMouse:hover(x, y) and not self.player.isOutsideZone and self.player.isInTargetingRange then
            -- mouse move
            if type == 0 then
                self.hover:show(const.visFeature)
            -- mouse left click
            elseif type == 1 then
                return true
            -- mouse left release
            elseif type == 2 then
                windower.send_command('input /ta ' .. self.player.name)
                return true
            end
        else
            self.hover:hide(const.visFeature)
        end
    else
        self.hover:hide(const.visFeature)
    end

    return false
end

return uiListItem