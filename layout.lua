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

local layout = {}

layout.scale = 1 -- image scale factor. does not affect offsets, spacings or font sizes. intended for easier creation of multi resolution layouts

layout.list = {}
layout.list.itemHeight = 40 -- overall height of a party list item (top to bottom, including all texts, images). not affected by scale
layout.list.offset = L{ 30, 0 } -- distance between edge of the mid background part and party list items

layout.bg = {}
layout.bg.imgTop = {}
layout.bg.imgTop.path = 'assets/BgTop.png'
layout.bg.imgTop.size = L{ 377, 21 }
layout.bg.imgTop.color = '#FFFFFFFF'

layout.bg.imgMid = {}
layout.bg.imgMid.path = 'assets/BgMid.png' -- this texture is repeated vertically when the list resizes
layout.bg.imgMid.size = L{ 377, 12 }
layout.bg.imgMid.color = '#FFFFFFFF'

layout.bg.imgBottom = {}
layout.bg.imgBottom.path = 'assets/BgBottom.png'
layout.bg.imgBottom.size = L{ 377, 21 }
layout.bg.imgBottom.color = '#FFFFFFFF'

layout.bar = {}
layout.bar.offset = L{ 0, 20 }
layout.bar.spacingX = 24 -- distance between hp, mp and tp bars
layout.bar.animSpeed = 0.1 -- speed of the bar animation in percent per frame (higher is faster)

layout.bar.hp = {}
layout.bar.hp.imgBg = {}
layout.bar.hp.imgBg.path = 'assets/BarBG.png'
layout.bar.hp.imgBg.size = L{ 107, 10 }
layout.bar.hp.imgBg.color = '#FFFFFFFF'
layout.bar.hp.imgFg = {}
layout.bar.hp.imgFg.path = 'assets/BarFG.png'
layout.bar.hp.imgFg.size = L{ 103, 6 }
layout.bar.hp.imgFg.color = '#FFFFFFFF'

layout.bar.mp = {}
layout.bar.mp.imgBg = {}
layout.bar.mp.imgBg.path = 'assets/BarBG.png'
layout.bar.mp.imgBg.size = L{ 107, 10 }
layout.bar.mp.imgBg.color = '#FFFFFFFF'
layout.bar.mp.imgFg = {}
layout.bar.mp.imgFg.path = 'assets/BarFG.png'
layout.bar.mp.imgFg.size = L{ 103, 6 }
layout.bar.mp.imgFg.color = '#FFFFFFFF'

layout.bar.tp = {}
layout.bar.tp.imgBg = {}
layout.bar.tp.imgBg.path = 'assets/BarBG.png'
layout.bar.tp.imgBg.size = L{ 107, 10 }
layout.bar.tp.imgBg.color = '#FFFFFFFF'
layout.bar.tp.imgFg = {}
layout.bar.tp.imgFg.path = 'assets/BarFG.png'
layout.bar.tp.imgFg.size = L{ 103, 6 }
layout.bar.tp.imgFg.color = '#FFFFFFFF'

layout.range = {}
layout.range.offset = L{ 0, 30 }
layout.range.img = {}
layout.range.img.path = 'assets/RangeIndicator.png'
layout.range.img.size = L{ 10, 10 }
layout.range.img.color = '#FFFFFFFF'

layout.cursor = {}
layout.cursor.offset = L{ 0, 0 }
layout.cursor.img = {}
layout.cursor.img.path = 'assets/Cursor.png'
layout.cursor.img.size = L{ 46, 36 } -- cursor is right aligned, this will be used to offset it to the left
layout.cursor.img.color = '#FFFFFFFF'

layout.buffIcons = {}
layout.buffIcons.path = 'assets/buffIcons/'
layout.buffIcons.size = L{ 20, 20 }
layout.buffIcons.offset = L{ 1, 0 }
layout.buffIcons.spacing = L{ 0, 1 } -- Y coordinate is only used when buffs wrap around to a second row
layout.buffIcons.wrap = 19 -- wrap buff icons to a second row after this many icons (max 32 icons displayed)
layout.buffIcons.wrapOffset = 6 -- offset the second buff icon row by this many icons to the right

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