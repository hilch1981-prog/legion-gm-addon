# Sources and validation boundaries

> v1.0.0 initial release / 최초 배포: the gameplay-tested RC8.1 implementation is retained; only version identifiers and distribution documentation were changed. Historical RC labels below preserve the actual test provenance. No new full gameplay test is claimed. / 실게임 시험한 RC8.1의 기능 코드를 유지하고 버전 표기와 배포 문서를 변경했습니다. 아래 RC 표기는 개발 시험 당시 기록이며 전체 기능을 새로 실게임 시험했다는 뜻이 아닙니다.

Prepared 2026-10-10. Client target: 7.3.5.26972, Interface 70300.

- The user-provided **SPP개조애드온.zip / SPPLegionAdmin** supplies command examples and the non-instance city/zone/class-hall travel seed. Blank/test entries and malformed decimal separators were handled during import. Original admin UI/libraries are not required at runtime.
- [Single-Player-Project/SPPLegionAdmin](https://github.com/Single-Player-Project/SPPLegionAdmin): official SPP command reference, GPLv3, derived from SecretMars/MarsAdmin and TrinityAdmin. Supplied travel data retains this attribution.
- [AshamaneCore Legion source](https://github.com/AshamaneProject/AshamaneCore/tree/b3ec0305caba2ab84596da501e9213ec4707d026): command arguments and behaviors checked in `cs_go`, `cs_learn`, `cs_modify`, `cs_misc`, `cs_cheat`, `cs_tele`. This is an upstream reference, not the exact private Praevius binary. No core implementation is included in the addon.
- [Blizzard Interface code mirror, Legion 7.3.5](https://github.com/tomrus88/BlizzardInterfaceCode/tree/8398c39f1e98c0ca34cf1bc480abdab8220fc1ec): secure item actions, native ContainerFrame item-button XML/handlers, MerchantFrame cursor-drop sale (PickupMerchantItem(0)), quest-map and `NEW_RECIPE_LEARNED` event references. RC5 also checks `SecureStateDriver.lua` visibility handling, `SecureHandlerTemplates.xml` and `InterfaceOptionsPanels.lua` autoLootDefault CVar wiring. This reference is build 25901; the supplied client data is build 26972. Selected operations were tested on the actual 26972 client; see `GAME_TEST.md`. No Blizzard UI source is bundled.
- Supplied SPP **7.3.5 DB2 files**, enUS/koKR: Spell, SpellLevels, SpellMisc, SpellEffect, SkillLine, SkillLineAbility, SpellReagents, Item, ItemSparse, Map, MapDifficulty, LFGDungeons, AreaTable, WorldSafeLocs and TaxiNodes. RC2 also joins SkillRaceClassInfo, ChrSpecialization, SpecializationSpells, Talent, JournalInstance, JournalEncounter, JournalEncounterItem, ItemSet and WorldMapArea. Extracted fields are limited to display names/IDs, search metadata, player/profession/loot relationships, reagents and travel coordinates. Original client archives are not bundled.
- [wowdev/WoWDBDefs](https://github.com/wowdev/WoWDBDefs): DB2 field descriptions selected by the actual file's layout hash. [wowdev/DBCD](https://github.com/wowdev/DBCD): WDC1 storage format reference for the offline reader. Neither library is required or bundled inside the installed addon.
- Existing [GM MINI BAR AzerothCore edition](https://github.com/hilch1981-prog/azerothcore-gm-addon): layout conventions and test harness foundation, GPLv3. The Legion implementation is separate and does not install WotLK/MoP/Turtle addons or data.

The addon source and adapted SPP travel table are distributed under GPL-3.0; see `LICENSE`. WoW game names, icons and extracted game metadata belong to their respective rights holders. Icons use the installed client's textures and are not redistributed as image files.

The generated catalog is an offline client catalog, not an export of the private SPP world database. It must not be presented as game-verified NPC placement or support for every client spell/item.

Developer regeneration order: run `work/legion-audit/build_data.py`, then `work/legion-audit/enrich_browser_data.py`, then `work/legion-build/scripts/validate.py`. The second step embeds browser relationships into the existing `Data/Catalog.lua` TOC entry, so an installed update can be loaded with ReloadUI without adding a new addon file entry mid-session. Its audit report records the unchanged coordinate-data SHA-256. Explicit destination zone names and instance-parent regions take priority over overlapping WorldMapArea rectangles; unmatched rectangles are display metadata, not proof of server-side area or terrain geometry.

## RC6 quest giver relations

[AshamaneProject ADB_735.10 release](https://github.com/AshamaneProject/AshamaneCore/releases/tag/ADB_735.10), asset ADB_735.10.rar, SHA-256 e3f0f90db8940f3a1201188fafdf740b8734e2d3e893e1cebbd14c2b9917154a. Extracted only creature/gameobject queststarter/questender IDs: 16,367 / 22,991 / 1,108 / 1,228 relations, covering 22,353 quests. No SQL database or fixed upstream spawn GUID/coordinate is distributed. This public reference is not an export of the private SPP world DB; mismatched/custom relations and phase-specific spawns remain a compatibility boundary. Live SPP list responses resolve the installed server's coordinates/GUIDs. `cs_list.cpp` at the existing pinned upstream commit documents lookup responses; English numeric/link response syntax was verified on the actual Korean client. Unknown formats stop without guessing.

Regenerate after the two catalog builders: run `work/legion-audit/extract_quest_relations.py` against that pinned archive, then `build_quest_givers.py`. The latter replaces one marked generated block inside the existing Catalog.lua TOC entry; it does not add another runtime addon folder. Compact strings avoid eagerly expanding all relation arrays. See QUEST_DATA_MANIFEST.json.

## RC7 objective and item-source relations

The same pinned ADB_735.10 archive supplies quest_objectives, creature/gameobject templates, creature/gameobject/reference loot and npc_vendor relations. The compact generated block contains 28,061 objectives across 17,822 quests, source IDs for 4,513 item-objective IDs, creature kill-credit mappings and display names. No fixed spawn GUID, objective coordinate, full SQL table, private DB or account information is bundled. Public relations can differ from the user's SPP fork.

AshamaneCore `QuestDef.h` defines objective types and hidden/progress-bar flags; `GameObjectData.h` identifies gameobject loot fields. The Gilneas `zone_gilneas_city1.cpp` script maps quest 14098 objective 267179 (kill-credit 35830) to the actual interactable door 195327. This explicit public-source override is mocked only, not retested in game. Actual SPP replies verified the `Entry:`/Y-label parsing boundary for object 201775. Actual quests 24575 and 24675 verified object and item-source travel on map 654.

Regeneration order: build_data.py, enrich_browser_data.py, extract_quest_relations.py, build_quest_givers.py, then build_quest_objectives.py. Both relation builders preserve the other's marked Catalog.lua block. All generated data stays within the existing single addon folder and existing TOC entry. Read QUEST_OBJECTIVE_MANIFEST.json for source hash, counts and coverage limits. Only the selected quest's objective rows are decoded at runtime; item-source queries are bounded and large source lists require a choice.

## RC8 utility and map sources

The running private SPP 2026.2a server's `.commands` and 43 read-only help queries establish the installed command surface. The public Ashamane source is not assumed to match this binary. Actual replies reject explore and bulk-learning commands listed in GAME_TEST.json. `.start`, `.respawn`, `.setskill` and the name-before-delta levelup syntax were found in the running server help. Live action results are documented separately from help availability.

The supplied WorldMapOverlay/WorldMapArea DB2s provide 111 map groups and 1,521 unique unconditional map artwork rectangles. Conditional/invalid rows are excluded. A small original renderer uses the installed client's existing textures; no map image or Blizzard UI implementation is redistributed. The pinned BlizzardInterfaceCode WorldMapFrame.lua documents 256-pixel tiles and power-of-two edge padding. MAP_REVEAL_MANIFEST.json records the exact supplied DB2 hashes. This only changes map display, not server exploration data.

The supplied Talent DB2 provides class-specific talent spell IDs. The supplied SkillLineAbility has no members for the GM/internal skill-line 769, so the GM button intentionally opens the full spell catalog rather than inventing a curated GM group. UTILITY_SPELL_MANIFEST.json records source hashes and counts. Learning these spells does not select talents in the talent system.

After the existing catalog, browser and quest builders, run `work/legion-audit/build_map_reveal.py` and `build_utility_spells.py`, then `work/legion-build/scripts/validate.py`. Each builder replaces its own marked block in the existing Catalog.lua TOC entry. Use read_utility_runtime.py only for the filtered diagnostics export; do not bundle account files, general chat, the help audit or raw SavedVariables.

## RC8.1 localized quest replies

The supplied `056_legion_world_trinity_string.sql` (SHA-256 `d04bccc971835d38cd2ab5e97b8055a118f347d6878640e33fcb1e97531e98ef`) provides Korean templates 439, 441, 515 and 517. The regression fixtures retain only these four format strings, not the database or account data. The screenshot-reported map/entry labels are matched independently of the addon UI language. Unknown reply formats still cannot invent coordinates. See GAME_TEST.md for the separate runtime evidence.
