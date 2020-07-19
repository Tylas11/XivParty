# XivParty
A party list addon for Windower 4.

Shows party members' HP/MP/TP, main job, sub job and current buffs. Buffs can be filtered and are sorted debuffs before buffs for easier visibility. Distance to party members is indicated by dimming HP bars when out of casting or targeting range.

![Screenshot](https://i.imgur.com/VtnZmB0.jpg)

# Installation
* Copy all files in the repo to Windower4/addons/XivParty
* Load using //lua load xivparty
* RECOMMENDED: Download and install the free font '[Grammara](https://www.fontspace.com/grammara-font-f4454)' for a more authentic FF14 look of the numbers

# Commands

| Command | Action |
| --- | --- |
| //xp filter add &lt;ID&gt; | Adds filter for buff with specified ID. |
| //xp filter remove &lt;ID&gt; | Removes filter for buff with specified ID. |
| //xp filter clear | Clears all buff filters. |
| //xp filter list | Shows list of all current filters in log window. |
| //xp buffs &lt;name&gt; | Shows list of currently active buffs (and IDs) for a party member. Omit name to see own buffs. |
| //xp range &lt;distance&gt; | Shows a marker for each party member closer than the set distance. 'Off' or '0' to disable. |
| //xp customOrder on / off | Enable / disable custom buff ordering (customize in bufforder.lua). |
| //xp hideSolo on / off | Hide the party list while solo. |
| //xp move on / off | Move the UI via drag and drop, use mouse wheel to adjust space between party members. |

# Range indication
The distance to party members is indicated by dimming their HP bars in two stages: out of standard casting range (~20.8) and out of targeting range (50).

There is also a customizable range indicator useful when casting aoe buffs. Set the desired distance with the 'range' command and any party member closer than this distance will have a small diamond icon displayed below their HP bar. The main player will always have this icon displayed when the feature is active. Set to range 0 or 'off' to disable.

# Custom buff ordering
By default buffs are ordered debuffs first, then buffs by various categories. This can be disabled to revert to the game's original ordering, which is sometimes random and based on when the buff was added to the game.

You can customize the sorting order by editing the file 'bufforder.lua'. Just reorder the lines of the list. Do not change the IDs. The name strings are not used by the addon and are only there for readability. Save the file as UTF-8 without BOM or ANSI (however this will destroy the Japanese translations).

# Credits
* SirEdeonX (xivbar) - early prototype based on xivbar's code
* KenshiDRK (partybuffs) - buff parsing code and buff icons
* Windower - buff listing for custom ordering feature