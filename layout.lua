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

local layout = {}

layout.scale = 1 -- image scale factor. does not affect offsets, spacings or font sizes. intended for easier creation of multi resolution layouts

layout.list = {}
layout.list.itemHeight = 46 -- overall height of a party list item (top to bottom, including all texts, images). not affected by scale
layout.list.offset = L{ 30, 0 } -- distance between edge of the mid background part and party list items

layout.bg = {}
layout.bg.imgTop = {}
layout.bg.imgTop.path = 'assets/BgTop.png'
layout.bg.imgTop.size = L{ 377, 21 }
layout.bg.imgTop.color = '#FFFFFFDD'

layout.bg.imgMid = {}
layout.bg.imgMid.path = 'assets/BgMid.png' -- this texture is repeated vertically when the list resizes
layout.bg.imgMid.size = L{ 377, 12 }
layout.bg.imgMid.color = '#FFFFFFDD'

layout.bg.imgBottom = {}
layout.bg.imgBottom.path = 'assets/BgBottom.png'
layout.bg.imgBottom.size = L{ 377, 21 }
layout.bg.imgBottom.color = '#FFFFFFDD'

layout.bar = {}
layout.bar.offset = L{ 0, 20 }
layout.bar.spacingX = 24 -- distance between hp, mp and tp bars
layout.bar.animSpeed = 0.1 -- speed of the bar animation in percent per frame (higher is faster)

-- glow colors are taken from the respective bar foreground colors
layout.bar.imgGlowMid = {}
layout.bar.imgGlowMid.path = 'assets/BarGlowMid.png'
layout.bar.imgGlowMid.size = L{ 6, 32 }

layout.bar.imgGlowSides = {}
layout.bar.imgGlowSides.path = 'assets/BarGlowSides.png'
layout.bar.imgGlowSides.size = L{ 3, 32 }

layout.bar.hp = {}
layout.bar.hp.glowColor = '#FFFFFFFF'
layout.bar.hp.imgBg = {}
layout.bar.hp.imgBg.path = 'assets/BarBG.png'
layout.bar.hp.imgBg.size = L{ 107, 10 }
layout.bar.hp.imgBg.color = '#FFFFFFFF'
layout.bar.hp.imgFg = {}
layout.bar.hp.imgFg.path = 'assets/BarFG.png'
layout.bar.hp.imgFg.size = L{ 103, 6 }
layout.bar.hp.imgFg.color = '#FFFFFFFF'

layout.bar.mp = {}
layout.bar.mp.glowColor = '#FFFFFFFF'
layout.bar.mp.imgBg = {}
layout.bar.mp.imgBg.path = 'assets/BarBG.png'
layout.bar.mp.imgBg.size = L{ 107, 10 }
layout.bar.mp.imgBg.color = '#FFFFFFFF'
layout.bar.mp.imgFg = {}
layout.bar.mp.imgFg.path = 'assets/BarFG.png'
layout.bar.mp.imgFg.size = L{ 103, 6 }
layout.bar.mp.imgFg.color = '#FFFFFFFF'

layout.bar.tp = {}
layout.bar.tp.glowColor = '#FFFFFFFF'
layout.bar.tp.imgBg = {}
layout.bar.tp.imgBg.path = 'assets/BarBG.png'
layout.bar.tp.imgBg.size = L{ 107, 10 }
layout.bar.tp.imgBg.color = '#FFFFFFFF'
layout.bar.tp.imgFg = {}
layout.bar.tp.imgFg.path = 'assets/BarFG.png'
layout.bar.tp.imgFg.size = L{ 103, 6 }
layout.bar.tp.imgFg.color = '#FFFFFFFF'

layout.jobIcon = {}
layout.jobIcon.offset = L{ -41, -2 } -- offset for the whole component
layout.jobIcon.path = 'assets/jobIcons/' -- where all job icons are located, named <3 letter job>.png
layout.jobIcon.colors = {} -- background colors for job roles
layout.jobIcon.colors.dd = '#663535FF'
layout.jobIcon.colors.tank = '#364597FF'
layout.jobIcon.colors.healer = '#3B6529FF'
layout.jobIcon.colors.support = '#DAB200FF'
layout.jobIcon.colors.special = '#FFFFFFFF'

layout.jobIcon.imgFrame = {}
layout.jobIcon.imgFrame.offset = L{ 0, 0 }
layout.jobIcon.imgFrame.path = 'assets/jobIcons/frame.png'
layout.jobIcon.imgFrame.size = L{ 36, 36 }
layout.jobIcon.imgFrame.color = '#FFFFFFFF'

layout.jobIcon.imgIcon = {}
layout.jobIcon.imgIcon.offset = L{ 0, -0.25 } -- slight Y offset to improve aliasing artifacts from scaling
layout.jobIcon.imgIcon.path = '' -- must remain empty
layout.jobIcon.imgIcon.size = L{ 36, 36 }
layout.jobIcon.imgIcon.color = '#FFFFFFFF'

layout.jobIcon.imgGradient = {}
layout.jobIcon.imgGradient.offset = L{ 0, 0 }
layout.jobIcon.imgGradient.path = 'assets/jobIcons/gradient.png'
layout.jobIcon.imgGradient.size = L{ 36, 36 }
layout.jobIcon.imgGradient.color = '#FFFFFFFF'

layout.jobIcon.imgBg = {}
layout.jobIcon.imgBg.offset = L{ 0, 0 }
layout.jobIcon.imgBg.path = 'assets/jobIcons/bg.png'
layout.jobIcon.imgBg.size = L{ 36, 36 }
layout.jobIcon.imgBg.color = '#FFFFFFFF' -- will be overwritten with role colors

layout.jobIcon.imgHighlight = {}
layout.jobIcon.imgHighlight.offset = L{ -13, -13 } -- relative to the whole job icon component position
layout.jobIcon.imgHighlight.path = 'assets/jobIcons/highlight.png'
layout.jobIcon.imgHighlight.size = L{ 62, 62 }
layout.jobIcon.imgHighlight.color = '#FFFFFFFF'

layout.leader = {}
layout.leader.offset = L{ 58, 15 }
layout.leader.img = {}
layout.leader.img.path = 'assets/Leader.png'
layout.leader.img.size = L{ 7, 5 }
layout.leader.img.color = '#E6E159FF' -- party leader color
layout.leader.allianceColor = '#FFFFFFFF'
layout.leader.quarterMasterColor = '#66E659FF'

layout.range = {}
layout.range.offset = L{ 0, 30 }
layout.range.img = {}
layout.range.img.path = 'assets/RangeIndicator.png'
layout.range.img.size = L{ 10, 10 }
layout.range.img.color = '#FFFFFFFF'

layout.rangeFar = {}
layout.rangeFar.offset = L{ 0, 30 }
layout.rangeFar.img = {}
layout.rangeFar.img.path = 'assets/RangeIndicator_far.png'
layout.rangeFar.img.size = L{ 10, 10 }
layout.rangeFar.img.color = '#FFFFFFFF'

layout.cursor = {}
layout.cursor.offset = L{ -50, 0 }
layout.cursor.img = {}
layout.cursor.img.path = 'assets/Cursor.png'
layout.cursor.img.size = L{ 46, 36 }
layout.cursor.img.color = '#FFFFFFFF'

layout.buffIcons = {}
layout.buffIcons.path = 'assets/buffIcons/'
layout.buffIcons.size = L{ 20, 20 }
layout.buffIcons.offset = L{ 1, 0 } -- icons are aligned to the left side of the TP bar
layout.buffIcons.spacing = L{ 0, 1 } -- Y coordinate is only used when buffs wrap around to a second row
layout.buffIcons.wrap = 19 -- wrap buff icons to a second row after this many icons (max 32 icons displayed)
layout.buffIcons.wrapOffset = 6 -- offset the second buff icon row by this many icons to the right
layout.buffIcons.alignRight = false -- icons will extend from right to left (still aligned to left side of TP bar, use offset!)

layout.text = {}
layout.text.tpFullColor = '#50B4FAFF'
layout.text.hpYellowColor = '#F3F37CFF'
layout.text.hpOrangeColor = '#F8BA80FF'
layout.text.hpRedColor = '#FC8182FF'

layout.text.numbers = {}
layout.text.numbers.font = 'Grammara'
layout.text.numbers.size = 11
layout.text.numbers.color = '#F0FFFFFF'
layout.text.numbers.stroke = '#062D54C8'
layout.text.numbers.strokeWidth = 2
layout.text.numbers.offset = L{ 2, 28 }

layout.text.name = {}
layout.text.name.font = 'Arial'
layout.text.name.size = 15
layout.text.name.color = '#F0FFFFFF'
layout.text.name.stroke = '#062D54C8'
layout.text.name.strokeWidth = 2
layout.text.name.offset = L{ 65, 1 }

layout.text.zone = {}
layout.text.zone.font = 'Arial'
layout.text.zone.size = 13
layout.text.zone.color = '#F0FFFFFF'
layout.text.zone.stroke = '#062D54C8'
layout.text.zone.strokeWidth = 2
layout.text.zone.offset = L{ 0, 1 }
layout.text.zone.short = false -- display short zone name
layout.text.zone.alignRight = false -- right align the text to the right end of the TP bar (use short zone names or text might overlap with player name)

layout.text.job = {}
layout.text.job.font = 'Arial'
layout.text.job.size = 8
layout.text.job.color = '#F0FFFFFF'
layout.text.job.stroke = '#062D54C8'
layout.text.job.strokeWidth = 2
layout.text.job.offset = L{ 0, 0 }

layout.text.subJob = {}
layout.text.subJob.font = 'Arial'
layout.text.subJob.size = 8
layout.text.subJob.color = '#F0FFFFFF'
layout.text.subJob.stroke = '#062D54C8'
layout.text.subJob.strokeWidth = 2
layout.text.subJob.offset = L{ 9, 9 }

return layout