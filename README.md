# XivParty
A party list addon for Windower 4.

Shows party members' HP/MP/TP, main job, sub job and current buffs. Buffs can be filtered and are sorted debuffs before buffs for easier visibility. Distance to party members is indicated by dimming HP bars when out of casting or targeting range.

![Screenshot](https://i.imgur.com/VtnZmB0.jpg)

## Installation
* Copy all files in the repo to Windower4/addons/XivParty
* Load using //lua load xivparty
* RECOMMENDED: Download and install the free font '[Grammara](https://www.fontspace.com/grammara-font-f4454)' for a more authentic FF14 look of the numbers

## Commands

| Command | Action |
| --- | --- |
| //xp filter add [ID] | Adds filter for buff with specified ID. |
| //xp filter remove [ID] | Removes filter for buff with specified ID. |
| //xp filter clear | Clears all buff filters. |
| //xp filter list | Shows list of all current filters in log window. |
| //xp filter mode | Switches between blacklist and whitelist filter mode (both use same filter list).
| //xp buffs [name] | Shows list of currently active buffs (and IDs) for a party member. Omit name to see own buffs. |
| //xp range [distance] | Shows a marker for each party member closer than the set distance. 'Off' or '0' to disable. |
| //xp customOrder | Toggles custom buff ordering (customize in bufforder.lua). |
| //xp hideSolo | Hides the party list while solo. |
| //xp move | Move the UI via drag and drop, use mouse wheel to adjust space between party members. |
| //xp layout [file] | Loads a UI layout file from the XivParty/layouts directory. Omit file extension. Use \'auto\' to enable resolution based selection (for preset layouts only). |

## Range Indication
The distance to party members is indicated by dimming their HP bars in two stages: out of standard casting range (~20.8) and out of targeting range (50).

There is also a customizable range indicator useful when casting aoe buffs. Set the desired distance with the 'range' command and any party member closer than this distance will have a small diamond icon displayed below their HP bar. The main player will always have this icon displayed when the feature is active. Set to range 0 or 'off' to disable.

## Custom Buff Ordering
By default buffs are ordered debuffs first, then buffs by various categories. This can be disabled to revert to the game's original ordering, which is sometimes random and based on when the buff was added to the game.

You can customize the sorting order by editing the file 'bufforder.lua'. Just reorder the lines of the list. Do not change the IDs. The name strings are not used by the addon and are only there for readability. Save the file as UTF-8 without BOM or ANSI (however this will destroy the Japanese translations).

## Creating Custom Layouts
A layout consists of an XML file in XivParty/layouts and image files in XivParty/assets. Constants defining positions, offsets, sizes, fonts and colors of various UI elements are exposed in the XML file, so editing the LUA files should not be necessary in most cases.

#### Background
Consists of a fixed top and bottom image, and a center (mid) texture that repeats vertically when the party list expands. All background images must have the same width, top and bottom must have the same height.
#### Bars
The HP/MP/TP bars all use the same images and consist of a background and a foreground part. The foreground image is centered inside the background in code and should not have a transparent frame around it, or scaling will not look good when the bar's value changes.
#### Fonts
You can use any system installed font, make sure to restart Windower after installing new fonts. The parameters text.color and text.stroke affect all fonts.
#### Resizing Layouts
Set the 'scale' parameter to adjust the size of all images. This will not affect any offsets, spacings or fonts so they have to be adjusted manually. Alternatively leave the scale at 1, resize the image files and set their new width / height in the XML.

## Acknowledgments
* SirEdeonX (xivbar) - early prototype based on xivbar's code
* KenshiDRK (partybuffs) - buff packet code and buff icons
* Windower - buff listing for custom ordering feature