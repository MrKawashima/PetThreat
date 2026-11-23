# PetThreat 1.0

![PetThreat](https://raw.githubusercontent.com/MrKawashima/PetThreat/main/media/banner.png)

Lightweight hunter threat information above or below enemy nameplates, with configurable early warnings, a simple settings window and a round minimap button.

## Known limitations - please read
- Threat percentages are not always available, including on the selected target or additional enemies. Grey **Waiting for threat** means missing data, not 0% or safety. Attacking does not guarantee that data becomes available.
- Blue percentages are protected game values shown directly. They cannot be used for numerical early-warning calculations. Blue does not mean safe.
- Threat updates can arrive after a hit. The addon cannot make the game provide data sooner. Warnings are advisory and cannot guarantee that you will avoid pulling aggro.
- Multiple visible nameplates are supported, but reliable percentages and advance warnings for every enemy are not guaranteed.
- In-game observations are from WoW Forever. The listed Classic clients are targeted by the code, not all verified in-game. Replacement nameplate addons may need adjustments. Retail and old/private-server executables are not supported.
- Optional timing diagnostics measure observed event-to-threat changes, not network/server latency. The fallback includes damage from any attacker, including your pet.

## Features
- Solo pet threat and party/raid threat, including groups with a dismissed or dead pet.
- Percentage above/below health bars; adjustable font size and spacing.
- Warning threshold 50-99%, default 85%, adjusted with plus/minus controls.
- Optional warning sound. Center-screen warning is off by default and can be enabled separately.
- Dark blue-grey settings, teal accents, live preview and movable round minimap button.
- Rising readable values display immediately when received; falling non-warning values smooth over 0.1 seconds.
- No external addon dependencies. Settings saved per character.

## Install and settings
Extract the PetThreat folder into your client's Interface/AddOns folder. Enable enemy nameplates with V. Reload the UI after updating.
Open settings with /petthreat or the minimap button. Right-click the minimap button to toggle sound; drag it to move it.

100% refers to the game's scaled aggro-pull threshold, not simply equal raw threat to your pet. The addon never stops your attacks or controls your pet.

## Troubleshooting
Use /petthreat debug for build and threat-data diagnostics.
Use /petthreat latency on for a 30-second timing session, off to stop early, and report to show the last summary.

## Release 1.0.0
This release promotes the 0.3.10 feature set to 1.0 with the limitations above explicitly documented; it does not claim to fix unavailable or delayed game data. Offline Lua 5.1 regression checks passed. See README.txt for command details and change history.

[Source and releases](https://github.com/MrKawashima/PetThreat)
