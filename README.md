# XivParty
A party list addon for Windower 4.

Shows party members' HP/MP/TP, main job, sub job and current buffs. Buffs can be filtered and are sorted debuffs before buffs for easier visibility. Distance to party members is indicated by dimming HP bars when out of casting or targeting range.

![Screenshot](https://i.imgur.com/VtnZmB0.jpg)

## Installation
* Download the [latest release](https://github.com/Tylas11/XivParty/releases) and extract it to Windower4/addons
* Load using "//lua load xivparty" in the chat window
* To load the addon automatically when the game starts, edit Windower4/scripts/init.txt and add "lua load xivparty" at the end
* RECOMMENDED: Download and install the free font "[Grammara](https://www.fontspace.com/grammara-font-f4454)" for a more authentic FF14 look of the numbers (restart Windower afterwards, or it won't find the newly installed font)

## Commands

| Command                 | Action                                                                                         |
| ----------------------- | ---------------------------------------------------------------------------------------------- |
| //xp filter add [ID]    | Adds filter for buff with specified ID.                                                        |
| //xp filter remove [ID] | Removes filter for buff with specified ID.                                                     |
| //xp filter clear       | Clears all buff filters.                                                                       |
| //xp filter list        | Shows list of all current filters in log window.                                               |
| //xp filter mode        | Switches between blacklist and whitelist filter mode (both use same filter list).              |
| //xp buffs [name]       | Shows list of currently active buffs (and IDs) for a party member. Omit name to see own buffs. |
| //xp range [near] [far] | Shows a marker for each party member closer than the set distances. "off" or "0" to disable.   |
| //xp customOrder        | Toggles custom buff ordering (customize in bufforder.lua).                                     |
| //xp hideSolo           | Hides the party list while solo.                                                               |
| //xp alignBottom        | Expands the party list from bottom to top.                                                     |
| //xp move               | Move the UI via drag and drop, use mouse wheel to adjust space between party members.          |
| //xp layout [file]      | Loads a UI layout file from the XivParty/layouts directory. Omit file extension. <br/> Use "auto" to enable resolution based selection (for default layouts only). |

## Range Indication
The distance to party members is indicated by dimming their HP bars in two stages: out of standard casting range (~20.8) and out of targeting range (50).

There is also a customizable range indicator useful when casting aoe buffs. Set a near and an optional far distance with the "range" command. A filled diamond icon (near) or a hollow diamond icon (far) will appear below the HP bar of any party member in range. The main player will always have the icon displayed when the feature is active. Set the range to "off" or "0" to disable.

## Custom Buff Ordering
By default buffs are ordered debuffs first, then buffs by various categories. This can be disabled to revert to the game's original ordering, which is sometimes random and based on when the buff was added to the game.

You can customize the sorting order by editing the file bufforder.lua. Just reorder the lines of the list. Do not change the IDs. The name strings are not used by the addon and are only there for readability. Save the file as UTF-8 without BOM or ANSI (however this will destroy the Japanese translations).

## Creating Custom Layouts
A layout consists of an XML file in XivParty/layouts and image files in XivParty/assets. Constants defining positions, offsets, sizes, fonts and colors of various UI elements are exposed in the XML file, so editing the LUA files should not be necessary in most cases.

You can set the color and alpha for every image, font and font outline (stroke) individually using a hexadecimal color code in the format #RRGGBBAA. Offsets, spacings and sizes are set in a single comma separated parameter, where the first number is either the X position or width and the second is Y or height. 

For further details, check out the comments in layout.lua.

#### Background
Consists of a fixed top and bottom image, and a center (mid) texture that repeats vertically when the party list resizes. When using repeating patterns, make the mid texture height as low as possible, as it can only repeat in full height steps and will be slightly compressed in between.

#### Bars
The HP/MP/TP bars each use a background and foreground image which can be set separately for all three bars. The foreground image is centered inside the background in code and should not have a transparent frame around it, or horizontal scaling will not look good when the bar's value changes.

#### Buff Icons
Buffs are positioned at the left edge of the TP bar and extend to the right. They wrap around to a second row when there are more buffs than the "wrap" count set in the layout. The "wrapOffset" will push the second row by a number of icon widths to the right.

The icons can be configured to align right and extend to the left. They will still start at the left edge of the TP bar, so a negative offset is recommended to move them outside the party list window.

#### Texts
Most texts can be configured separately, only the HP/MP/TP numbers share the same settings. There are additional font colors when the TP bar fills up or when HP drops below certain percentages. The zone name can optionally be right-aligned to the right edge of the TP bar. When using right alignment, it is recommended to use the "short" zone names or they might overlap with long player names.

You can use any system installed font, but make sure to restart Windower after installing new fonts or they wont be detected. If a font is not found, it will fall back to Arial.

#### Resizing Layouts
Set the "scale" parameter to adjust the size of all images. This will not affect any offsets, spacings or fonts so they have to be adjusted manually. Alternatively leave the scale at 1, resize the image files and set their new size in the XML. It is also possible to override the scale of individual images by adjusting their "size" parameter.

## Acknowledgments
* SirEdeonX (xivbar) - early prototype based on xivbar's code
* KenshiDRK (partybuffs) - buff packet code and buff icons
* Windower - buff listing for custom ordering feature