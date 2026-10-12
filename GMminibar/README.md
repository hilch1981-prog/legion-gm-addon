# GM MINI BAR — SPP Legion

English · [한국어](README.ko.md)

**1.0.0 — Korean quest reply compatibility**

**v1.0.0** fixes quest travel with Korean server replies (`지도`, translated entry labels and lookup summaries). English replies remain supported independently of the UI language. Replace the addon folder and reload the UI; no SQL rollback is needed. See GAME_TEST.md for verification coverage.

A single-folder GM addon for **SPP Legion V2 Praevius / WoW 7.3.5.26972 / Interface 70300**, using the established GM MINI BAR black-and-gold interface and two-column utility cards.

RC2 restores the original menu placement, three-panel spell browser, category tree and two-column item browser with a quantity dialog, and six-category teleport table. Player spell classification now includes specialization/talent relationships and excludes profession eligibility masks. Dungeon/raid loot and item sets use matching Legion DB2 relationships.

Copy the `GMminibar` folder into the Legion client's `Interface/AddOns`. Enable **GM MINI BAR[Legion-SPP]** and log in with an account that has the required GM permissions. Keep other expansion editions in their respective clients. No extra MPQ or server binary/database modification is required.

RC4 restores the established WotLK bag toolbar: selection, height, destruction, sorting, sale and lock controls; search, item pins, free space, money and four numbered equipment slots remain below the grid. Quality/type filters, preview confirmation and character-specific slot pins are included. Manual/automatic sorting preserves pinned positions. The grid retains eight columns, 36px icons, a three-row default and wheel scrolling.

RC5 restores the missing settings and applies saved values to the actual UI, native loot CVar and bag behavior. It removes the blanket combat block on minibar command actions.

RC7 implements **Find objective** for unfinished creature, object and item-source objectives. Multiple objectives offer a selection list. Source IDs are resolved against live server spawns.

## RC8 utility controls

The running SPP command table was checked directly. Unsupported explore/bulk-learning/maxskill/unstuck requests have been removed from utility buttons. The original two-column layout remains.

- **Map reveal:** left-click opens the map with unexplored artwork shown; right-click restores normal fog. This is local map display, not exploration credit, XP, achievements or flight-path unlocking. Metadata covers 111 maps; Stonetalon was tested visually.
- **Respawn:** left-click clears selection and respawns nearby creatures/objects. Right-click keeps the selected dead creature. Living creatures, pets and players are rejected on the targeted path. Both creature paths were tested with a Forest Spider.
- **Unstuck:** uses this SPP's `.start`; its cast and actual arrival were verified.
- **Maximum skill:** raises already-learned professions to their current rank cap; it does not learn new professions or ranks.
- **GM/class/talent/profession learning:** opens an explicit spell or recipe picker instead of sending unsupported learn-all commands. GM search exposes the full catalog; talent spells come from class-specific Talent DB2 relations. Spell learning does not activate a talent. The recipe button filters unlearned recipes.
- Self-only commands are labeled accordingly. Named level changes use `.levelup NAME DELTA`. Other applicable utilities retain left=self and right=selected player/name.

Server replies remain visible; a sent request is not presented as confirmed success. `/gmbar audit` reads command help for troubleshooting without executing gameplay commands.

## Settings and server kill mode

The gear panel provides main-window/minibar scale, quest companion, combat window hiding, native auto loot, bag auto sorting, unified/native bags, gray-junk auto sale, position restore, language and diagnostics. Options apply immediately and persist; language changes require UI reload. Auto sale is OFF by default and excludes pinned, quest and unsellable items.

Kill sends `.die` once. SPP's damage-calculation mode may leave a target alive; the server administrator should set `Die.Command.Mode = 1` in `worldserver.conf` and execute `.reload config`. This was applied and tested on the user's current SPP server. The ZIP includes no server configuration and cannot automatically apply this setting to another server. Preconfigured minibar commands work during combat; opening protected windows, changing layout/options and rebinding keys remain restricted until combat ends.

## Controls

- `/gmbar`: utilities; `/gmbar bags`: unified bags; `/gmbar quest`: quest helper; `/gmbar test`: diagnostics; `/gmbar reset`: minibar position/scale reset.
- Gear: settings listed above, automatic language, Korean or English, UI reload and diagnostics. Other client languages fall back to English.
- Left-click applicable utilities for yourself. Right-click for the selected player or a name prompt. Commands without a name argument require a selectable nearby player. Summon/appear require another player.
- Drag the minibar grip to move it; use +/− to resize by 5%; right-click a slot to bind a key.
- Minibar slots: menu, bank, quest helper, teleport, self resurrection, GM mode, god mode, stealth, kill target, flight and movement speed. Ctrl-click bank to open unified bags.
- The game's key-binding menu offers unified bag and GM menu bindings. Existing backpack/all-bags keys (including B) open unified bags through a temporary override. Saved key assignments and Blizzard global bag functions remain unchanged.

## Included

Shared 1080×700 main windows scale to the screen. Utilities use two-column icon cards. Spell/item searches use local name/ID catalogs and class/quality/level filters; spell searches can hide known spells. Learning securely targets the player first; learned state is read back from client APIs. Professions show sequential ranks through Legion, current skill, maximum skill controls, recipes and reagent quantities. Unified bags use the native Legion container button click/drag handlers. Selection limits bulk operations to checked slots; pins block using, moving, sorting, selling or destroying those slots. Left-click Sort to sort now; right-click to toggle automatic sorting. Sale/destruction filters produce a confirmation list before execution. Sale excludes quest/unsellable items and requires an open merchant.

The quest helper offers Find objective, Complete, Start and End with optional party follow. Find resolves unfinished creature/object objectives and item loot/vendor sources against live SPP spawn queries; multiple objectives open a picker. Start/end use the respective giver relations. Travel prefers the nearest current-map spawn and uses the returned GUID, with a picker for ambiguous other-map destinations. Missing/mismatched data and failed queries stop with a message. Currency, reputation, area events and unmapped scripts may have no destination. Connected party members on the same quest can be summoned after arrival. Multiplayer and all-quest support are not live-verified.

Data includes **104,009 item names, 179,381 named spell records, 14 professions, 6,362 profession spell/recipe rows and 833 travel entries**. These are client catalog counts, not a guarantee that every entry is supported by the SPP world database. Normal spell browsing uses the player-class relationships; exact-ID lookup in All can still access the full catalog. Catalog searches run in small timer batches. RC2 removes the 2,000-match cap and stores compact numeric references, decoding only visible rows without permanent frame-update polling.

## Travel and limitations

Travel entries include difficulty variants of **131 outdoor portal landing points**, supplied SPP cities/zones/class halls and **422 client flight nodes**. Tabs are All, Zone, City, Dungeon, Raid and Battleground; Zone also includes flight masters and class halls. The table shows continent, zone/city, destination, type, recommended level and faction. Difficulty labels cover supported Normal/Heroic/Mythic and legacy 10/25-player modes. Travel waits for a requested difficulty change; failed changes cancel the teleport. Left-click teleports; right-click only changes a favorite. Column headers sort, with ascending level as the default and continent/zone/faction/favorite filters.

Portal coordinates come from WorldSafeLocs outdoor exit points, not meeting-stone object origins. Flight nodes come from TaxiNodes; full current SPP NPC spawn matching remains unverified. Explicit flight-node zone names and instance-parent relationships take priority over overlapping map rectangles. Recommended levels use matching dungeon/zone data, with expansion entry levels as a fallback. RC2 preserves all RC1 landing coordinates; terrain, mounts and phasing still require live landing tests.

Innkeeper data is not included. RC6 provides 22,353 public Legion giver relations; RC7 adds 28,061 objectives across 17,822 quests and public sources for 4,513 of 7,632 item-objective IDs. Runtime SPP queries supply spawn locations. No private world DB is imported or modified. Custom quests, phase variants and unmapped scripts remain compatibility boundaries. Generic `.go quest` remains disconnected after an invalid landing. ON/OFF controls submit requests rather than claiming a confirmed server state.

## Validation status

On 2026-10-10, Lua 5.1 syntax checks and **270 mock API contracts per language** passed. These are separate from the live game checks below.

RC8 live tests verified map artwork ON/OFF, selected/nearby creature respawn (dead → 2,212 health), one-click kill, unstuck travel, class/talent pickers, recipe filtering and already-max skill feedback. Diagnostics passed **24/24**, about **34.9 MiB** after testing, with no new session errors. The character returned to the original position at level 40. One historical blocked Hide error remains preserved. All commands, all 111 maps, multiplayer and actual RC8 bulk skill increases are not fully verified. See [GAME_TEST.md](GAME_TEST.md).

RC7 live checks cover the shackle object for quest 24575, the deer source for quest 24675, ground contact, arrival/nearby labels and return to the turn-in NPC. Diagnostics passed **24/24**, about **36.9 MiB**. One historical blocked Hide error is retained; the final combat/Escape retest session after the fix recorded no new errors. No quest objectives or rewards were completed. Earlier release results below are historical.

RC6 live checks cover quest 14098 start/end and quest 14093 end controls, current-map preference, walking away and teleporting back, ground contact and arrival messages. Diagnostics passed **23/23** with zero recorded errors. No quest objectives/rewards or server DB/configuration were changed.

RC5 live checks cover settings application/reload persistence, quest companion ON/OFF, native bag fallback, native auto loot, secure combat hide/restore, one key press killing a Raider's Training Dummy, one click killing a ranger, flight ON/OFF, GM mode and resurrection. Automatic junk sale was tested with mocked APIs only. See the test report for exact character side effects.

RC4 live checks cover the full bag toolbar/footer, B binding, pin protection, potion use (stack 2→1), selection, destruction preview/cancel, pinned manual/automatic sorting and persisted settings. After UI reload, diagnostics passed **22/22**, initially **29.9 MiB**, with **zero recorded errors**. Actual bulk sale/destruction, Shift-click/drag gestures and service transfers remain unverified in game; stateful mocked execution is reported separately.

Native control of the user's **7.3.5.26972 32-bit koKR client and SPP 2026.2a** verified RC2 Mortal Strike 12294 search/learn/unlearn and state refresh, 103,892 displayed item matches, two-column/advanced filter layout, the quantity dialog and one potion grant, teleport categories/table/difficulty labels/sorting, First Aid 75/75 and sequential rank controls, and compact menu placement at a small resolution. API/data diagnostics passed **22/22**, initially about **29.8 MiB**. Earlier RC1 tests covered bag use/equipment, flight, selected landings, difficulty switching and KO/EN display; [GAME_TEST.md](GAME_TEST.md) separates those observations from the RC2 retest.

Recipe refresh, overlapping windows, small-screen quest-helper placement, save icon and drag-grip display issues found in testing were fixed. This is not full acceptance of every command, profession rank, all 833 destinations, mounted/combat behavior or multiplayer actions. See [GAME_TEST.md](GAME_TEST.md) for the exact scope and remaining work.

Recent addon security errors and API diagnostics are stored in `GMMLegionDiagnostics`. Passing diagnostics is not proof of server command success.

See [SOURCES.md](SOURCES.md) for provenance and licensing.
