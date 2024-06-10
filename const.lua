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

local const = {
    barTypeHp = 'barTypeHp',
    barTypeMp = 'barTypeMp',
    barTypeTp = 'barTypeTp',

    xmlExtension = '.xml',
    dataDir = 'data/',
    layoutDir = 'layouts/',
    layoutAllianceSuffix = '_alliance',
    defaultLayout = 'xiv',

    maxBuffs = 32,
    baseResY = 1440, -- default positions and scales are based on a 1440p screen

    castRange = 20.79,
    targetRange = 50,

    -- visibility flag IDs
    visDefault = 1, -- the default flag to use when no flag is specified
    visOutsideZone = 2, -- hide elements based on the player being outside the current zone
    visFeature = 3, -- for general UI features like icons that show up, etc.
    visKeyboard = 4, -- temporarily hide UI by holding down a key
    visInit = 5, -- for delayed showing of newly loaded images
    visCutscene = 6, -- hide UI during cutscenes
    visSolo = 7, -- hide UI while solo
    visZoning = 8 -- hide UI while zoning
}

return const