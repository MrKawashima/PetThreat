PetThreat 0.3.1 beta

A small hunter-only addon. Simple settings window and minimap button; no libraries
or damage meter.

INSTALL
Close WoW. Extract the PetThreat folder into the selected client's Interface/AddOns.
The final path must be Interface/AddOns/PetThreat/PetThreat.toc.
Repeat for each client you use. Log in on your hunter and enable enemy nameplates (V).

DISPLAY
Below the enemy health bar by default. Only tracks enemies your pet tanks, or
enemies you tank where your pet has threat. Unrelated group-tanked enemies stay quiet.
Green: your current percentage of the aggro-pull threshold.
Orange at 85%: EASE OFF, with a screen warning and a short sound.
Red: AGGRO ON YOU. Missing/hidden data is never presented as 0% or safe.
100% means reaching the game's scaled pull threshold, NOT matching your pet's raw
threat. The game's scaling accounts for melee/ranged pull thresholds.
One large hit or moving into melee range can still pull before you react.
Warnings advise you only; this addon never stops attacks or controls your pet.

SETTINGS (saved per character)
Click the minimap button or type /petthreat to open the settings window.
Left-click: settings. Right-click: toggle sound. Drag: move around the minimap.
Use the window for above/below placement, warning threshold, text size, spacing,
sound, enable/disable, preview and reset. Escape closes the window.
/petthreat above       Place text above the health bar
/petthreat below       Place text below the health bar (default)
/petthreat warn 85     Warning threshold, 50-99
/petthreat sound off   Mute warning sound (on to enable)
/petthreat gap 4       Distance from the bar, 0-60 pixels
/petthreat size 13     Font size, 8-30
/petthreat test        Eight-second warning preview, also on visible nameplates
/petthreat off         Disable (on to enable)
/petthreat reset       Restore defaults
/petthreat             Open settings
/petthreat help        Show command help and current settings
/petthreat debug       Print build and target threat diagnostics during combat

0.2.1: Uses the target token for the selected enemy's nameplate and adds a
basic-threat-status fallback. Pet tanking - no % means pet aggro is confirmed,
but a numerical warning cannot be calculated. This is not a safe-to-attack signal.
Diagnostics distinguish HIDDEN, nil/no data, missing APIs and API errors.

0.2.2: Also checks pet target, focus and mouseover when they refer to exactly the
same enemy as a nameplate. These are live queries, not remembered percentages.
Debug now includes all visible nameplates, including enemies not selected.
This cannot guarantee percentages for every mob if the client does not expose them.

0.3.0: Hunter-themed settings window with an interactive sample nameplate.
Cycle preview switches between normal threat, warning and aggro examples.
The preview follows placement, gap, font size and warning threshold settings.
Threat is polled every 0.05 seconds (20 Hz), plus immediate threat-event updates.
One decimal is shown, truncated rather than rounded up across the warning boundary.
No interpolation or stale-value cache is used: warnings use the latest readable
data immediately. This improves display responsiveness, not server data accuracy.

0.3.1: Replaces the flat settings window with Blizzard dialog textures, framed
sections, standard WoW buttons and a more compact preview. The minimap icon now
uses a circular alpha mask with Blizzard's tracking-button rim. Existing saved
settings and the 20 Hz threat updates are preserved.

COMPATIBILITY AND LIMITS
Targets Blizzard's modern Classic clients: Era/Hardcore/SoD, TBC Anniversary,
Wrath/Titan Reforged, Cataclysm, Mists and Forever. Retail is disabled explicitly.
Original 2004-2012 executables and private-server forks are not supported.
This is an initial beta: offline Lua checks are not in-game verification on every
client. Older/newer patches may need Load out of date AddOns or a TOC update.
Forever can hide threat/identity data, particularly in instances. The addon uses
readable threat state when possible; it cannot provide percentage-based advance
warnings when those values are hidden. It shows Threat unavailable where possible.
Designed for Blizzard nameplates. Replacement nameplate addons need in-game testing;
their healthbar layout can require an offset adjustment or may not be supported.
Only visible enemy nameplates can carry text. Your current target is checked for
the screen/sound warning even when its plate is not visible.

IN-GAME CHECK
1. /petthreat test: confirm the preview, above/below and gap/font settings.
2. On an ordinary low-risk mob, let your pet establish aggro, then attack slowly.
3. Confirm the number rises and an orange warning appears before aggro transfers.
4. Stop attacking: confirm the warning clears as your pet gains threat.
5. Confirm red text when you have aggro, and hiding when your pet dies/is dismissed.
6. Repeat on each client. Record client version and any Lua error if reporting a bug.
