PetThreat 1.0.1

KNOWN LIMITATIONS
Percentages can be missing even on the selected target. Waiting for threat is
not zero threat. Blue protected percentages cannot drive numerical warnings.
Game data can be delayed; warnings cannot guarantee avoiding aggro. Multi-target
reliability and all-client compatibility are not fully verified in-game.

A small addon for hunters and warlocks. Simple settings window and minimap button; no libraries
or damage meter.

INSTALL
Close WoW. Extract the PetThreat folder into the selected client's Interface/AddOns.
The final path must be Interface/AddOns/PetThreat/PetThreat.toc.
Repeat for each client you use. Log in on your hunter or warlock and enable enemy nameplates (V).

DISPLAY
Below the enemy health bar by default. Solo: tracks enemies your pet tanks, or
enemies you tank where your pet has threat. In a party or raid, displays your
threat even when another player tanks, including when your pet is absent or dead.
Group warnings use the game's aggro-pull threshold, not a player-to-pet ratio.
Protected percentages remain display-only; missing data is shown in grey.
Green: your current percentage of the aggro-pull threshold.
Orange at 85%: EASE OFF, with optional sound and optional screen warning (off by default).
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

0.3.2: Display protected threat percentages through Blizzard's permitted
FontString:SetFormattedText path instead of discarding them. Light-blue numbers
are display-only: the custom warning threshold cannot be calculated from these
protected values. Readable threat values keep their normal colors and warnings.
If the API returns no percentage at all, the unavailable message remains.
This fixes a code limitation but still needs in-game multi-enemy verification.

COMPATIBILITY AND LIMITS
Targets Blizzard's modern Classic clients: Era/Hardcore/SoD, TBC Anniversary,
Wrath/Titan Reforged, Cataclysm, Mists and Forever. Retail is disabled explicitly.
Original 2004-2012 executables and private-server forks are not supported.
Offline Lua checks are not in-game verification on every
client. Older/newer patches may need Load out of date AddOns or a TOC update.
Forever can hide threat/identity data, particularly in instances. The addon uses
readable threat state when possible; it cannot provide percentage-based advance
warnings when those values are hidden. It shows Waiting for threat where possible.
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

0.3.3 BETA
Fixed group visibility: party/raid threat no longer requires your pet to tank or
have threat. Group display also works with a dismissed/dead pet. Group warnings
use neutral wording, and joining/leaving groups refreshes the display immediately.
Offline Lua 5.1 regression tests pass; party/raid behavior needs in-game testing.

0.3.4 BETA
Readable, non-warning percentages now transition over 0.2 seconds per nameplate.
Warning thresholds and aggro alerts still use the newest unsmoothed data. Warning
values and recovery from warnings display immediately. Missing or protected data
clears smoothing; blue protected percentages remain direct display and may jump.
This improves presentation, not the accuracy of the game data. In-game testing
is still needed. Group support from 0.3.3 is included.

0.3.5 BETA
Rising readable threat now displays immediately on the next threat update, even
during a downward transition. Only falling non-warning values are smoothed, over
0.1 seconds. Warning and aggro handling remain immediate. This removes added
rise animation delay; it cannot accelerate game/server threat updates.

0.3.6 BETA - DELAY MEASUREMENT
/petthreat latency on      Start a 30-second measurement (off by default).
/petthreat latency off     Stop early and print the summary.
/petthreat latency report  Print the last summary, saved per character.
Keep one target and fire single direct-damage shots at least 3 seconds apart.
The timer measures local combat-log damage-event receipt to the first observed
change in the target's readable, unsmoothed scaled threat percentage. It does
not measure projectile animation timing, network latency, or server latency.
Pet/other threat changes, event ordering, and data batching may affect results.
Sampling uses the normal 50-ms poll plus threat events, subject to frame time.
Overlapping hits are excluded. Target changes, hidden/missing values and hits
without a change within two seconds are not treated as successful samples.
A zero-ms sample means the changed value was already available at the hit event.
Protected values cannot be compared. Restricted/missing combat-log APIs are
reported instead of fabricating a measurement. Damage-over-time ticks excluded.
Results print in chat; the final summary is retained in PetThreatDB.

0.3.7 BETA - FOREVER DIAGNOSTIC FALLBACK
When the combat log API is missing, restricted, or rejects event registration,
latency on tries UNIT_COMBAT target WOUND events. The reason is printed.
This mode measures target damage events from ANY attacker (including your pet,
other players and periodic damage); it cannot identify your own shots. Reports
label this explicitly. The damage amount is never read. Protected threat or
identity data can still prevent timing. If no samples arrive, this is reported
as unavailable timing, never zero latency. The fallback needs in-game testing.
Use the same /petthreat latency on | off | report commands.
Reference: Blizzard UnitDocumentation.lua (Forever), UNIT_COMBAT event payload.

0.3.8 BETA
Center-screen warnings are off by default, including on upgrade. Enable them
with Show center-screen warning in settings or /petthreat screenwarning on.
The nameplate percentage/warnings and warning sound are independent of this
setting. Test display respects the checkbox. Reset settings turns it off.

0.3.9 BETA
Missing threat data now displays Waiting for threat instead of Threat unavailable.
The neutral grey label does not imply zero threat or promise that attacking will
unlock data. Protected percentage display and warning behavior are unchanged.

0.3.10 BETA
Settings restyled to match WhatsNext/Crossroads: dark blue-grey panels, thin
borders, teal accents, hover states and selected placement buttons. Plus/minus
controls are retained for warning percentage, font size and distance. No slider.

1.0.0 RELEASE
Promotes 0.3.10 with explicit known limitations. No threat-data behavior changes.

1.0.1 RELEASE
Enables Warlock alongside Hunter. Updated class descriptions and settings heading.
Existing threat-data limitations still apply. Warlock class gating tested offline;
in-game behavior across all clients and pets is not independently verified.
