![PetThreat — Know when to ease off.](media/banner.png)

# PetThreat

A small hunter addon that shows your threat above or below enemy nameplates and warns before you pull aggro from your pet.

## Install
Download the ZIP from Releases. Extract the PetThreat folder into your client's Interface/AddOns folder. Enable enemy nameplates with V. Click the minimap button or use /petthreat for settings.

## Features
- One-decimal threat percentage, checked at 20 Hz plus threat events.
- Adjustable early warning threshold (85% default), visual warning and optional sound.
- Above/below placement, text size and spacing controls.
- WoW-style settings window, sample preview and round movable minimap button.
- No external addon dependencies. Retail is disabled.

## Beta status and limitations
Percentage display and visual early warnings have been observed in-game on the user's Forever client. Other Classic clients remain unverified in-game. The code targets modern Era/Hardcore/SoD, TBC Anniversary, Wrath/Titan Reforged, Cataclysm, Mists and Forever clients; this is not a claim that every client has been tested.

Non-selected enemies may lack readable threat percentages. PetThreat tries matching target, pet target, focus and mouseover aliases; it does not display stale cached values as live data. If the game hides or omits threat data, a numerical early warning cannot be calculated. Grey text indicates unavailable data.

100% represents the game's aggro-pull threshold, not simply equality with your pet's raw threat. Polling faster cannot increase server data accuracy. The addon never stops your attacks or controls your pet.

## Troubleshooting
Use /petthreat debug during combat and report the output with your client version. See README.txt for all commands.

## Validation
Offline Lua 5.1 checks cover threat classification, restricted-data handling, target aliases, client gates, settings, update interval and minimap controls. In-game multi-target and cross-client testing is still needed.

## CurseForge
[PetThreat on CurseForge](https://www.curseforge.com/wow/addons/petthreat) (new project; availability depends on moderation approval).
