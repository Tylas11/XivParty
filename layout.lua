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
layout.list.offsetX = 30 -- distance between left edge of the background and party list items
layout.list.offsetY = 0

layout.bg = {}
layout.bg.alpha = 255
layout.bg.imgTopPath = 'assets/BgTop.png'
layout.bg.imgMidPath = 'assets/BgMid.png' -- this texture is repeated vertically when the list resizes
layout.bg.imgBottomPath = 'assets/BgBottom.png'
layout.bg.imgWidth = 377 -- width of all background images in pixels
layout.bg.imgTopBottomHeight = 21 -- height of the top and bottom background image in pixels
layout.bg.imgMidHeight = 12

layout.bar = {}
layout.bar.imgBgPath = 'assets/BarBG.png'
layout.bar.imgFgPath = 'assets/BarFG.png'
layout.bar.imgBgWidth = 107
layout.bar.imgFgWidth = 103
layout.bar.imgBgHeight = 10
layout.bar.imgFgHeight = 6
layout.bar.offsetX = 0
layout.bar.offsetY = 20
layout.bar.spacingX = 24 -- distance between hp, mp and tp bars
layout.bar.animSpeed = 0.1 -- speed of the bar animation in percent per frame (higher is faster)

layout.range = {}
layout.range.imgPath = 'assets/RangeIndicator.png'
layout.range.imgWidth = 10
layout.range.imgHeight = 10
layout.range.offsetX = 0
layout.range.offsetY = 30

layout.cursor = {}
layout.cursor.imgPath = 'assets/Cursor.png'
layout.cursor.imgWidth = 46 -- cursor is right aligned, this will be used to offset it to the left
layout.cursor.imgHeight = 36
layout.cursor.offsetX = 0
layout.cursor.offsetY = 0

layout.buffIcons = {}
layout.buffIcons.path = 'assets/buffIcons/'
layout.buffIcons.width = 20
layout.buffIcons.height = 20
layout.buffIcons.offsetX = 1
layout.buffIcons.offsetY = 0
layout.buffIcons.spacingX = 0
layout.buffIcons.spacingY = 1 -- this is only used when buffs wrap around to a second row

layout.text = {}
layout.text.color = {}
layout.text.color.alpha = 255
layout.text.color.red = 240
layout.text.color.green = 255
layout.text.color.blue = 255

layout.text.stroke = {}
layout.text.stroke.width = 2
layout.text.stroke.alpha = 200
layout.text.stroke.red = 6
layout.text.stroke.green = 45
layout.text.stroke.blue = 84

layout.text.fullTpColor = {}
layout.text.fullTpColor.alpha = 255
layout.text.fullTpColor.red = 80
layout.text.fullTpColor.green = 180
layout.text.fullTpColor.blue = 250

layout.text.numbers = {}
layout.text.numbers.font = 'Grammara'
layout.text.numbers.size = 11
layout.text.numbers.offsetX = 2
layout.text.numbers.offsetY = 28

layout.text.name = {}
layout.text.name.font = 'Meiryo'
layout.text.name.size = 14
layout.text.name.offsetX = 65
layout.text.name.offsetY = -1

layout.text.zone = {}
layout.text.zone.font = 'Meiryo'
layout.text.zone.size = 12
layout.text.zone.offsetX = 0
layout.text.zone.offsetY = -1

layout.text.job = {}
layout.text.job.font = 'Arial'
layout.text.job.size = 8
layout.text.job.offsetX = 0
layout.text.job.offsetY = 0

layout.text.subJob = {}
layout.text.subJob.font = 'Arial'
layout.text.subJob.size = 8
layout.text.subJob.offsetX = 9
layout.text.subJob.offsetY = 9

return layout