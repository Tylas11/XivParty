--[[
	Copyright © 2020, Tylas
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

-- the order of entires in this list defines the sort order of buffs for all party members
-- this file must be saved as UTF-8 without BOM (or ANSI if you don't care about the JP texts)
-- name strings are not used and are only here for readability and easier copying from windower/res/buffs.lua
local buffOrder = L{
	--------------------------------- debuffs / negative effects ----------------------------------

	-- common debuffs
    {id=0,en="KO",ja="戦闘不能",enl="KO'd",jal="戦闘不能"},
    {id=1,en="weakness",ja="衰弱",enl="weakened",jal="衰弱"},
	{id=15,en="doom",ja="死の宣告",enl="doomed",jal="死の宣告"},
	{id=14,en="charm",ja="魅了",enl="charmed",jal="魅了"},
	{id=17,en="charm",ja="魅了",enl="charmed",jal="魅了"},
    {id=2,en="sleep",ja="睡眠",enl="asleep",jal="睡眠"},
	{id=19,en="sleep",ja="睡眠",enl="asleep",jal="睡眠"},
	{id=10,en="stun",ja="スタン",enl="stunned",jal="スタン"},
	{id=28,en="terror",ja="テラー",enl="terrorized",jal="テラー"},
    {id=11,en="bind",ja="バインド",enl="bound",jal="バインド"},
	{id=12,en="weight",ja="ヘヴィ",enl="weighed down",jal="ヘヴィ"},
	{id=567,en="weight",ja="ヘヴィ",enl="weighed down",jal="ヘヴィ"},
	{id=177,en="encumbrance",ja="装備変更不可",enl="encumbered",jal="装備変更不可"},
	{id=13,en="slow",ja="スロウ",enl="slowed",jal="スロウ"},
	{id=565,en="slow",ja="スロウ",enl="slowed",jal="スロウ"},
    {id=3,en="poison",ja="毒",enl="poisoned",jal="毒"},
	{id=540,en="poison",ja="ポイズン",enl="poisoned",jal="ポイズン"},
    {id=4,en="paralysis",ja="麻痺",enl="paralyzed",jal="麻痺"},
	{id=566,en="paralysis",ja="麻痺",enl="paralyzed",jal="麻痺"},
    {id=5,en="blindness",ja="暗闇",enl="blinded",jal="暗闇"},
	{id=156,en="Flash",ja="フラッシュ",enl="afflicted with Flash",jal="フラッシュ"},
    {id=6,en="silence",ja="静寂",enl="silenced",jal="静寂"},
	{id=29,en="mute",ja="沈黙",enl="muted",jal="沈黙"},
    {id=7,en="petrification",ja="石化",enl="petrified",jal="石化"},
	{id=18,en="gradual petrification",ja="徐々に石化",enl="gradually petrifying",jal="徐々に石化"},
    {id=8,en="disease",ja="病気",enl="diseased",jal="病気"},
	{id=31,en="plague",ja="悪疫",enl="plagued",jal="悪疫"},
    {id=9,en="curse",ja="呪い",enl="cursed",jal="呪い"},
	{id=20,en="curse",ja="呪い",enl="cursed",jal="呪い"},
    {id=16,en="amnesia",ja="アムネジア",enl="amnesic",jal="アムネジア"},
    {id=21,en="addle",ja="アドル",enl="addled",jal="アドル"},
    {id=22,en="intimidate",ja="ひるみ",enl="intimidated",jal="ひるみ"},
    {id=30,en="bane",ja="呪詛",enl="baned",jal="呪詛"},
    
	-- misc debuffs
	{id=299,en="Overload",ja="オーバーロード",enl="overloaded",jal="オーバーロード"},
	{id=473,en="muddle",ja="アイテム使用不可",enl="muddled",jal="アイテム使用不可"},
	{id=575,en="gestation",ja="出現準備期間",enl="gestating",jal="出現準備期間"},
    {id=576,en="Doubt",ja="減退中",enl="afflicted with Doubt",jal="減退中"},
	
	-- dots
	{id=128,en="Burn",ja="バーン",enl="afflicted with Burn",jal="バーン"},
    {id=129,en="Frost",ja="フロスト",enl="afflicted with Frost",jal="フロスト"},
    {id=130,en="Choke",ja="チョーク",enl="afflicted with Choke",jal="チョーク"},
    {id=131,en="Rasp",ja="ラスプ",enl="afflicted with Rasp",jal="ラスプ"},
    {id=132,en="Shock",ja="ショック",enl="afflicted with Shock",jal="ショック"},
    {id=133,en="Drown",ja="ドラウン",enl="afflicted with Drown",jal="ドラウン"},
    {id=134,en="Dia",ja="ディア",enl="afflicted with Dia",jal="ディア"},
    {id=135,en="Bio",ja="バイオ",enl="afflicted with Bio",jal="バイオ"},
    {id=186,en="Helix",ja="計略",enl="Helix",jal="計略"},
	{id=23,en="Kaustra",ja="メルトン",enl="afflicted with Kaustra",jal="メルトン"},
	
	-- song debuffs
	{id=192,en="Requiem",ja="レクイエム",enl="Requiem",jal="レクイエム"},
    {id=193,en="Lullaby",ja="ララバイ",enl="Lullaby",jal="ララバイ"},
    {id=194,en="Elegy",ja="エレジー",enl="Elegy",jal="エレジー"},
	{id=217,en="Threnody",ja="スレノディ",enl="Threnody",jal="スレノディ"},
	
	-- downs
	{id=146,en="Accuracy Down",ja="命中率ダウン",enl="afflicted with Accuracy Down",jal="命中率ダウン"},
	{id=561,en="Accuracy Down",ja="命中率ダウン",enl="afflicted with Accuracy Down",jal="命中率ダウン"},
    {id=147,en="Attack Down",ja="攻撃力ダウン",enl="afflicted with Attack Down",jal="攻撃力ダウン"},
	{id=557,en="Attack Down",ja="攻撃力ダウン",enl="afflicted with Attack Down",jal="攻撃力ダウン"},
    {id=148,en="Evasion Down",ja="回避率ダウン",enl="afflicted with Evasion Down",jal="回避率ダウン"},
	{id=562,en="Evasion Down",ja="回避率ダウン",enl="afflicted with Evasion Down",jal="回避率ダウン"},
    {id=149,en="Defense Down",ja="防御力ダウン",enl="afflicted with Defense Down",jal="防御力ダウン"},
    {id=558,en="Defense Down",ja="防御力ダウン",enl="afflicted with Defense Down",jal="防御力ダウン"},
	
    {id=174,en="Magic Acc. Down",ja="魔法命中率ダウン",enl="Magic Acc. Down",jal="魔法命中率ダウン"},
	{id=563,en="Magic Acc. Down",ja="魔法命中率ダウン",enl="afflicted with Magic Acc. Down",jal="魔法命中率ダウン"},
	{id=175,en="Magic Atk. Down",ja="魔法攻撃力ダウン",enl="Magic Atk. Down",jal="魔法攻撃力ダウン"},
	{id=559,en="Magic Atk. Down",ja="魔法攻撃力ダウン",enl="afflicted with Magic Atk. Down",jal="魔法攻撃力ダウン"},
	{id=404,en="Magic Evasion Down",ja="魔法回避率ダウン",enl="Magic Evasion Down",jal="魔法回避率ダウン"},
	{id=564,en="Magic Evasion Down",ja="魔法回避率ダウン",enl="afflicted with Magic Evasion Down",jal="魔法回避率ダウン"},
    {id=167,en="Magic Def. Down",ja="魔法防御力ダウン",enl="Magic Def. Down",jal="魔法防御力ダウン"},
	{id=560,en="Magic Def. Down",ja="魔法防御力ダウン",enl="afflicted with Magic Adef. Down",jal="魔法防御力ダウン"},
    
	{id=298,en="critical hit evasion down",ja="被クリティカルヒット率アップ",enl="critical hit evasion down",jal="被クリティカルヒット率アップ"},
	{id=572,en="Avoidance Down",ja="回避能力ダウン",enl="afflicted with Avoidance Down",jal="回避能力ダウン"},
	{id=144,en="Max HP Down",ja="HPmaxダウン",enl="afflicted with Max HP Down",jal="HPmaxダウン"},
    {id=145,en="Max MP Down",ja="MPmaxダウン",enl="afflicted with Max MP Down",jal="MPmaxダウン"},
	{id=189,en="Max TP Down",ja="TPmaxダウン",enl="Max TP Down",jal="TPmaxダウン"},
	{id=168,en="Inhibit TP",ja="インヒビットTP",enl="TP-inhibited",jal="インヒビットTP"},
	
	-- attribute downs
	{id=136,en="STR Down",ja="STRダウン",enl="afflicted with STR Down",jal="STRダウン"},
    {id=137,en="DEX Down",ja="DEXダウン",enl="afflicted with DEX Down",jal="DEXダウン"},
    {id=138,en="VIT Down",ja="VITダウン",enl="afflicted with VIT Down",jal="VITダウン"},
    {id=139,en="AGI Down",ja="AGIダウン",enl="afflicted with AGI Down",jal="AGIダウン"},
    {id=140,en="INT Down",ja="INTダウン",enl="afflicted with INT Down",jal="INTダウン"},
    {id=141,en="MND Down",ja="MNDダウン",enl="afflicted with MND Down",jal="MNDダウン"},
    {id=142,en="CHR Down",ja="CHRダウン",enl="afflicted with CHR Down",jal="CHRダウン"},
	
	-- pathos?
    {id=258,en="Illusion",ja="イリュージョン",enl="Illusion",jal="イリュージョン"},
    {id=259,en="encumbrance",ja="エンカンバー",enl="encumbered",jal="エンカンバー"},
    {id=260,en="Obliviscence",ja="オブリビセンス",enl="Obliviscence",jal="オブリビセンス"},
    {id=261,en="impairment",ja="インペア",enl="impaired",jal="インペア"},
    {id=262,en="Omerta",ja="オメルタ",enl="Omerta",jal="オメルタ"},
    {id=263,en="debilitation",ja="デビリテート",enl="debilitated",jal="デビリテート"},
    {id=264,en="Pathos",ja="パトス",enl="Pathos",jal="パトス"},
	
	--------------------------------- buffs / positive effects ----------------------------------
	
	-- 2hrs / 1hrs / SPs
	{id=44,en="Mighty Strikes",ja="マイティストライク",enl="Mighty Strikes",jal="マイティストライク"},
    {id=46,en="Hundred Fists",ja="百烈拳",enl="Hundred Fists",jal="百烈拳"},
    {id=47,en="Manafont",ja="魔力の泉",enl="Manafont",jal="魔力の泉"},
    {id=48,en="Chainspell",ja="連続魔",enl="Chainspell",jal="連続魔"},
    {id=49,en="Perfect Dodge",ja="絶対回避",enl="Perfect Dodge",jal="絶対回避"},
    {id=50,en="Invincible",ja="インビンシブル",enl="Invincible",jal="インビンシブル"},
    {id=51,en="Blood Weapon",ja="ブラッドウェポン",enl="Blood Weapon",jal="ブラッドウェポン"},
    {id=52,en="Soul Voice",ja="ソウルボイス",enl="Soul Voice",jal="ソウルボイス"},
    {id=53,en="Eagle Eye Shot",ja="イーグルアイ",enl="Eagle Eye Shot",jal="イーグルアイ"},
    {id=54,en="Meikyo Shisui",ja="明鏡止水",enl="Meikyo Shisui",jal="明鏡止水"},
    {id=55,en="Astral Flow",ja="アストラルフロウ",enl="Astral Flow",jal="アストラルフロウ"},
	{id=126,en="Spirit Surge",ja="竜剣",enl="Spirit Surge",jal="竜剣"},
	{id=163,en="Azure Lore",ja="アジュールロー",enl="Azure Lore",jal="アジュールロー"},
    {id=166,en="Overdrive",ja="オーバードライヴ",enl="Overdrive",jal="オーバードライヴ"},
	{id=376,en="Trance",ja="トランス",enl="Trance",jal="トランス"},
	{id=377,en="Tabula Rasa",ja="連環計",enl="Tabula Rasa",jal="連環計"},
	{id=490,en="Brazen Rush",ja="ブラーゼンラッシュ",enl="Brazen Rush",jal="ブラーゼンラッシュ"},
    {id=491,en="Inner Strength",ja="インナーストレングス",enl="Inner Strength",jal="インナーストレングス"},
    {id=492,en="Asylum",ja="女神の羽衣",enl="Asylum",jal="女神の羽衣"},
    {id=493,en="Subtle Sorcery",ja="サテルソーサリー",enl="Subtle Sorcery",jal="サテルソーサリー"},
    {id=494,en="Stymie",ja="スタイミー",enl="Stymie",jal="スタイミー"},
    {id=496,en="Intervene",ja="インターヴィーン",enl="Intervene",jal="インターヴィーン"},
    {id=497,en="Soul Enslavement",ja="ソールエンスレーヴ",enl="Soul Enslavement",jal="ソールエンスレーヴ"},
    {id=498,en="Unleash",ja="アンリーシュ",enl="Unleash",jal="アンリーシュ"},
    {id=499,en="Clarion Call",ja="クラリオンコール",enl="Clarion Call",jal="クラリオンコール"},
    {id=500,en="Overkill",ja="オーバーキル",enl="Overkill",jal="オーバーキル"},
    {id=501,en="Yaegasumi",ja="八重霞",enl="Yaegasumi",jal="八重霞"},
    {id=502,en="Mikage",ja="身影",enl="Mikage",jal="身影"},
    {id=503,en="Fly High",ja="フライハイ",enl="Fly High",jal="フライハイ"},
    {id=504,en="Astral Conduit",ja="アストラルパッセージ",enl="Astral Conduit",jal="アストラルパッセージ"},
    {id=505,en="Unbridled Wisdom",ja="N.ウィズドム",enl="Unbridled Wisdom",jal="N.ウィズドム"},
    {id=507,en="Grand Pas",ja="グランドパー",enl="Grand Pas",jal="グランドパー"},
	{id=513,en="Bolster",ja="ボルスター",enl="bolstered",jal="ボルスター"},
    {id=508,en="Widened Compass",ja="ワイデンコンパス",enl="Widened Compass",jal="ワイデンコンパス"},
    {id=509,en="Odyllic Subterfuge",ja="オディリックサブタ",enl="Odyllic Subterfuge",jal="オディリックサブタ"},
	{id=522,en="Elemental Sforzo",ja="E.スフォルツォ",enl="Elemental Sforzo",jal="E.スフォルツォ"},
	
	-- copy image
	{id=66,en="Copy Image",ja="分身",enl="Copy Image",jal="分身"},
	{id=444,en="Copy Image (2)",ja="分身(2)",enl="Copy Image (2)",jal="分身(2)"},
    {id=445,en="Copy Image (3)",ja="分身(3)",enl="Copy Image (3)",jal="分身(3)"},
    {id=446,en="Copy Image (4+)",ja="分身(4+)",enl="Copy Image (4+)",jal="分身(4+)"},
	
	-- common buffs
	{id=33,en="Haste",ja="ヘイスト",enl="hastened",jal="ヘイスト"},
	{id=580,en="Haste",ja="ヘイスト",enl="hastened",jal="ヘイスト"}, -- geo haste
	{id=265,en="Flurry",ja="フラーリー",enl="Flurry",jal="フラーリー"},
    {id=581,en="Flurry",ja="スナップ",enl="Flurry",jal="スナップ"},
	{id=36,en="Blink",ja="ブリンク",enl="Blink",jal="ブリンク"},
    {id=37,en="Stoneskin",ja="ストンスキン",enl="Stoneskin",jal="ストンスキン"},
    {id=40,en="Protect",ja="プロテス",enl="Protect",jal="プロテス"},
    {id=41,en="Shell",ja="シェル",enl="Shell",jal="シェル"},
	{id=39,en="Aquaveil",ja="アクアベール",enl="Aquaveil",jal="アクアベール"},
    {id=42,en="Regen",ja="リジェネ",enl="regenerating",jal="リジェネ"},
	{id=539,en="Regen",ja="リジェネ",enl="regenerating",jal="リジェネ"}, -- geo regen
    {id=43,en="Refresh",ja="リフレシュ",enl="refreshing",jal="リフレシュ"},
	{id=541,en="Refresh",ja="リフレシュ",enl="refreshing",jal="リフレシュ"}, -- geo refresh
	{id=116,en="Phalanx",ja="ファランクス",enl="Phalanx",jal="ファランクス"},
	{id=113,en="Reraise",ja="リレイズ",enl="Reraise",jal="リレイズ"},
	{id=69,en="Invisible",ja="インビジ",enl="Invisible",jal="インビジ"},
    {id=70,en="Deodorize",ja="デオード",enl="Deodorize",jal="デオード"},
    {id=71,en="Sneak",ja="スニーク",enl="Sneak",jal="スニーク"},
	
	-- barspells
    {id=100,en="Barfire",ja="バファイ",enl="Barfire",jal="バファイ"},
    {id=101,en="Barblizzard",ja="バブリザ",enl="Barblizzard",jal="バブリザ"},
    {id=102,en="Baraero",ja="バエアロ",enl="Baraero",jal="バエアロ"},
    {id=103,en="Barstone",ja="バストン",enl="Barstone",jal="バストン"},
    {id=104,en="Barthunder",ja="バサンダ",enl="Barthunder",jal="バサンダ"},
    {id=105,en="Barwater",ja="バウォタ",enl="Barwater",jal="バウォタ"},
    {id=106,en="Barsleep",ja="バスリプル",enl="Barsleep",jal="バスリプル"},
    {id=107,en="Barpoison",ja="バポイズン",enl="Barpoison",jal="バポイズン"},
    {id=108,en="Barparalyze",ja="バパライズ",enl="Barparalyze",jal="バパライズ"},
    {id=109,en="Barblind",ja="バブライン",enl="Barblind",jal="バブライン"},
    {id=110,en="Barsilence",ja="バサイレス",enl="Barsilence",jal="バサイレス"},
    {id=111,en="Barpetrify",ja="バブレイク",enl="Barpetrify",jal="バブレイク"},
    {id=112,en="Barvirus",ja="バウィルス",enl="Barvirus",jal="バウィルス"},
	{id=286,en="Baramnesia",ja="バアムネジア",enl="Baramnesia",jal="バアムネジア"},
	
	-- spikes
    {id=34,en="Blaze Spikes",ja="ブレイズスパイク",enl="Blaze Spikes",jal="ブレイズスパイク"},
    {id=35,en="Ice Spikes",ja="アイススパイク",enl="Ice Spikes",jal="アイススパイク"},
    {id=38,en="Shock Spikes",ja="ショックスパイク",enl="Shock Spikes",jal="ショックスパイク"},
	{id=173,en="Dread Spikes",ja="ドレッドスパイク",enl="Dread Spikes",jal="ドレッドスパイク"},
	{id=153,en="Damage Spikes",ja="ダメージスパイク",enl="Damage Spikes",jal="ダメージスパイク"},
	{id=573,en="Deluge Spikes",ja="アクアスパイク",enl="Deluge Spikes",jal="アクアスパイク"},
	{id=605,en="Gale Spikes",ja="ゲイルスパイク",enl="Gale Spikes",jal="ゲイルスパイク"},
    {id=606,en="Clod Spikes",ja="クロッドスパイク",enl="Clod Spikes",jal="クロッドスパイク"},
    {id=607,en="Glint Spikes",ja="グリントスパイク",enl="Glint Spikes",jal="グリントスパイク"},
	
	-- enspells
    {id=94,en="Enfire",ja="エンファイア",enl="Enfire",jal="エンファイア"},
    {id=95,en="Enblizzard",ja="エンブリザド",enl="Enblizzard",jal="エンブリザド"},
    {id=96,en="Enaero",ja="エンエアロ",enl="Enaero",jal="エンエアロ"},
    {id=97,en="Enstone",ja="エンストーン",enl="Enstone",jal="エンストーン"},
    {id=98,en="Enthunder",ja="エンサンダー",enl="Enthunder",jal="エンサンダー"},
    {id=99,en="Enwater",ja="エンウォータ",enl="Enwater",jal="エンウォータ"},
	{id=274,en="Enlight",ja="エンライト",enl="Enlight",jal="エンライト"},
	{id=288,en="Endark",ja="エンダーク",enl="Endark",jal="エンダーク"},
	{id=277,en="Enfire II",ja="エンファイアII",enl="Enfire II",jal="エンファイアII"},
    {id=278,en="Enblizzard II",ja="エンブリザドII",enl="Enblizzard II",jal="エンブリザドII"},
    {id=279,en="Enaero II",ja="エンエアロII",enl="Enaero II",jal="エンエアロII"},
    {id=280,en="Enstone II",ja="エンストーンII",enl="Enstone II",jal="エンストーンII"},
    {id=281,en="Enthunder II",ja="エンサンダーII",enl="Enthunder II",jal="エンサンダーII"},
    {id=282,en="Enwater II",ja="エンウォータII",enl="Enwater II",jal="エンウォータII"},
	{id=487,en="Endrain",ja="エンドレイン",enl="Endrain",jal="エンドレイン"},
    {id=488,en="Enaspir",ja="エンアスピル",enl="Enaspir",jal="エンアスピル"},
	{id=275,en="Auspice",ja="オースピス",enl="Auspice",jal="オースピス"},
	
	-- scholar spells
	{id=228,en="Embrava",ja="オーラ",enl="Embrava",jal="オーラ"},
	{id=407,en="Klimaform",ja="虚誘掩殺の策",enl="Klimaform",jal="虚誘掩殺の策"},
    {id=178,en="Firestorm",ja="熱波の陣",enl="Firestorm",jal="熱波の陣"},
    {id=179,en="Hailstorm",ja="吹雪の陣",enl="Hailstorm",jal="吹雪の陣"},
    {id=180,en="Windstorm",ja="烈風の陣",enl="Windstorm",jal="烈風の陣"},
    {id=181,en="Sandstorm",ja="砂塵の陣",enl="Sandstorm",jal="砂塵の陣"},
    {id=182,en="Thunderstorm",ja="疾雷の陣",enl="Thunderstorm",jal="疾雷の陣"},
    {id=183,en="Rainstorm",ja="豪雨の陣",enl="Rainstorm",jal="豪雨の陣"},
    {id=184,en="Aurorastorm",ja="極光の陣",enl="Aurorastorm",jal="極光の陣"},
    {id=185,en="Voidstorm",ja="妖霧の陣",enl="Voidstorm",jal="妖霧の陣"},
	{id=589,en="Firestorm",ja="熱波の陣II",enl="Firestorm",jal="熱波の陣II"},
    {id=590,en="Hailstorm",ja="吹雪の陣II",enl="Hailstorm",jal="吹雪の陣II"},
    {id=591,en="Windstorm",ja="烈風の陣II",enl="Windstorm",jal="烈風の陣II"},
    {id=592,en="Sandstorm",ja="砂塵の陣II",enl="Sandstorm",jal="砂塵の陣II"},
    {id=593,en="Thunderstorm",ja="疾雷の陣II",enl="Thunderstorm",jal="疾雷の陣II"},
    {id=594,en="Rainstorm",ja="豪雨の陣II",enl="Rainstorm",jal="豪雨の陣II"},
    {id=595,en="Aurorastorm",ja="極光の陣II",enl="Aurorastorm",jal="極光の陣II"},
    {id=596,en="Voidstorm",ja="妖霧の陣II",enl="Voidstorm",jal="妖霧の陣II"},
	
	-- avatar buffs
	{id=154,en="Shining Ruby",ja="ルビーの輝き",enl="Shining Ruby",jal="ルビーの輝き"},
	{id=458,en="Earthen Armor",ja="大地の鎧",enl="Earthen Armor",jal="大地の鎧"},
	{id=624,en="Wind's Blessing",ja="風の守り",enl="Wind's Blessing",jal="風の守り"},
	{id=283,en="Perfect Defense",ja="絶対防御",enl="Perfect Defense",jal="絶対防御"},
	
	-- other spell buffs
	{id=169,en="Potency",ja="ポテンシー",enl="Potency",jal="ポテンシー"},
    {id=170,en="Regain",ja="リゲイン",enl="Regain",jal="リゲイン"},
    {id=171,en="Pax",ja="パクス",enl="Pax",jal="パクス"},
    {id=172,en="Intension",ja="インテンション",enl="Intension",jal="インテンション"},
	{id=150,en="Physical Shield",ja="物理バリア",enl="Physical Shield",jal="物理バリア"},
    {id=151,en="Arrow Shield",ja="遠隔物理バリア",enl="Arrow Shield",jal="遠隔物理バリア"},
    {id=152,en="Magic Shield",ja="魔法バリア",enl="Magic Shield",jal="魔法バリア"},
	{id=289,en="Enmity Boost",ja="敵対心アップ",enl="Enmity Boost",jal="敵対心アップ"},
    {id=290,en="Subtle Blow Plus",ja="モクシャアップ",enl="Subtle Blow Plus",jal="モクシャアップ"},
    {id=291,en="Enmity Down",ja="敵対心ダウン",enl="Enmity Down",jal="敵対心ダウン"},
	
	-- songs
    {id=195,en="Paeon",ja="ピーアン",enl="Paeon",jal="ピーアン"},
    {id=196,en="Ballad",ja="バラード",enl="Ballad",jal="バラード"},
    {id=197,en="Minne",ja="ミンネ",enl="Minne",jal="ミンネ"},
    {id=198,en="Minuet",ja="メヌエット",enl="Minuet",jal="メヌエット"},
    {id=199,en="Madrigal",ja="マドリガル",enl="Madrigal",jal="マドリガル"},
    {id=200,en="Prelude",ja="プレリュード",enl="Prelude",jal="プレリュード"},
    {id=201,en="Mambo",ja="マンボ",enl="Mambo",jal="マンボ"},
    {id=202,en="Aubade",ja="オーバード",enl="Aubade",jal="オーバード"},
    {id=203,en="Pastoral",ja="パストラル",enl="Pastoral",jal="パストラル"},
    {id=204,en="Hum",ja="ハミング",enl="Hum",jal="ハミング"},
    {id=205,en="Fantasia",ja="ファンタジア",enl="Fantasia",jal="ファンタジア"},
    {id=206,en="Operetta",ja="オペレッタ",enl="Operetta",jal="オペレッタ"},
    {id=207,en="Capriccio",ja="カプリチオ",enl="Capriccio",jal="カプリチオ"},
    {id=208,en="Serenade",ja="セレナーデ",enl="Serenade",jal="セレナーデ"},
    {id=209,en="Round",ja="ロンド",enl="Round",jal="ロンド"},
    {id=210,en="Gavotte",ja="ガボット",enl="Gavotte",jal="ガボット"},
    {id=211,en="Fugue",ja="フーガ",enl="Fugue",jal="フーガ"},
    {id=212,en="Rhapsody",ja="ラプソディ",enl="Rhapsody",jal="ラプソディ"},
    {id=213,en="Aria",ja="アリア",enl="Aria",jal="アリア"},
    {id=214,en="March",ja="マーチ",enl="March",jal="マーチ"},
    {id=215,en="Etude",ja="エチュード",enl="Etude",jal="エチュード"},
    {id=216,en="Carol",ja="カロル",enl="Carol",jal="カロル"},
    {id=218,en="Hymnus",ja="ヒムヌス",enl="Hymnus",jal="ヒムヌス"},
    {id=219,en="Mazurka",ja="マズルカ",enl="Mazurka",jal="マズルカ"},
    {id=220,en="Sirvente",ja="シルベント",enl="Sirvente",jal="シルベント"},
    {id=221,en="Dirge",ja="ダージュ",enl="Dirge",jal="ダージュ"},
    {id=222,en="Scherzo",ja="スケルツォ",enl="Scherzo",jal="スケルツォ"},
    {id=223,en="Nocturne",ja="ノクターン",enl="Nocturne",jal="ノクターン"},
	{id=231,en="Marcato",ja="マルカート",enl="Marcato",jal="マルカート"},
	
	-- corsair / rolls
	{id=601,en="Crooked Cards",ja="クルケッドカード",enl="Crooked Cards",jal="クルケッドカード"},
    {id=308,en="Double-Up Chance",ja="ダブルアップチャンス",enl="Double-Up Chance",jal="ダブルアップチャンス"},
    {id=310,en="Fighter's Roll",ja="ファイターズロール",enl="Fighter's Roll",jal="ファイターズロール"},
    {id=311,en="Monk's Roll",ja="モンクスロール",enl="Monk's Roll",jal="モンクスロール"},
    {id=312,en="Healer's Roll",ja="ヒーラーズロール",enl="Healer's Roll",jal="ヒーラーズロール"},
    {id=313,en="Wizard's Roll",ja="ウィザーズロール",enl="Wizard's Roll",jal="ウィザーズロール"},
    {id=314,en="Warlock's Roll",ja="ワーロックスロール",enl="Warlock's Roll",jal="ワーロックスロール"},
    {id=315,en="Rogue's Roll",ja="ローグズロール",enl="Rogue's Roll",jal="ローグズロール"},
    {id=316,en="Gallant's Roll",ja="ガランツロール",enl="Gallant's Roll",jal="ガランツロール"},
    {id=317,en="Chaos Roll",ja="カオスロール",enl="Chaos Roll",jal="カオスロール"},
    {id=318,en="Beast Roll",ja="ビーストロール",enl="Beast Roll",jal="ビーストロール"},
    {id=319,en="Choral Roll",ja="コーラルロール",enl="Choral Roll",jal="コーラルロール"},
    {id=320,en="Hunter's Roll",ja="ハンターズロール",enl="Hunter's Roll",jal="ハンターズロール"},
    {id=321,en="Samurai Roll",ja="サムライロール",enl="Samurai Roll",jal="サムライロール"},
    {id=322,en="Ninja Roll",ja="ニンジャロール",enl="Ninja Roll",jal="ニンジャロール"},
    {id=323,en="Drachen Roll",ja="ドラケンロール",enl="Drachen Roll",jal="ドラケンロール"},
    {id=324,en="Evoker's Roll",ja="エボカーズロール",enl="Evoker's Roll",jal="エボカーズロール"},
    {id=325,en="Magus's Roll",ja="メガスズロール",enl="Magus's Roll",jal="メガスズロール"},
    {id=326,en="Corsair's Roll",ja="コルセアズロール",enl="Corsair's Roll",jal="コルセアズロール"},
    {id=327,en="Puppet Roll",ja="パペットロール",enl="Puppet Roll",jal="パペットロール"},
    {id=328,en="Dancer's Roll",ja="ダンサーロール",enl="Dancer's Roll",jal="ダンサーロール"},
    {id=329,en="Scholar's Roll",ja="スカラーロール",enl="Scholar's Roll",jal="スカラーロール"},
    {id=330,en="Bolter's Roll",ja="ボルターズロール",enl="Bolter's Roll",jal="ボルターズロール"},
    {id=331,en="Caster's Roll",ja="キャスターズロール",enl="Caster's Roll",jal="キャスターズロール"},
    {id=332,en="Courser's Roll",ja="コアサーズロール",enl="Courser's Roll",jal="コアサーズロール"},
    {id=333,en="Blitzer's Roll",ja="ブリッツァロール",enl="Blitzer's Roll",jal="ブリッツァロール"},
    {id=334,en="Tactician's Roll",ja="タクティックロール",enl="Tactician's Roll",jal="タクティックロール"},
    {id=335,en="Allies' Roll",ja="アライズロール",enl="Allies' Roll",jal="アライズロール"},
    {id=336,en="Miser's Roll",ja="マイザーロール",enl="Miser's Roll",jal="マイザーロール"},
    {id=337,en="Companion's Roll",ja="コンパニオンロール",enl="Companion's Roll",jal="コンパニオンロール"},
    {id=338,en="Avenger's Roll",ja="カウンターロール",enl="Avenger's Roll",jal="カウンターロール"},
    {id=339,en="Naturalist's Roll",ja="ナチュラリストロール",enl="Naturalist's Roll",jal="ナチュラリストロール"},
	{id=600,en="Runeist's Roll",ja="ルーニストロール",enl="Runeist's Roll",jal="ルーニストロール"},
	{id=309,en="Bust",ja="バスト",enl="Bust",jal="バスト"},
	
	-- boosts
    {id=90,en="Accuracy Boost",ja="命中率アップ",enl="accuracy-boosted",jal="命中率アップ"},
	{id=553,en="Accuracy Boost",ja="命中率アップ",enl="accuracy-boosted",jal="命中率アップ"},
    {id=91,en="Attack Boost",ja="攻撃力アップ",enl="attack-boosted",jal="攻撃力アップ"},
    {id=549,en="Attack Boost",ja="攻撃力アップ",enl="attack-boosted",jal="攻撃力アップ"},
	{id=92,en="Evasion Boost",ja="回避率アップ",enl="evasion-boosted",jal="回避率アップ"},
	{id=554,en="Evasion Boost",ja="回避率アップ",enl="evasion-boosted",jal="回避率アップ"},
    {id=93,en="Defense Boost",ja="防御力アップ",enl="defense-boosted",jal="防御力アップ"},
	{id=550,en="Defense Boost",ja="防御力アップ",enl="defense-boosted",jal="防御力アップ"},
	{id=555,en="Magic Acc. Boost",ja="魔法命中率アップ",enl="Magic Acc. Boost",jal="魔法命中率アップ"},
	{id=190,en="Magic Atk. Boost",ja="魔法攻撃力アップ",enl="Magic Atk. Boost",jal="魔法攻撃力アップ"},
	{id=551,en="Magic Atk. Boost",ja="魔法攻撃力アップ",enl="Magic Atk. Boost",jal="魔法攻撃力アップ"},
	{id=556,en="Magic Evasion Boost",ja="魔法回避率アップ",enl="Magic Evasion Boost",jal="魔法回避率アップ"},
	{id=611,en="Magic Evasion Boost",ja="魔法回避率アップ",enl="Magic Evasion Boost",jal="魔法回避率アップ"},
    {id=191,en="Magic Def. Boost",ja="魔法防御力アップ",enl="Magic Def. Boost",jal="魔法防御力アップ"},
	{id=552,en="Magic Def. Boost",ja="魔法防御力アップ",enl="Magic Def. Boost",jal="魔法防御力アップ"},
	{id=88,en="Max HP Boost",ja="HPmaxアップ",enl="Max HP-boosted",jal="HPmaxアップ"},
    {id=89,en="Max MP Boost",ja="MPmaxアップ",enl="Max MP-boosted",jal="MPmaxアップ"},
	
	-- attribute boosts
    {id=80,en="STR Boost",ja="STRアップ",enl="STR-boosted",jal="STRアップ"},
    {id=81,en="DEX Boost",ja="DEXアップ",enl="DEX-boosted",jal="DEXアップ"},
    {id=82,en="VIT Boost",ja="VITアップ",enl="VIT-boosted",jal="VITアップ"},
    {id=83,en="AGI Boost",ja="AGIアップ",enl="AGI-boosted",jal="AGIアップ"},
    {id=84,en="INT Boost",ja="INTアップ",enl="INT-boosted",jal="INTアップ"},
    {id=85,en="MND Boost",ja="MNDアップ",enl="MND-boosted",jal="MNDアップ"},
    {id=86,en="CHR Boost",ja="CHRアップ",enl="CHR-boosted",jal="CHRアップ"},
    {id=119,en="STR Boost",ja="STRアップ",enl="STR-boosted",jal="STRアップ"},
    {id=120,en="DEX Boost",ja="DEXアップ",enl="DEX-boosted",jal="DEXアップ"},
    {id=121,en="VIT Boost",ja="VITアップ",enl="VIT-boosted",jal="VITアップ"},
    {id=122,en="AGI Boost",ja="AGIアップ",enl="AGI-boosted",jal="AGIアップ"},
    {id=123,en="INT Boost",ja="INTアップ",enl="INT-boosted",jal="INTアップ"},
    {id=124,en="MND Boost",ja="MNDアップ",enl="MND-boosted",jal="MNDアップ"},
    {id=125,en="CHR Boost",ja="CHRアップ",enl="CHR-boosted",jal="CHRアップ"},
	{id=542,en="STR Boost",ja="STRアップ",enl="STR-boosted",jal="STRアップ"}, -- these seem geo buffs
    {id=543,en="DEX Boost",ja="DEXアップ",enl="DEX-boosted",jal="DEXアップ"},
    {id=544,en="VIT Boost",ja="VITアップ",enl="VIT-boosted",jal="VITアップ"},
    {id=545,en="AGI Boost",ja="AGIアップ",enl="AGI-boosted",jal="AGIアップ"},
    {id=546,en="INT Boost",ja="INTアップ",enl="INT-boosted",jal="INTアップ"},
    {id=547,en="MND Boost",ja="MNDアップ",enl="MND-boosted",jal="MNDアップ"},
    {id=548,en="CHR Boost",ja="CHRアップ",enl="CHR-boosted",jal="CHRアップ"},
	
	-- abilities
	{id=45,en="Boost",ja="ためる",enl="Boost",jal="ためる"},
    {id=56,en="Berserk",ja="バーサク",enl="Berserk",jal="バーサク"},
    {id=57,en="Defender",ja="ディフェンダー",enl="Defender",jal="ディフェンダー"},
    {id=58,en="Aggressor",ja="アグレッサー",enl="Aggressor",jal="アグレッサー"},
    {id=59,en="Focus",ja="集中",enl="Focus",jal="集中"},
    {id=60,en="Dodge",ja="回避",enl="Dodge",jal="回避"},
    {id=61,en="Counterstance",ja="かまえる",enl="Counterstance",jal="かまえる"},
    {id=62,en="Sentinel",ja="センチネル",enl="Sentinel",jal="センチネル"},
    {id=63,en="Souleater",ja="暗黒",enl="Souleater",jal="暗黒"},
    {id=64,en="Last Resort",ja="ラストリゾート",enl="Last Resort",jal="ラストリゾート"},
    {id=65,en="Sneak Attack",ja="不意打ち",enl="Sneak Attack",jal="不意打ち"},
    {id=87,en="Trick Attack",ja="だまし討ち",enl="Trick Attack",jal="だまし討ち"},
    {id=67,en="Third Eye",ja="心眼",enl="Third Eye",jal="心眼"},
    {id=68,en="Warcry",ja="ウォークライ",enl="Warcry",jal="ウォークライ"},
    {id=72,en="Sharpshot",ja="狙い撃ち",enl="Sharpshot",jal="狙い撃ち"},
    {id=73,en="Barrage",ja="乱れ撃ち",enl="Barrage",jal="乱れ撃ち"},
    {id=76,en="Hide",ja="かくれる",enl="hiding",jal="かくれる"},
    {id=77,en="Camouflage",ja="カモフラージュ",enl="camouflaged",jal="カモフラージュ"},
    {id=78,en="Divine Seal",ja="女神の印",enl="Divine Seal",jal="女神の印"},
    {id=79,en="Elemental Seal",ja="精霊の印",enl="Elemental Seal",jal="精霊の印"},
	{id=114,en="Cover",ja="かばう",enl="Cover",jal="かばう"},
    {id=115,en="Unlimited Shot",ja="エンドレスショット",enl="Unlimited Shot",jal="エンドレスショット"},
	{id=164,en="Chain Affinity",ja="ブルーチェーン",enl="Chain Affinity",jal="ブルーチェーン"},
    {id=165,en="Burst Affinity",ja="ブルーバースト",enl="Burst Affinity",jal="ブルーバースト"},
	{id=227,en="Store TP",ja="ストアTP",enl="Store TP",jal="ストアTP"},
    {id=229,en="Manawell",ja="魔力の雫",enl="Manawell",jal="魔力の雫"},
    {id=230,en="Spontaneity",ja="クイックマジック",enl="Spontaneity",jal="クイックマジック"},
    {id=233,en="Auto-Regen",ja="オートリジェネ",enl="Auto-Regen",jal="オートリジェネ"},
    {id=234,en="Auto-Refresh",ja="オートリフレシュ",enl="Auto-Refresh",jal="オートリフレシュ"},
	{id=266,en="Concentration",ja="コンセントレーション",enl="Concentration",jal="コンセントレーション"},
    {id=340,en="Warrior's Charge",ja="ウォリアーチャージ",enl="Warrior's Charge",jal="ウォリアーチャージ"},
    {id=341,en="Formless Strikes",ja="無想無念",enl="Formless Strikes",jal="無想無念"},
    {id=342,en="Assassin's Charge",ja="アサシンチャージ",enl="Assassin's Charge",jal="アサシンチャージ"},
    {id=343,en="Feint",ja="フェイント",enl="Feint",jal="フェイント"},
    {id=344,en="Fealty",ja="フィールティ",enl="Fealty",jal="フィールティ"},
    {id=345,en="Dark Seal",ja="ダークシール",enl="Dark Seal",jal="ダークシール"},
    {id=346,en="Diabolic Eye",ja="ディアボリクアイ",enl="Diabolic Eye",jal="ディアボリクアイ"},
    {id=347,en="Nightingale",ja="ナイチンゲール",enl="Nightingale",jal="ナイチンゲール"},
    {id=348,en="Troubadour",ja="トルバドゥール",enl="Troubadour",jal="トルバドゥール"},
    {id=349,en="Killer Instinct",ja="K.インスティンクト",enl="Killer Instinct",jal="K.インスティンクト"},
    {id=350,en="Stealth Shot",ja="ステルスショット",enl="Stealth Shot",jal="ステルスショット"},
    {id=351,en="Flashy Shot",ja="フラッシーショット",enl="Flashy Shot",jal="フラッシーショット"},
    {id=352,en="Sange",ja="散華",enl="Sange",jal="散華"},
    {id=355,en="Convergence",ja="コンバージェンス",enl="Convergence",jal="コンバージェンス"},
    {id=356,en="Diffusion",ja="ディフュージョン",enl="Diffusion",jal="ディフュージョン"},
    {id=357,en="Snake Eye",ja="スネークアイ",enl="Snake Eye",jal="スネークアイ"},
    {id=371,en="Velocity Shot",ja="ベロシティショット",enl="Velocity Shot",jal="ベロシティショット"},
    {id=403,en="Reprisal",ja="リアクト",enl="Reprisal",jal="リアクト"},
    {id=405,en="Retaliation",ja="リタリエーション",enl="Retaliation",jal="リタリエーション"},
    {id=406,en="Footwork",ja="猫足立ち",enl="Footwork",jal="猫足立ち"},
    {id=408,en="Sekkanoki",ja="石火之機",enl="Sekkanoki",jal="石火之機"},
    {id=409,en="Pianissimo",ja="ピアニッシモ",enl="Pianissimo",jal="ピアニッシモ"},
    {id=419,en="Composure",ja="コンポージャー",enl="Composure",jal="コンポージャー"},
    {id=432,en="Multi Strikes",ja="マルチアタック",enl="Multi Strikes",jal="マルチアタック"},
    {id=433,en="Double Shot",ja="ダブルショット",enl="Double Shot",jal="ダブルショット"},
    {id=434,en="Transcendency",ja="天神地祇",enl="Transcendency",jal="天神地祇"},
    {id=435,en="Restraint",ja="リストレント",enl="Restraint",jal="リストレント"},
    {id=436,en="Perfect Counter",ja="絶対カウンター",enl="Perfect Counter",jal="絶対カウンター"},
    {id=437,en="Mana Wall",ja="マナウォール",enl="Mana Wall",jal="マナウォール"},
    {id=438,en="Divine Emblem",ja="神聖の印",enl="Divine Emblem",jal="神聖の印"},
    {id=439,en="Nether Void",ja="ネザーヴォイド",enl="Nether Void",jal="ネザーヴォイド"},
    {id=440,en="Sengikori",ja="先義後利",enl="Sengikori",jal="先義後利"},
	{id=455,en="Tenuto",ja="テヌート",enl="Tenuto",jal="テヌート"},
    {id=447,en="Multi Shots",ja="マルチショット",enl="Multi Shots",jal="マルチショット"},
    {id=453,en="Divine Caress",ja="女神の愛撫",enl="Divine Caress",jal="女神の愛撫"},
    {id=454,en="Saboteur",ja="サボトゥール",enl="Saboteur",jal="サボトゥール"},
    {id=456,en="Spur",ja="気張れ",enl="Spur",jal="気張れ"},
    {id=457,en="Efflux",ja="エフラックス",enl="Efflux",jal="エフラックス"},
    {id=459,en="Divine Caress",ja="女神の愛撫",enl="Divine Caress",jal="女神の愛撫"},
    {id=460,en="Blood Rage",ja="ブラッドレイジ",enl="Blood Rage",jal="ブラッドレイジ"},
    {id=461,en="Impetus",ja="インピタス",enl="Impetus",jal="インピタス"},
    {id=462,en="Conspirator",ja="コンスピレーター",enl="Conspirator",jal="コンスピレーター"},
    {id=463,en="Sepulcher",ja="セプルカー",enl="Sepulcher",jal="セプルカー"},
    {id=464,en="Arcane Crest",ja="アルケインクレスト",enl="Arcane Crest",jal="アルケインクレスト"},
    {id=465,en="Hamanoha",ja="破魔の刃",enl="Hamanoha",jal="破魔の刃"},
    {id=466,en="Dragon Breaker",ja="ドラゴンブレイカー",enl="Dragon Breaker",jal="ドラゴンブレイカー"},
    {id=467,en="Triple Shot",ja="トリプルショット",enl="Triple Shot",jal="トリプルショット"},
    {id=474,en="Prowess",ja="一時技能",enl="Prowess",jal="一時技能"},
    {id=476,en="Ensphere",ja="インスフィア",enl="Ensphere",jal="インスフィア"},
    {id=477,en="Sacrosanctity",ja="女神の聖域",enl="Sacrosanctity",jal="女神の聖域"},
    {id=478,en="Palisade",ja="パリセード",enl="Palisade",jal="パリセード"},
    {id=479,en="Scarlet Delirium",ja="レッドデリリアム",enl="Scarlet Delirium",jal="レッドデリリアム"},
    {id=480,en="Scarlet Delirium",ja="レッドデリリアム",enl="Scarlet Delirium",jal="レッドデリリアム"},
    {id=482,en="Decoy Shot",ja="デコイショット",enl="Decoy Shot",jal="デコイショット"},
    {id=483,en="Hagakure",ja="葉隠",enl="Hagakure",jal="葉隠"},
    {id=484,en="Issekigan",ja="一隻眼",enl="Issekigan",jal="一隻眼"},
    {id=485,en="Unbridled Learning",ja="ノートリアスナレッジ",enl="Unbridled Learning",jal="ノートリアスナレッジ"},
    {id=486,en="Counter Boost",ja="カウンターアップ",enl="Counter Boost",jal="カウンターアップ"},
	{id=582,en="Contradance",ja="コントラダンス",enl="Contradance",jal="コントラダンス"},
    {id=583,en="Apogee",ja="アポジー",enl="Apogee",jal="アポジー"},
    {id=584,en="Entrust",ja="エントラスト",enl="entrusting",jal="エントラスト"},
    {id=586,en="Curing Conduit",ja="被ケアル回復量アップ",enl="Curing Conduit",jal="被ケアル回復量アップ"},
    {id=587,en="TP Bonus",ja="TPボーナスアップ",enl="TP Bonus",jal="TPボーナスアップ"},
    {id=597,en="Inundation",ja="イナンデーション",enl="innundated",jal="イナンデーション"},
    {id=598,en="Cascade",ja="カスケード",enl="Cascade",jal="カスケード"},
    {id=599,en="Consume Mana",ja="コンスームマナ",enl="Consume Mana",jal="コンスームマナ"},
    {id=604,en="Mighty Guard",ja="マイティガード",enl="mightly guarded",jal="マイティガード"},
    {id=613,en="Mumor's Radiance",ja="ミュモルの光",enl="Mumor's Radiance",jal="ミュモルの光"},
    {id=614,en="Ullegore's Gloom",ja="ウルゴアの闇",enl="Ullegore's Gloom",jal="ウルゴアの闇"},
    {id=615,en="Boost",ja="ためる",enl="Boost",jal="ためる"},
    {id=616,en="Artisanal Knowledge",ja="芸術家肌",enl="Artisanal Knowledge",jal="芸術家肌"},
    {id=617,en="Sacrifice",ja="サクリファイス",enl="Sacrifice",jal="サクリファイス"},
    {id=619,en="Spirit Bond",ja="スピリットボンド",enl="Spirit Bond",jal="スピリットボンド"},
    {id=620,en="Awaken",ja="覚醒",enl="awakened",jal="覚醒"},
    {id=622,en="Guarding Rate Boost",ja="ガード率アップ",enl="Guarding Rate Boost",jal="ガード率アップ"},
    {id=623,en="Rampart",ja="ランパート",enl="Rampart",jal="ランパート"},
	
	-- dancer
	{id=368,en="Drain Samba",ja="ドレインサンバ",enl="Drain Samba",jal="ドレインサンバ"},
    {id=369,en="Aspir Samba",ja="アスピルサンバ",enl="Aspir Samba",jal="アスピルサンバ"},
    {id=370,en="Haste Samba",ja="ヘイストサンバ",enl="Haste Samba",jal="ヘイストサンバ"},
	{id=378,en="Drain Daze",ja="ドレインデイズ",enl="Drain Daze",jal="ドレインデイズ"},
    {id=379,en="Aspir Daze",ja="アスピルデイズ",enl="Aspir Daze",jal="アスピルデイズ"},
    {id=380,en="Haste Daze",ja="ヘイストデイズ",enl="Haste Daze",jal="ヘイストデイズ"},
    {id=381,en="Finishing Move 1",ja="フィニシングムーブ1",enl="Finishing Move 1",jal="フィニシングムーブ1"},
    {id=382,en="Finishing Move 2",ja="フィニシングムーブ2",enl="Finishing Move 2",jal="フィニシングムーブ2"},
    {id=383,en="Finishing Move 3",ja="フィニシングムーブ3",enl="Finishing Move 3",jal="フィニシングムーブ3"},
    {id=384,en="Finishing Move 4",ja="フィニシングムーブ4",enl="Finishing Move 4",jal="フィニシングムーブ4"},
    {id=385,en="Finishing Move 5",ja="フィニシングムーブ5",enl="Finishing Move 5",jal="フィニシングムーブ5"},
	{id=588,en="Finishing Move (6+)",ja="フィニシングムーブ(5+)",enl="Finishing Move (6+)",jal="フィニシングムーブ(5+)"},
    {id=386,en="Lethargic Daze 1",ja="クイックステップ1",enl="Lethargic Daze 1",jal="クイックステップ1"},
    {id=387,en="Lethargic Daze 2",ja="クイックステップ2",enl="Lethargic Daze 2",jal="クイックステップ2"},
    {id=388,en="Lethargic Daze 3",ja="クイックステップ3",enl="Lethargic Daze 3",jal="クイックステップ3"},
    {id=389,en="Lethargic Daze 4",ja="クイックステップ4",enl="Lethargic Daze 4",jal="クイックステップ4"},
    {id=390,en="Lethargic Daze 5",ja="クイックステップ5",enl="Lethargic Daze 5",jal="クイックステップ5"},
    {id=391,en="Sluggish Daze 1",ja="ボックスステップ1",enl="Sluggish Daze 1",jal="ボックスステップ1"},
    {id=392,en="Sluggish Daze 2",ja="ボックスステップ2",enl="Sluggish Daze 2",jal="ボックスステップ2"},
    {id=393,en="Sluggish Daze 3",ja="ボックスステップ3",enl="Sluggish Daze 3",jal="ボックスステップ3"},
    {id=394,en="Sluggish Daze 4",ja="ボックスステップ4",enl="Sluggish Daze 4",jal="ボックスステップ4"},
    {id=395,en="Sluggish Daze 5",ja="ボックスステップ5",enl="Sluggish Daze 5",jal="ボックスステップ5"},
    {id=396,en="Weakened Daze 1",ja="スタッターステップ1",enl="Weakened Daze 1",jal="スタッターステップ1"},
    {id=397,en="Weakened Daze 2",ja="スタッターステップ2",enl="Weakened Daze 2",jal="スタッターステップ2"},
    {id=398,en="Weakened Daze 3",ja="スタッターステップ3",enl="Weakened Daze 3",jal="スタッターステップ3"},
    {id=399,en="Weakened Daze 4",ja="スタッターステップ4",enl="Weakened Daze 4",jal="スタッターステップ4"},
    {id=400,en="Weakened Daze 5",ja="スタッターステップ5",enl="Weakened Daze 5",jal="スタッターステップ5"},
	{id=448,en="Bewildered Daze 1",ja="フェザーステップ1",enl="Bewildered Daze 1",jal="フェザーステップ1"},
    {id=449,en="Bewildered Daze 2",ja="フェザーステップ2",enl="Bewildered Daze 2",jal="フェザーステップ2"},
    {id=450,en="Bewildered Daze 3",ja="フェザーステップ3",enl="Bewildered Daze 3",jal="フェザーステップ3"},
    {id=451,en="Bewildered Daze 4",ja="フェザーステップ4",enl="Bewildered Daze 4",jal="フェザーステップ4"},
    {id=452,en="Bewildered Daze 5",ja="フェザーステップ5",enl="Bewildered Daze 5",jal="フェザーステップ5"},
	{id=375,en="Building Flourish",ja="B.フラリッシュ",enl="Building Flourish",jal="B.フラリッシュ"},
	{id=443,en="Climactic Flourish",ja="C.フラリッシュ",enl="Climactic Flourish",jal="C.フラリッシュ"},
	{id=468,en="Striking Flourish",ja="S.フラリッシュ",enl="Striking Flourish",jal="S.フラリッシュ"},
    {id=472,en="Ternary Flourish",ja="T.フラリッシュ",enl="Ternary Flourish",jal="T.フラリッシュ"},
	{id=410,en="Saber Dance",ja="剣の舞い",enl="Saber Dance",jal="剣の舞い"},
    {id=411,en="Fan Dance",ja="扇の舞い",enl="Fan Dance",jal="扇の舞い"},
	{id=442,en="Presto",ja="プレスト",enl="Presto",jal="プレスト"},
	
	-- scholar abilities
    {id=187,en="Sublimation: Activated",ja="机上演習:蓄積中",enl="Sublimation: Activated",jal="机上演習:蓄積中"},
    {id=188,en="Sublimation: Complete",ja="机上演習:蓄積完了",enl="Sublimation: Complete",jal="机上演習:蓄積完了"},
	{id=358,en="Light Arts",ja="白のグリモア",enl="Light Arts",jal="白のグリモア"},
    {id=359,en="Dark Arts",ja="黒のグリモア",enl="Dark Arts",jal="黒のグリモア"},
	{id=401,en="Addendum: White",ja="白の補遺",enl="Addendum: White",jal="白の補遺"},
    {id=402,en="Addendum: Black",ja="黒の補遺",enl="Addendum: Black",jal="黒の補遺"},
    {id=360,en="Penury",ja="簡素清貧の章",enl="Penury",jal="簡素清貧の章"},
    {id=361,en="Parsimony",ja="勤倹小心の章",enl="Parsimony",jal="勤倹小心の章"},
    {id=362,en="Celerity",ja="電光石火の章",enl="Celerity",jal="電光石火の章"},
    {id=363,en="Alacrity",ja="疾風迅雷の章",enl="Alacrity",jal="疾風迅雷の章"},
    {id=364,en="Rapture",ja="意気昂然の章",enl="Rapture",jal="意気昂然の章"},
    {id=365,en="Ebullience",ja="気炎万丈の章",enl="Ebullience",jal="気炎万丈の章"},
    {id=366,en="Accession",ja="女神降臨の章",enl="Accession",jal="女神降臨の章"},
    {id=367,en="Manifestation",ja="精霊光来の章",enl="Manifestation",jal="精霊光来の章"},
	{id=412,en="Altruism",ja="不惜身命の章",enl="Altruism",jal="不惜身命の章"},
    {id=413,en="Focalization",ja="一心精進の章",enl="Focalization",jal="一心精進の章"},
    {id=414,en="Tranquility",ja="天衣無縫の章",enl="Tranquility",jal="天衣無縫の章"},
    {id=415,en="Equanimity",ja="無憂無風の章",enl="Equanimity",jal="無憂無風の章"},
    {id=416,en="Enlightenment",ja="大悟徹底",enl="Enlightenment",jal="大悟徹底"},
	{id=469,en="Perpetuance",ja="令狸執鼠の章",enl="Perpetuance",jal="令狸執鼠の章"},
    {id=470,en="Immanence",ja="震天動地の章",enl="Immanence",jal="震天動地の章"},
	
	-- ninja
	{id=471,en="Migawari",ja="身替",enl="Migawari",jal="身替"},
	{id=420,en="Yonin",ja="陽忍",enl="Yonin",jal="陽忍"},
    {id=421,en="Innin",ja="陰忍",enl="Innin",jal="陰忍"},
	{id=441,en="Futae",ja="二重",enl="Futae",jal="二重"},
    
	-- geomancer
	{id=569,en="Blaze of Glory",ja="グローリーブレイズ",enl="Blaze of Glory",jal="グローリーブレイズ"},
    {id=515,en="Lasting Emanation",ja="エンデュアエマネイト",enl="Lasting Emanation",jal="エンデュアエマネイト"},
    {id=516,en="Ecliptic Attrition",ja="サークルエンリッチ",enl="Ecliptic Attrition",jal="サークルエンリッチ"},
    {id=517,en="Collimated Fervor",ja="コリメイトファーバー",enl="Collimated Fervor",jal="コリメイトファーバー"},
    {id=518,en="Dematerialize",ja="デマテリアライズ",enl="Dematerialize",jal="デマテリアライズ"},
    {id=519,en="Theurgic Focus",ja="タウマテルギフォカス",enl="Theurgic Focus",jal="タウマテルギフォカス"},
	{id=612,en="Colure Active",ja="コルア展開",enl="Colure Active",jal="コルア展開"},
	
	-- rune fencer
	{id=568,en="Foil",ja="特殊攻撃回避率アップ",enl="Foil",jal="特殊攻撃回避率アップ"},
    {id=532,en="Swordplay",ja="ソードプレイ",enl="Swordplay",jal="ソードプレイ"},
    {id=534,en="Embolden",ja="エンボルド",enl="emboldened",jal="エンボルド"},
	{id=533,en="Pflug",ja="フルーグ",enl="Pflug",jal="フルーグ"},
	{id=570,en="Battuta",ja="バットゥタ",enl="Battuta",jal="バットゥタ"},
    {id=571,en="Rayke",ja="レイク",enl="Rayke",jal="レイク"},
	{id=574,en="Fast Cast",ja="ファストキャスト",enl="Fast Cast",jal="ファストキャスト"},
    {id=535,en="Valiance",ja="ヴァリエンス",enl="Valiance",jal="ヴァリエンス"},
	{id=531,en="Vallation",ja="ヴァレション",enl="Vallation",jal="ヴァレション"},
    {id=536,en="Gambit",ja="ガンビット",enl="Gambit",jal="ガンビット"},
    {id=537,en="Liement",ja="リエモン",enl="Liement",jal="リエモン"},
    {id=538,en="One for All",ja="ワンフォアオール",enl="One for All",jal="ワンフォアオール"},
	{id=523,en="Ignis",ja="イグニス",enl="Ignis",jal="イグニス"},
    {id=524,en="Gelus",ja="ゲールス",enl="Gelus",jal="ゲールス"},
    {id=525,en="Flabra",ja="フラブラ",enl="Flabra",jal="フラブラ"},
    {id=526,en="Tellus",ja="テッルス",enl="Tellus",jal="テッルス"},
    {id=527,en="Sulpor",ja="スルポール",enl="Sulpor",jal="スルポール"},
    {id=528,en="Unda",ja="ウンダ",enl="Unda",jal="ウンダ"},
    {id=529,en="Lux",ja="ルックス",enl="Lux",jal="ルックス"},
    {id=530,en="Tenebrae",ja="テネブレイ",enl="Tenebrae",jal="テネブレイ"},
	
	-- pup maneuvers
    {id=300,en="Fire Maneuver",ja="ファイアマニューバ",enl="Fire Maneuver",jal="ファイアマニューバ"},
    {id=301,en="Ice Maneuver",ja="アイスマニューバ",enl="Ice Maneuver",jal="アイスマニューバ"},
    {id=302,en="Wind Maneuver",ja="ウィンドマニューバ",enl="Wind Maneuver",jal="ウィンドマニューバ"},
    {id=303,en="Earth Maneuver",ja="アースマニューバ",enl="Earth Maneuver",jal="アースマニューバ"},
    {id=304,en="Thunder Maneuver",ja="サンダーマニューバ",enl="Thunder Maneuver",jal="サンダーマニューバ"},
    {id=305,en="Water Maneuver",ja="ウォータマニューバ",enl="Water Maneuver",jal="ウォータマニューバ"},
    {id=306,en="Light Maneuver",ja="ライトマニューバ",enl="Light Maneuver",jal="ライトマニューバ"},
    {id=307,en="Dark Maneuver",ja="ダークマニューバ",enl="Dark Maneuver",jal="ダークマニューバ"},
	
	-- resistance buffs
	{id=74,en="Holy Circle",ja="ホーリーサークル",enl="Holy Circle",jal="ホーリーサークル"},
    {id=75,en="Arcane Circle",ja="アルケインサークル",enl="Arcane Circle",jal="アルケインサークル"},
    {id=117,en="Warding Circle",ja="護摩の守護円",enl="Warding Circle",jal="護摩の守護円"},
    {id=118,en="Ancient Circle",ja="エンシェントサークル",enl="Ancient Circle",jal="エンシェントサークル"},
	
	-- negates
    {id=293,en="Negate Petrify",ja="ネゲートペトリ",enl="Negate Petrify",jal="ネゲートペトリ"},
    {id=294,en="Negate Terror",ja="ネゲートテラー",enl="Negate Terror",jal="ネゲートテラー"},
    {id=295,en="Negate Amnesia",ja="ネゲートアムネジア",enl="Negate Amnesia",jal="ネゲートアムネジア"},
    {id=296,en="Negate Doom",ja="ネゲートドゥーム",enl="Negate Doom",jal="ネゲートドゥーム"},
    {id=297,en="Negate Poison",ja="ネゲートポイズン",enl="Negate Poison",jal="ネゲートポイズン"},
	{id=608,en="Negate Virus",ja="ネゲートウィルス",enl="Negate Virus",jal="ネゲートウィルス"},
    {id=609,en="Negate Curse",ja="ネゲートカーズ",enl="Negate Curse",jal="ネゲートカーズ"},
    {id=610,en="Negate Charm",ja="ネゲートチャーム",enl="Negate Charm",jal="ネゲートチャーム"},
	{id=626,en="Negate Sleep",ja="ネゲートスリープ",enl="Negate Sleep",jal="ネゲートスリープ"},
    
	-- rema
    {id=270,en="Aftermath: Lv.1",ja="アフターマス:Lv1",enl="Aftermath: Lv.1",jal="アフターマス:Lv1"},
    {id=271,en="Aftermath: Lv.2",ja="アフターマス:Lv2",enl="Aftermath: Lv.2",jal="アフターマス:Lv2"},
    {id=272,en="Aftermath: Lv.3",ja="アフターマス:Lv3",enl="Aftermath: Lv.3",jal="アフターマス:Lv3"},
    {id=273,en="Aftermath",ja="アフターマス",enl="Aftermath",jal="アフターマス"},
    {id=489,en="Afterglow",ja="アフターグロウ",enl="Afterglow",jal="アフターグロウ"},
	
	-- restrictions / costumes
	{id=284,en="Egg",ja="タマゴ",enl="Egg",jal="タマゴ"},
	{id=127,en="Costume",ja="コスチューム",enl="Costume",jal="コスチューム"},
	{id=585,en="Costume",ja="コスチューム",enl="costumed",jal="コスチューム"},
	{id=155,en="medicine",ja="服薬中",enl="medicated",jal="服薬中"},
    {id=143,en="Level Restriction",ja="レベル制限",enl="level-restricted",jal="レベル制限"},
	{id=157,en="SJ Restriction",ja="サポートジョブ無効",enl="SJ Restriction",jal="サポートジョブ無効"},
    {id=269,en="Level Sync",ja="レベルシンク",enl="Level Sync",jal="レベルシンク"},

	-- stances
	{id=417,en="Afflatus Solace",ja="ハートオブソラス",enl="Afflatus Solace",jal="ハートオブソラス"},
    {id=418,en="Afflatus Misery",ja="ハートオブミゼリ",enl="Afflatus Misery",jal="ハートオブミゼリ"},
	{id=353,en="Hasso",ja="八双",enl="Hasso",jal="八双"},
    {id=354,en="Seigan",ja="星眼",enl="Seigan",jal="星眼"},
	{id=621,en="Majesty",ja="マジェスティ",enl="Majesty",jal="マジェスティ"},
	
	-- avatar favors
	{id=431,en="Avatar's Favor",ja="神獣の加護",enl="Avatar's Favor",jal="神獣の加護"},
    {id=422,en="Carbuncle's Favor",ja="カーバンクルの加護",enl="Carbuncle's Favor",jal="カーバンクルの加護"},
    {id=423,en="Ifrit's Favor",ja="イフリートの加護",enl="Ifrit's Favor",jal="イフリートの加護"},
    {id=424,en="Shiva's Favor",ja="シヴァの加護",enl="Shiva's Favor",jal="シヴァの加護"},
    {id=425,en="Garuda's Favor",ja="ガルーダの加護",enl="Garuda's Favor",jal="ガルーダの加護"},
    {id=426,en="Titan's Favor",ja="タイタンの加護",enl="Titan's Favor",jal="タイタンの加護"},
    {id=427,en="Ramuh's Favor",ja="ラムウの加護",enl="Ramuh's Favor",jal="ラムウの加護"},
    {id=428,en="Leviathan's Favor",ja="リヴァイアサンの加護",enl="Leviathan's Favor",jal="リヴァイアサンの加護"},
    {id=429,en="Fenrir's Favor",ja="フェンリルの加護",enl="Fenrir's Favor",jal="フェンリルの加護"},
    {id=430,en="Diabolos's Favor",ja="ディアボロスの加護",enl="Diabolos's Favor",jal="ディアボロスの加護"},
	{id=577,en="Cait Sith's Favor",ja="ケット・シーの加護",enl="Cait Sith's Favor",jal="ケット・シーの加護"},
	{id=625,en="Siren's Favor",ja="セイレーンの加護",enl="Siren's Favor",jal="セイレーンの加護"},
	
	-- crafting / HELM
    {id=235,en="Fishing Imagery",ja="釣りイメージ",enl="Fishing Imagery",jal="釣りイメージ"},
    {id=236,en="Woodworking Imagery",ja="木工イメージ",enl="Woodworking Imagery",jal="木工イメージ"},
    {id=237,en="Smithing Imagery",ja="鍛冶イメージ",enl="Smithing Imagery",jal="鍛冶イメージ"},
    {id=238,en="Goldsmithing Imagery",ja="彫金イメージ",enl="Goldsmithing Imagery",jal="彫金イメージ"},
    {id=239,en="Clothcraft Imagery",ja="裁縫イメージ",enl="Clothcraft Imagery",jal="裁縫イメージ"},
    {id=240,en="Leathercraft Imagery",ja="革細工イメージ",enl="Leathercraft Imagery",jal="革細工イメージ"},
    {id=241,en="Bonecraft Imagery",ja="骨細工イメージ",enl="Bonecraft Imagery",jal="骨細工イメージ"},
    {id=242,en="Alchemy Imagery",ja="錬金術イメージ",enl="Alchemy Imagery",jal="錬金術イメージ"},
    {id=243,en="Cooking Imagery",ja="調理イメージ",enl="Cooking Imagery",jal="調理イメージ"},
	{id=578,en="Fishy Intuition",ja="釣り師のセンス",enl="Fishy Intuition",jal="釣り師のセンス"},
	
	-- exp/cp
    {id=249,en="Dedication",ja="専心",enl="Dedication",jal="専心"},
	{id=579,en="Commitment",ja="一心",enl="Commitment",jal="一心"},
	
	-- movement speed
	{id=32,en="Flee",ja="とんずら",enl="fleeing",jal="とんずら"},
    {id=176,en="quickening",ja="移動速度アップ",enl="quickened",jal="移動速度アップ"},
	
    -- food / mount
    {id=250,en="EF Badge",ja="遠征軍参加資格",enl="EF Badge",jal="遠征軍参加資格"},
    {id=251,en="Food",ja="食事",enl="Food",jal="食事"},
    {id=252,en="Mounted",ja="マウント",enl="Mounted",jal="マウント"},
	
	-- signets
	{id=253,en="Signet",ja="シグネット",enl="Signet",jal="シグネット"},
	{id=256,en="Sanction",ja="サンクション",enl="Sanction",jal="サンクション"},
	{id=268,en="Sigil",ja="シギル",enl="Sigil",jal="シギル"},
	{id=512,en="Ionis",ja="イオニス",enl="Ionis",jal="イオニス"},
	
	-- battlefields / instances
	{id=254,en="Battlefield",ja="バトルフィールド",enl="Battlefield",jal="バトルフィールド"},
    {id=257,en="Besieged",ja="ビシージド",enl="Besieged",jal="ビシージド"},
	{id=267,en="Allied Tags",ja="アライドタグ",enl="Allied Tags",jal="アライドタグ"},
	{id=510,en="Ergon Might",ja="エルゴンパワー",enl="Ergon Might",jal="エルゴンパワー"},
    {id=511,en="Reive Mark",ja="レイヴシンボル",enl="Reive Mark",jal="レイヴシンボル"},
	{id=475,en="Voidwatcher",ja="ヴォイドウォッチャー",enl="Voidwatcher",jal="ヴォイドウォッチャー"},
	{id=276,en="Confrontation",ja="コンフロント",enl="Confrontation",jal="コンフロント"},
	{id=285,en="Visitant",ja="ビジタント",enl="Visitant",jal="ビジタント"},
	{id=292,en="Pennant",ja="ペナント",enl="Pennant",jal="ペナント"},
	{id=627,en="Mobilization",ja="戦闘準備期間",enl="mobilized",jal="戦闘準備期間"},
	
	-- ballista
	{id=160,en="preparations",ja="試合復帰準備中",enl="preparing for battle",jal="試合復帰準備中"},
	{id=158,en="Provoke",ja="挑発",enl="provoked",jal="挑発"},
	{id=159,en="penalty",ja="ペナルティ",enl="penalized",jal="ペナルティ"},
    {id=161,en="Sprint",ja="スプリント",enl="Sprint",jal="スプリント"},
    {id=162,en="enchantment",ja="エンチャント",enl="enchanted",jal="エンチャント"},
	
	-- zone buffs
	{id=287,en="Atma",ja="アートマ",enl="Atma",jal="アートマ"},
	{id=602,en="Vorseal",ja="神符",enl="Vorseal",jal="神符"},
    {id=603,en="Elvorseal",ja="祈祷神符",enl="Elvorseal",jal="祈祷神符"},
    
    -- 72hr buffs
	{id=481,en="Abdhaljs Seal",ja="アブダルスの焼印",enl="Abdhaljs Seal",jal="アブダルスの焼印"},
    {id=618,en="Emporox's Gift",ja="エンポロックスのツボ",enl="Emporox's Gift",jal="エンポロックスのツボ"},
	
	-- unused?
	{id=24,en="ST24",ja="ＳＴ２４",enl="ST24",jal="ＳＴ２４"},
    {id=25,en="ST25",ja="ＳＴ２５",enl="ST25",jal="ＳＴ２５"},
    {id=26,en="ST26",ja="ＳＴ２６",enl="ST26",jal="ＳＴ２６"},
    {id=27,en="ST27",ja="ＳＴ２７",enl="ST27",jal="ＳＴ２７"},
    {id=224,en="ST224",ja="ＳＴ２２４",enl="ST224",jal="ＳＴ２２４"},
    {id=225,en="ST225",ja="ＳＴ２２５",enl="ST225",jal="ＳＴ２２５"},
    {id=226,en="ST226",ja="ＳＴ２２６",enl="ST226",jal="ＳＴ２２６"},
	{id=232,en="(N/A)",ja="（未使用）",enl="(N/A)",jal="（未使用）"},
}

function getBuffOrderWithIdKeys(b)
	local ret = {}
	local sort = 0
	for entry in b:it() do
		ret[entry.id] = sort
		sort = sort + 1
	end
	return ret
end

return buffOrder

-- CREDITS: based on windower's auto generated buffs.lua

--[[
Copyright © 2013-2020, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
