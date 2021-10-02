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

require('lists')
local utils = require('utils')

local jobs = {}

-- the role name (dd, healer, etc...) here must match an entry in layout.jobIcons.colors
local dd = 'dd'
local healer = 'healer'
local tank = 'tank'
local support = 'support'
local special = 'special'

jobs.roles = {
	['WAR'] = dd,
	['MNK'] = dd,
	['WHM'] = healer,
	['BLM'] = dd,
	['RDM'] = healer,
	['THF'] = dd,
	['PLD'] = tank,
	['DRK'] = dd,
	['BST'] = dd,
	['BRD'] = support,
	['RNG'] = dd,
	['SAM'] = dd,
	['NIN'] = dd,
	['DRG'] = dd,
	['SMN'] = dd,
	['BLU'] = dd,
	['COR'] = support,
	['PUP'] = tank,
	['DNC'] = dd,
	['SCH'] = healer,
	['GEO'] = support,
	['RUN'] = tank,
	['SPC'] = special,
	['MON'] = dd
}

-- model IDs are needed to resolve name conflicts between trust I / II variants
-- for some trusts the ID is not available, but it will still work as long as the one that comes first in the list has an ID if the other doesnt
jobs.trusts = L{
	-- tanks
	{ name = 'Amchuchu', job = 'RUN', subJob = 'WAR' },
	{ name = 'ArkEV', job = 'PLD', subJob = 'WHM' },
	{ name = 'ArkHM', job = 'WAR', subJob = 'NIN' },
	{ name = 'August', job = 'PLD', subJob = 'WAR' },
	{ name = 'Curilla', job = 'PLD' },
	{ name = 'Gessho', job = 'NIN', subJob = 'WAR' },
	{ name = 'Mnejing', job = 'PLD', subJob = 'WAR' },
	{ name = 'Rahal', job = 'PLD', subJob = 'WAR' },
	{ name = 'Rughadjeen', job = 'PLD' },
	{ name = 'Trion', job = 'PLD', subJob = 'WAR' },
	{ name = 'Valaineral', job = 'PLD', subJob = 'WAR' },
	-- melee
	{ name = 'Abenzio', job = 'THF', subJob = 'WAR' },
	{ name = 'Abquhbah', job = 'WAR' },
	{ name = 'Aldo', job = 'THF', model = 3034 },
	{ name = 'Areuhat', job = 'WAR' },
	{ name = 'ArkGK', job = 'SAM', subJob = 'DRG' },
	{ name = 'ArkMR', job = 'BST', subJob = 'THF' },
	{ name = 'Ayame', job = 'SAM', model = 3004 },
	{ name = 'BabbanMheillea', job = 'MNK' },
	{ name = 'Balamor', job = 'DRK' },
	{ name = 'Chacharoon', job = 'THF' },
	{ name = 'Cid', job = 'WAR' },
	{ name = 'Darrcuiln', job = 'SPC' }, -- special / beast
	{ name = 'Excenmille', job = 'PLD', model = 3003 },
	{ name = 'Excenmille', job = 'SPC' }, -- Excenmille (S), special
	{ name = 'Fablinix', job = 'RDM', subJob = 'BLM' },
	{ name = 'Gilgamesh', job = 'SAM' },
	{ name = 'Halver', job = 'PLD', subJob = 'WAR' },
	{ name = 'Ingrid', job = 'WAR', subJob = 'WHM', model = 3102 }, -- Ingrid II
	{ name = 'Iroha', job = 'SAM', model = 3111 },
	{ name = 'Iroha', job = 'SAM', subJob = 'WHM', model = 3112 }, -- Iroha II
	{ name = 'IronEater', job = 'WAR' },
	{ name = 'Klara', job = 'WAR' },
	{ name = 'LehkoHabhoka', job = 'THF', subJob = 'BLM' },
	{ name = 'LheLhangavo', job = 'MNK' },
	{ name = 'LhuMhakaracca', job = 'BST', subJob = 'WAR' },
	{ name = 'Lilisette', job = 'DNC', model = 3049 },
	{ name = 'Lilisette', job = 'DNC', model = 3084 }, -- Lilisette II
	{ name = 'Lion', job = 'THF', model = 3011 },
	{ name = 'Lion', job = 'THF', subJob = 'NIN', model = 3081 }, -- Lion II
	{ name = 'Luzaf', job = 'COR', subJob = 'NIN' },
	{ name = 'Maat', job = 'MNK', model = 3037 },
	{ name = 'Maximilian', job = 'WAR', subJob = 'THF' },
	{ name = 'Mayakov', job = 'DNC' },
	{ name = 'Mildaurion', job = 'PLD', subJob = 'WAR' },
	{ name = 'Morimar', job = 'BST' },
	{ name = 'Mumor', job = 'DNC', subJob = 'WAR', model = 3050 },
	{ name = 'NajaSalaheem', job = 'MNK', subJob = 'WAR', model = 3016 },
	{ name = 'Naji', job = 'WAR' },
	{ name = 'NanaaMihgo', job = 'THF' },
	{ name = 'Nashmeira', job = 'PUP', subJob = 'WHM', model = 3027 },
	{ name = 'Noillurie', job = 'SAM', subJob = 'PLD' },
	{ name = 'Prishe', job = 'MNK', subJob = 'WHM', model = 3017 },
	{ name = 'Prishe', job = 'MNK', subJob = 'WHM', model = 3082 }, -- Prishe II
	{ name = 'Rainemard', job = 'RDM' },
	{ name = 'RomaaMihgo', job = 'THF' },
	{ name = 'Rongelouts', job = 'WAR' },
	{ name = 'Selh\'teus', job = 'SPC' }, -- special
	{ name = 'ShikareeZ', job = 'DRG', subJob = 'WHM' },
	{ name = 'Tenzen', job = 'SAM', model = 3012 },
	{ name = 'Teodor', job = 'SAM', subJob = 'BLM' },
	{ name = 'UkaTotlihn', job = 'DNC', subJob = 'WAR' },
	{ name = 'Volker', job = 'WAR' },
	{ name = 'Zazarg', job = 'MNK' },
	{ name = 'Zeid', job = 'DRK', model = 3010 },
	{ name = 'Zeid', job = 'DRK', model = 3086 }, -- Zeid II
	-- ranged
	{ name = 'Elivira', job = 'RNG', subJob = 'WAR' },
	{ name = 'Makki-Chebukki', job = 'RNG' },
	{ name = 'Margret', job = 'RNG' },
	{ name = 'Najelith', job = 'RNG' },
	{ name = 'SemihLafihna', job = 'RNG' },
	{ name = 'Tenzen', job = 'RNG', model = 3097 }, -- Tenzen II
	-- caster
	{ name = 'Adelheid', job = 'SCH' },
	{ name = 'Ajido-Marujido', job = 'BLM', subJob = 'RDM' },
	{ name = 'ArkTT', job = 'BLM', subJob = 'DRK' },
	{ name = 'D.Shantotto', job = 'BLM' },
	{ name = 'Gadalar', job = 'BLM' },
	{ name = 'Ingrid', job = 'WHM', model = 3025 },
	{ name = 'Kayeel-Payeel', job = 'BLM' },
	{ name = 'Kukki-Chebukki', job = 'BLM' },
	{ name = 'Leonoyne', job = 'BLM' },
	{ name = 'Mumor', job = 'BLM', model = 3104 }, -- Mumor II
	{ name = 'Ovjang', job = 'RDM', subJob = 'WHM' },
	{ name = 'Robel-Akbel', job = 'BLM' },
	{ name = 'Rosulatia', job = 'BLM' },
	{ name = 'Shantotto', job = 'BLM', model = 3000 },
	{ name = 'Shantotto', job = 'BLM', model = 3110 }, -- Shantotto II
	{ name = 'Ullegore', job = 'BLM' },
	-- healer
	{ name = 'Cherukiki', job = 'WHM' },
	{ name = 'FerreousCoffin', job = 'WHM', subJob = 'WAR' },
	{ name = 'Karaha-Baruha', job = 'WHM', subJob = 'SMN' },
	{ name = 'Kupipi', job = 'WHM' },
	{ name = 'MihliAliapoh', job = 'WHM' },
	{ name = 'Monberaux', job = 'SPC' }, -- special / chemist
	{ name = 'Nashmeira', job = 'WHM', model = 3083 }, -- Nashmeira II
	{ name = 'Ygnas', job = 'WHM' },
	-- support
	{ name = 'Arciela', job = 'RDM', model = 3074 },
	{ name = 'Arciela', job = 'RDM', model = 3085 }, -- Arciela II
	{ name = 'Joachim', job = 'BRD', subJob = 'WHM' },
	{ name = 'KingOfHearts', job = 'RDM', subJob = 'WHM' },
	{ name = 'Koru-Moru', job = 'RDM' },
	{ name = 'Qultada', job = 'COR' },
	{ name = 'Ulmia', job = 'BRD' },
	-- special
	{ name = 'Brygid', job = 'GEO' },
	{ name = 'Cornelia', job = 'GEO' },
	{ name = 'Kupofried', job = 'GEO' },
	{ name = 'KuyinHathdenna', job = 'GEO' },
	{ name = 'Moogle', job = 'GEO' },
	{ name = 'Sakura', job = 'GEO' },
	{ name = 'StarSibyl', job = 'GEO' },
	-- unity
	{ name = 'Aldo', job = 'THF' },
	{ name = 'Apururu', job = 'WHM', subJob = 'RDM', model = 3061 },
	{ name = 'Ayame', job = 'SAM', },
	{ name = 'Flaviria', job = 'DRG', subJob = 'WAR' },
	{ name = 'InvincibleShield', job = 'WAR', subJob = 'MNK' }, 
	{ name = 'JakohWahcondalo', job = 'THF', subJob = 'WAR' },
	{ name = 'Maat', job = 'MNK', subJob = 'WAR' },
	{ name = 'NajaSalaheem', job = 'THF', subJob = 'WAR' },
	{ name = 'Pieuje', job = 'WHM' },
	{ name = 'Sylvie', job = 'GEO', subJob = 'WHM' },
	{ name = 'Yoran-Oran', job = 'WHM' },
}

function jobs:getRoleColor(job, jobIconColors)
	local hexColor = '#FFFFFFFF' -- default when nothing found

	local jobRole = jobs.roles[string.upper(job)]
	if jobRole then
		local roleColor = jobIconColors[jobRole]
		if roleColor then
			hexColor = roleColor
		end
	end
	
	return utils:colorFromHex(hexColor)
end

function jobs:getTrustInfo(trustName, trustModel)
	for t in jobs.trusts:it() do
		if t.name == trustName and (t.model == nil or t.model == trustModel) then
			return t
		end
	end
	
	return nil
end

return jobs