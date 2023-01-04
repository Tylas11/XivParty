--[[
	Copyright © 2023, Tylas
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

-- DO NOT EDIT VALUES IN THIS FILE if you want to customize a layout, edit the XML files in the layouts directory instead.
-- This file only contains default values and changes wont have any effect!

-- All positions, scales and z-orders are relative to an element's parent.
-- Scale affects all positions and sizes, snapToRaster only affects positions.
-- Due to a windower limitation, z-orders only work between the same type of element (image, text). Texts will always be placed above images!

-- All elements support "enabled", "pos", "scale", "zOrder", "snapToRaster" and all texts support "alignRight" and "maxChars". 
-- However some of these properties have been omitted on some elements to keep the XMLs shorter.
-- Add these properties to any element in this file if your custom layout requires them, otherwise they will not be loaded from the XML.

local layout = {
	partyList = {
		rows = 6,
		columns = 1,
		rowHeight = 46,
		columnWidth = 410,

		-- Background
		background = {
			enabled = true,
			pos = L{ 0, -21 },
			imgTop = {
				enabled = true,
				pos = L{ 0, 0 },
				path = 'assets/XivBgTop.png',
				size = L{ 377, 21 },
				color = '#FFFFFFDD'
			},
			imgMid = {
				enabled = true,
				pos = L{ 0, 21 },
				path = 'assets/XivBgMid.png', -- this texture is repeated vertically when the list resizes
				size = L{ 377, 12 }, -- Y size will be overwritten in code, value here still required as a base
				color = '#FFFFFFDD'
			},
			imgBottom = {
				enabled = true,
				pos = L{ 0, 0 }, -- Y pos will be overwritten in code, value here irrelevant
				path = 'assets/XivBgBottom.png',
				size = L{ 377, 21 },
				color = '#FFFFFFDD'
			}
		},

		-- List item - a container for all UI elements of a party member, position is set in code
		listItem = {
			enabled = true,

			-- HP bar
			hp = {
				enabled = true,
				pos = L{ 19, -7 },
				zOrder = 1,
				hideOutsideZone = false,
				hpYellowColor = '#F3F37CFF', -- HP < 75%
				hpOrangeColor = '#F8BA80FF', -- HP < 50%
				hpRedColor = '#FC8182FF', -- HP < 25%
				snapToRaster = true,

				text = {
					enabled = true,
					pos = L{ 120, 35 },
					font = 'Grammara',
					size = 11,
					color = '#F0FFFFFF',
					stroke = '#062D54C8',
					strokeWidth = 2,
					alignRight = true,
					snapToRaster = true
				},

				bar = {
					enabled = true,
					pos = L{ 0, 0 },
					animSpeed = 0.1, -- speed of the bar animation in percent per frame (higher is faster)

					imgBg = {
						enabled = true,
						pos = L{ 0, 0 },
						path = 'assets/XivBarBG.png',
						size = L{ 128, 64 },
						color = '#FFFFFFFF'
					},
					imgBar = {
						enabled = true,
						pos = L{ 13, 0 }, -- centered inside the foreground image = fg.pos + (fg.size - bar.size) / 2
						path = 'assets/XivBar.png',
						size = L{ 102, 64 },
						color = '#FFFFFFFF'
					},
					imgFg = {
						enabled = true,
						pos = L{ 0, 0 },
						path = 'assets/XivBarFG.png',
						size = L{ 128, 64 },
						color = '#FFFFFFFF'
					},
					imgGlow = {
						enabled = true,
						pos = L{ 13, 0 }, -- centered inside foreground image = bar.pos.y + (bar.size.y - glow.size.y ) / 2, x position set in code
						path = 'assets/XivBarGlow.png',
						size = L{ 6, 64 },
						color = '#FFFFFFFF'
					},
					imgGlowSides = {
						enabled = true,
						pos = L{ 11, 0 }, -- x position set in code
						path = 'assets/XivBarGlowSides.png',
						size = L{ 2, 64 },
						color = '#FFFFFFFF'
					}
				}
			},
			-- MP bar
			mp = {
				enabled = true,
				pos = L{ 150, -7 },
				zOrder = 2,
				hideOutsideZone = false,
				snapToRaster = true,

				text = {
					enabled = true,
					pos = L{ 120, 35 },
					font = 'Grammara',
					size = 11,
					color = '#F0FFFFFF',
					stroke = '#062D54C8',
					strokeWidth = 2,
					alignRight = true,
					snapToRaster = true
				},

				bar = {
					enabled = true,
					pos = L{ 0, 0 },
					animSpeed = 0.1, -- speed of the bar animation in percent per frame (higher is faster)

					imgBg = {
						enabled = true,
						pos = L{ 0, 0 },
						path = 'assets/XivBarBG.png',
						size = L{ 128, 64 },
						color = '#FFFFFFFF'
					},
					imgBar = {
						enabled = true,
						pos = L{ 13, 0 }, -- centered inside the foreground image = fg.pos + (fg.size - bar.size) / 2
						path = 'assets/XivBar.png',
						size = L{ 102, 64 },
						color = '#FFFFFFFF'
					},
					imgFg = {
						enabled = true,
						pos = L{ 0, 0 },
						path = 'assets/XivBarFG.png',
						size = L{ 128, 64 },
						color = '#FFFFFFFF'
					},
					imgGlow = {
						enabled = true,
						pos = L{ 13, 0 }, -- centered inside foreground image = bar.pos.y + (bar.size.y - glow.size.y ) / 2, x position set in code
						path = 'assets/XivBarGlow.png',
						size = L{ 6, 64 },
						color = '#FFFFFFFF'
					},
					imgGlowSides = {
						enabled = true,
						pos = L{ 11, 0 }, -- x position set in code
						path = 'assets/XivBarGlowSides.png',
						size = L{ 2, 64 },
						color = '#FFFFFFFF'
					}
				}
			},
			-- TP bar
			tp = {
				enabled = true,
				pos = L{ 281, -7 },
				zOrder = 3,
				tpFullColor = '#50B4FAFF', -- TP > 1000
				hideOutsideZone = false,
				snapToRaster = true,

				text = {
					enabled = true,
					pos = L{ 120, 35 },
					font = 'Grammara',
					size = 11,
					color = '#F0FFFFFF',
					stroke = '#062D54C8',
					strokeWidth = 2,
					alignRight = true,
					snapToRaster = true
				},

				bar = {
					enabled = true,
					pos = L{ 0, 0 },
					animSpeed = 0.1, -- speed of the bar animation in percent per frame (higher is faster)

					imgBg = {
						enabled = true,
						pos = L{ 0, 0 },
						path = 'assets/XivBarBG.png',
						size = L{ 128, 64 },
						color = '#FFFFFFFF'
					},
					imgBar = {
						enabled = true,
						pos = L{ 13, 0 }, -- centered inside the foreground image = fg.pos + (fg.size - bar.size) / 2
						path = 'assets/XivBar.png',
						size = L{ 102, 64 },
						color = '#FFFFFFFF'
					},
					imgFg = {
						enabled = true,
						pos = L{ 0, 0 },
						path = 'assets/XivBarFG.png',
						size = L{ 128, 64 },
						color = '#FFFFFFFF'
					},
					imgGlow = {
						enabled = true,
						pos = L{ 13, 0 }, -- centered inside foreground image = bar.pos.y + (bar.size.y - glow.size.y ) / 2, x position set in code
						path = 'assets/XivBarGlow.png',
						size = L{ 6, 64 },
						color = '#FFFFFFFF'
					},
					imgGlowSides = {
						enabled = true,
						pos = L{ 11, 0 }, -- x position set in code
						path = 'assets/XivBarGlowSides.png',
						size = L{ 2, 64 },
						color = '#FFFFFFFF'
					}
				}
			},
			-- job icon
			jobIcon = {
				enabled = true,
				pos = L{ -11, -2 },
				zOrder = 4,
				scale = L{ 1, 1 },
				path = 'assets/jobIcons/', -- where all job icons are located, named <3 letter job>.png
				snapToRaster = true,

				-- background colors for job roles
				colors = {
					dd = '#663535FF',
					tank = '#364597FF',
					healer = '#3B6529FF',
					support = '#DAB200FF',
					special = '#FF9700FF'
				},

				imgFrame = {
					enabled = true,
					pos = L{ 0, 0 },
					path = 'assets/jobIcons/frame.png',
					size = L{ 36, 36 },
					color = '#FFFFFFFF'
				},
				imgIcon = {
					enabled = true,
					pos = L{ 0, 0 },
					path = '', -- must remain empty, set in code
					size = L{ 36, 36 },
					color = '#FFFFFFFF'
				},
				imgGradient = {
					enabled = true,
					pos = L{ 0, 0 },
					path = 'assets/jobIcons/gradient.png',
					size = L{ 36, 36 },
					color = '#FFFFFFFF'
				},
				imgBg = {
					enabled = true,
					pos = L{ 0, 0 },
					path = 'assets/jobIcons/bg.png',
					size = L{ 36, 36 },
					color = '#FFFFFFFF' -- will be overwritten with role colors
				},
				imgHighlight = {
					enabled = true,
					pos = L{ -13, -13 },
					path = 'assets/jobIcons/highlight.png',
					size = L{ 62, 62 },
					color = '#FFFFFFFF'
				}
			},
			-- leader icons
			leader = {
				enabled = true,
				pos = L{ -23, -6 },
				zOrder = 9,
				scale = L{ 1, 1 },

				imgParty = {
					enabled = true,
					pos = L{ 0, 0 },
					path = 'assets/XivLeader.png',
					size = L{ 22, 22 },
					color = '#FFFFFFFF'
				},
				imgAlliance = {
					enabled = true,
					pos = L{ 0, 11 },
					path = 'assets/XivAllianceLeader.png',
					size = L{ 22, 22 },
					color = '#FFFFFFFF'
				},
				imgQuarterMaster = {
					enabled = true,
					pos = L{ 0, 22 },
					path = 'assets/XivQuarterMaster.png',
					size = L{ 22, 22 },
					color = '#FFFFFFFF'
				}
			},
			-- range indicator
			range = {
				enabled = true,
				pos = L{ 30, 30 },
				zOrder = 10,

				imgNear = {
					enabled = true,
					pos = L { 0, 0 },
					path = 'assets/RangeIndicator.png',
					size = L{ 10, 10 },
					color = '#FFFFFFFF'
				},
				imgFar = {
					enabled = true,
					pos = L { 0, 0 },
					path = 'assets/RangeIndicatorFar.png',
					size = L{ 10, 10 },
					color = '#FFFFFFFF'
				}
			},
			-- cursor image
			cursor = {
				enabled = true,
				pos = L{ 20, -8 },
				zOrder = 0,
				path = 'assets/XivCursor.png',
				size = L{ 390, 60 },
				color = '#FFFFFFFF',
				scale = L{ 1, 1 }
			},
			-- buff icons
			buffIcons = {
				enabled = true,
				pos = L{ 293, 0 },
				zOrder = 11,
				path = 'assets/buffIcons/', -- directory where buff icons can be found. must follow naming pattern: <buffId>.png
				size = L{ 20, 20 }, -- size of all buff icon images
				color = '#FFFFFFFF', -- color of all buff icon images
				spacing = L{ 0, 1 }, -- spacing between each icon
				numIconsByRow = L{ 19, 13 }, -- number of icons to display in each row (max 32 in total)
				offsetByRow = L{ 0, 6 }, -- offset each row by this many icons to the right
				alignRight = false -- icons will extend from right to left (adjust pos, x origin will change to the right side!)
			},
			-- text labels
			text = {
				name = {
					enabled = true,
					pos = L{ 95, 1 },
					zOrder = 5,
					font = 'Arial',
					size = 15,
					color = '#F0FFFFFF',
					stroke = '#062D54C8',
					strokeWidth = 2,
					maxChars = 17, -- maximum number of characters to display, longer texts will be cut off by replacing the last allowed char with '...'
					snapToRaster = true
				},
				zone = {
					enabled = true,
					pos = L{ 292, 1 },
					zOrder = 6,
					font = 'Arial',
					size = 13,
					color = '#F0FFFFFF',
					stroke = '#062D54C8',
					strokeWidth = 2,
					short = false, -- display short zone name
					alignRight = false, -- right align the text to the right end of the TP bar (use short zone names or text might overlap with player name)
					snapToRaster = true
				},
				job = {
					enabled = true,
					pos = L{ 30, 0 },
					zOrder = 7,
					font = 'Arial',
					size = 8,
					color = '#F0FFFFFF',
					stroke = '#062D54C8',
					strokeWidth = 1,
					snapToRaster = true
				},
				subJob = {
					enabled = true,
					pos = L{ 39, 9 },
					zOrder = 8,
					font = 'Arial',
					size = 8,
					color = '#F0FFFFFF',
					stroke = '#062D54C8',
					strokeWidth = 1,
					snapToRaster = true
				}
			}
		}
	}
}

return layout