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

## 0.3.2 Beta
Non-selected nameplates can now pass protected threat percentages directly to the game text renderer where supported. Blue percentages are display-only: protected values cannot be used for numerical warning thresholds. Missing data still uses the grey fallback. Offline regression checks pass; this change still needs in-game multi-target verification.

## 0.3.10 Beta
## Changes since 0.3.2
- Party/raid threat display no longer requires your pet to tank; works with a dismissed or dead pet.
- Rising readable threat displays immediately when received. Only falling non-warning values are smoothed over 0.1 seconds.
- Center-screen warnings are now off by default, with an optional settings checkbox. Nameplate warnings and sound remain independent.
- Dark blue-grey settings with teal accents, matching WhatsNext/Crossroads. Plus/minus controls are retained.
- Missing-data text now reads Waiting for threat.
- Optional 30-second timing diagnostics: /petthreat latency on, off, report. Uses target-damage events as a labeled fallback when the combat log is unavailable.

## Validation and limitations
Offline Lua 5.1 regression tests passed. The updated settings appearance was reviewed in-game by the author. Cross-client coverage remains beta. Protected blue percentages are display-only and cannot drive numerical warning thresholds. Missing threat data is not zero threat. The addon cannot accelerate delayed game data; fallback timing includes damage from any attacker and is not a direct server-latency measurement. Retail is not supported.
