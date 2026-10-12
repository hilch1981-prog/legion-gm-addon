local A=GMMLegion735
local EN={
 title='GM MINI BAR · Legion / SPP',menu='GM menu',utilities='GM Utilities',travel='Teleport',items='Items',spells='Spell search',professions='Professions',commands='GM Commands',island='GM Island',bags='Unified bags',quests='GM Quest Helper',settings='Settings',
 search='Search',nameid='Name or ID',all='All',previous='Previous',next='Next',level='Level',myLevel='At or below my level',hideKnown='Hide learned',known='Learned',learn='Learn spell',unlearn='Unlearn',learned='Learned',unlearned='Not learned',rank='Spell rank',select='Select an entry.',id='ID',class='Class',quality='Quality',count='Count',add='Add item',itemlevel='Item level',detail='Details',
 empty='No results',pending='Request sent. Waiting for server/client confirmation.',combat='Available after combat.',invalid='Invalid command or input.',selfTargetFail='Self targeting failed; command was not sent.',unavailable='This action is not available.',loaded='Legion edition loaded.',wrongVersion='This addon requires Legion 7.3.5 / Interface 70300.',
 selfOther='Left: self · Right: selected player / enter name',enterName='Enter the player name',apply='Apply',cancel='Cancel',notFound='Select an online player nearby. No command was sent.',
 drag='Drag here to move the mini bar',scaleUp='Increase size by 5%',scaleDown='Decrease size by 5%',bindings='Key binding',bindHint='Press a key combination. Escape cancels; Delete clears.',
 repair='Repair items',cooldown='Reset cooldowns',combatStop='Stop combat',unstuck='Unstuck character',dismount='Dismount',demorph='Restore appearance',waterwalk='Water walking',save='Save character',revive='Resurrect',gm='GM mode',god='Invulnerability',stealth='Stealth',kill='Kill target',fly='Flight',speed='Movement speed',on='ON',off='OFF',unknown='Unknown',
 up1='Level +1',down1='Level -1',up10='Level +10',down10='Level -10',explore='Reveal maps',taxi='Unlock flight paths',gold='Add 1,000 gold',cast='Instant cast',power='No power cost',access='Ignore instance requirements',gmskills='Learn GM spells',crafts='Learn professions / recipes',myclass='Learn class spells',talents='Learn talents',summon='Summon player',appear='Teleport to player',respawn='Respawn nearby',maxskill='Maximize skills',recipes='Learn all recipes',expansion='Account expansion',difficulty='Difficulty',normal='Normal',heroic='Heroic',mythic='Mythic',legacy='Legacy',dungeon='Dungeon',raid='Raid',battleground='Battleground',city='City',zone='Zone',inn='Inn',flight='Flight master',classhall='Class hall',outdoor='Outdoor entrance',favorite='Favorite',move='Teleport',recall='Return',continent='Continent',destination='Destination',faction='Faction',neutral='Neutral',
 skill='Skill',train='Learn rank',maximize='Maximize skill',professionRank='Profession rank',reagents='Reagents in bags',required='Required',liveSkill='Current skill',onlyKnown='Learned only',recipeRanks='Recipe ranks',
 bagSlots='Equipped bags (drag a bag here)',free='Free slots',money='Money',sort='Sort bags',nativeBags='Default bags',bank='Bank',
 find='Find objective',complete='Complete',start='Quest start',finish='Quest end',party='Apply to party',questMissing='Select a quest in the quest log.',locationUnknown='No server location is available. Open quest map or request server lookup.',openMap='Quest map',targetQuest='Selected quest',serverLookup='Server lookup',questID='Quest ID',
 language='Language',auto='Automatic',reload='Reload UI',diagnostics='Diagnostics',clear='Clear',run='Run',arguments='Command arguments',serverReply='Server reply',confirmKnown='Already learned.',noRecipe='Select a profession.',unsupported='Support depends on your SPP server command permissions.',
 pendingDifficulty='Waiting for difficulty update before teleporting.',difficultyDenied='Difficulty did not change. Teleport cancelled.',landingNote='Outdoor portal coordinates; landing must be verified on your server.',
 repairNote='Repairs equipped and bag items.',loot='Loot target',moved='Position saved.',spellSource='Client 7.3.5 spell database',itemsSource='Client 7.3.5 item database',
 }
local KO={title='GM MINI BAR · 군단 / SPP',menu='GM 메뉴',utilities='GM 편의 기능',travel='순간이동',items='아이템',spells='주문 검색',professions='전문기술',commands='GM 명령어',island='GM의 섬',bags='통합 가방',quests='GM 퀘스트 도우미',settings='설정',
 search='검색',nameid='이름 또는 ID',all='전체',previous='이전',next='다음',level='레벨',myLevel='내 레벨 이하',hideKnown='습득한 주문 제외',known='습득',learn='스킬 습득',unlearn='습득 취소',learned='습득 완료',unlearned='미습득',rank='주문 단계',select='목록에서 선택하세요.',id='ID',class='클래스',quality='품질',count='수량',add='아이템 추가',itemlevel='아이템 레벨',detail='상세 정보',
 empty='검색 결과 없음',pending='요청을 보냈습니다. 서버·클라이언트 응답 후 반영됩니다.',combat='전투 종료 후 사용할 수 있습니다.',invalid='올바르지 않은 명령 또는 입력입니다.',selfTargetFail='본인 대상 지정에 실패해 명령을 보내지 않았습니다.',unavailable='현재 사용할 수 없는 기능입니다.',loaded='군단 버전을 불러왔습니다.',wrongVersion='군단 7.3.5 / Interface 70300 전용입니다.',
 selfOther='왼쪽: 본인 · 오른쪽: 선택 플레이어 / 이름 입력',enterName='캐릭터 이름 입력',apply='적용',cancel='취소',notFound='근처의 온라인 플레이어를 선택하세요. 명령을 보내지 않았습니다.',drag='여기를 잡고 미니바를 이동하세요',scaleUp='크기 5% 확대',scaleDown='크기 5% 축소',bindings='단축키 설정',bindHint='조합키를 누르세요. ESC: 취소 / Delete: 해제',
 repair='아이템 수리',cooldown='재사용 시간 초기화',combatStop='전투 중지',unstuck='캐릭터 탈출',dismount='탈것 내리기',demorph='외형 복원',waterwalk='수면 보행',save='캐릭터 저장',revive='부활',gm='GM 모드',god='무적',stealth='은신',kill='대상 즉사',fly='비행 모드',speed='이동 속도',on='ON',off='OFF',unknown='확인 전',
 up1='레벨 1 상승',down1='레벨 1 감소',up10='레벨 10 상승',down10='레벨 10 감소',explore='지도 개방',taxi='비행 경로 해제',gold='1000 골드 추가',cast='즉시 시전',power='자원 소모 해제',access='인던 입장 조건 해제',gmskills='GM 스킬 습득',crafts='전문기술 / 조리법 배우기',myclass='직업 주문 배우기',talents='특성 배우기',summon='대상 소환',appear='대상으로 순간이동',respawn='주변 리스폰',maxskill='숙련도 최대',recipes='모든 조리법 배우기',expansion='계정 확장팩 수준',difficulty='난이도',normal='일반',heroic='영웅',mythic='신화',legacy='이전 확장팩',dungeon='던전',raid='공격대',battleground='전장',city='도시',zone='지역',inn='여관',flight='비행 조련사',classhall='직업 전당',outdoor='외부 입구',favorite='즐겨찾기',move='순간이동',recall='이전 위치',continent='대륙',destination='목적지',faction='진영',neutral='중립',
 skill='숙련도',train='등급 습득',maximize='숙련 최대',professionRank='숙련 등급',reagents='가방 내 재료',required='필요',liveSkill='현재 숙련도',onlyKnown='습득만',recipeRanks='조리법 단계',
 bagSlots='장착 가방 (가방을 끌어다 놓으세요)',free='빈칸',money='소지금',sort='가방 정렬',nativeBags='기본 가방',bank='은행',find='조건 찾기',complete='조건 완료',start='시작 위치',finish='종료 위치',party='파티원 적용',questMissing='퀘스트 목록에서 퀘스트를 선택하세요.',locationUnknown='서버 위치 정보가 없습니다. 퀘스트 지도 또는 서버 검색을 이용하세요.',openMap='퀘스트 지도',targetQuest='선택 퀘스트',serverLookup='서버 검색',questID='퀘스트 ID',
 language='언어',auto='자동',reload='UI 다시 불러오기',diagnostics='진단',clear='초기화',run='실행',arguments='명령 인수',serverReply='서버 응답',confirmKnown='이미 습득한 주문입니다.',noRecipe='전문기술을 선택하세요.',unsupported='현재 SPP 서버의 명령 지원·권한에 따라 작동합니다.',
 pendingDifficulty='난이도 변경 확인 후 이동합니다.',difficultyDenied='난이도가 변경되지 않아 이동을 취소했습니다.',landingNote='외부 포탈 좌표입니다. 실제 서버의 착지를 확인해야 합니다.',repairNote='장착 장비와 가방 속 아이템을 수리합니다.',loot='대상 전리품',moved='위치를 저장했습니다.',spellSource='군단 7.3.5 주문 자료',itemsSource='군단 7.3.5 아이템 자료'}
A.locales={enUS=EN,koKR=KO}
local browserLabels={
 gmskills={'GM spell search (all spells)','GM 주문 검색 (전체)'},crafts={'Choose professions / recipes','전문기술 / 조리법 선택'},myclass={'Choose class spells','직업 주문 선택'},talents={'Choose talent spells','특성 주문 선택'},recipePicker={'Show unlearned recipes','미습득 조리법 보기'},
 utilityPickerHint={'Left: open the learning list. Select a spell, then learn it for yourself. This SPP build does not support bulk-learning commands.','왼쪽: 습득 목록 열기. 주문을 선택한 뒤 본인에게 습득합니다. 이 SPP 서버는 일괄 습득 명령을 지원하지 않습니다.'},
 talentPickerHint={'Choose individual talent spells for your class. Learning a spell does not select a talent in the talent panel.','내 직업의 특성 주문을 개별 선택합니다. 주문 습득은 특성창의 특성 선택과 별개입니다.'},
 utilityPickerNote={'Select a spell, then click Learn spell.','주문 선택 후 스킬 습득을 누르세요.'},talentPickerNote={'Spell learning does not select or activate a talent.','주문 습득은 특성창의 선택·활성화와 별개입니다.'},
 maxSkillsHint={'Maximize your learned professions to their current rank caps. Does not learn professions or unlock later ranks.','본인이 배운 전문기술을 현재 등급의 최대 숙련도로 올립니다. 새 기술이나 다음 등급은 배우지 않습니다.'},
 skillsAlreadyMax={'No learned professions need skill points. Learn a profession rank first if needed.','올릴 숙련도가 없습니다. 필요한 전문기술 등급을 먼저 배우세요.'},
 mapRevealHint={'Left: reveal map artwork and open the map.\nRight: restore normal unexplored fog.\nLocal display only; exploration credit, XP and flight paths are unchanged.','왼쪽: 미탐험 지형 표시 · 지도 열기\n오른쪽: 원래 지도 표시로 복원\n지도 표시 전용이며 탐험 실적·경험치·비행 경로는 변경하지 않습니다.'},
 mapRevealOn={'Map terrain is revealed. Exploration progress is unchanged.','미탐험 지형을 표시합니다. 탐험 진행도는 변경하지 않습니다.'},
 mapRevealOff={'Normal map fog restored.','기본 지도 표시로 복원했습니다.'},
 selfOnly={'Applies to your character. Left click to use.','본인 전용 기능입니다. 왼쪽 클릭으로 사용하세요.'},
 respawnHint={'Left: clear target and respawn nearby creatures / objects.\nRight: respawn the selected dead creature.','왼쪽: 대상을 해제하고 주변 몬스터·오브젝트 리스폰\n오른쪽: 선택한 죽은 몬스터만 리스폰'},
 respawnSelect={'Select a dead creature. Players and pets cannot be respawned here.','죽은 몬스터를 선택하세요. 플레이어·소환수는 리스폰 대상이 아닙니다.'},
 respawnClearFailed={'Target clearing failed; no respawn command was sent.','대상 해제에 실패해 리스폰 명령을 보내지 않았습니다.'},
 respawnSent={'Respawn requested. Check the creature / object or the server reply.','리스폰을 요청했습니다. 몬스터·오브젝트 상태 또는 서버 응답을 확인하세요.'},
 respawnConfirmed={'The selected creature is alive again.','선택한 몬스터가 다시 살아난 것을 확인했습니다.'},
 equippedBags={'Equipped bags','장착 가방'},emptyBagSlot={'Empty bag slot','빈 가방칸'},bagEquipHint={'Drop a bag here to equip or replace it.','가방을 끌어 놓아 장착 / 교체'},bagClickHint={'Click: open bag · Drag: pick up bag','클릭: 개별 가방 열기 · 드래그: 가방 꺼내기'},bagGrow={'Increase bag height','가방 높이 늘리기'},bagShrink={'Decrease bag height','가방 높이 줄이기'},bagResizeHint={'Add/remove one row · 8 columns · Minimum 3 rows','세로 한 줄 조절 · 가로 8칸 · 최소 3줄'},bagWheel={'Mouse wheel: scroll','마우스 휠: 스크롤'},
 professionHint={'Crafting list · Search / learned filters · Spell learning · Materials in bags','제작 목록 · 분류/검색/습득 필터 · 주문 습득/삭제 · 실시간 재료 확인'},craftedItems={'Crafted items','제작 아이템'},
 menuCaption={'Menu','메뉴'},lockWindow={'Lock / unlock window movement','창 이동 잠금 / 해제'},spellQuery={'Spell name or ID','주문 이름 또는 ID'},spellInfo={'Spell information','주문 정보'},searchFilters={'Search / filters','검색 / 필터'},minLevel={'Min level','최소 레벨'},maxLevel={'Max level','최대 레벨'},learnLevel={'Learn level','습득 레벨'},baseTalent={'Base / talent','기본/특성'},castTime={'Cast','시전'},instant={'Instant','즉시'},range={'Range','사거리'},none={'None','없음'},currentRank={'Current learned rank','현재 습득 단계'},singleRank={'Single rank','단일 단계'},myClass={'My class','내 직업'},badLevels={'Enter a valid level range from 0 to 110.','레벨 범위를 0~110 사이로 입력하세요.'},
 category={'Category','분류'},advanced={'Advanced filters','상세 필터'},hideAdvanced={'Hide filters','상세 필터 접기'},itemHint={'Left click: quantity / add · Right click: server lookup · Mouse wheel: pages','왼쪽 클릭: 수량 지정 / 지급 · 오른쪽 클릭: 서버 조회 · 마우스 휠: 페이지'},currentFilter={'Current category','현재 분류'},sets={'Item sets','세트 아이템'},weapon={'Weapons','무기'},armor={'Armor','방어구'},consumable={'Consumables','소모품'},material={'Materials','재료'},recipe={'Recipes','조리법'},container={'Bags','가방'},other={'Other','기타'},
 travelHint={'Search / continent / category / faction · Click a header to sort · Right click: favorite','필터: 검색/대륙/분류/내 진영 · 머리글 클릭: 정렬 · 우클릭: 즐겨찾기'},allRegions={'All regions','전체 지역'},areaCity={'Zone / city','지역 · 도시'},myFaction={'My faction only','내 진영만'},mapFavorites={'Map favorites','지도 즐겨찾기'},type={'Type','유형'},recommendedLevel={'Recommended level','권장 레벨'},travelClick={'Left click a destination to teleport · Right click to toggle favorite','목적지 왼쪽 클릭: 순간이동 · 오른쪽 클릭: 즐겨찾기'},
 class1={'Warrior','전사'},class2={'Paladin','성기사'},class3={'Hunter','사냥꾼'},class4={'Rogue','도적'},class5={'Priest','사제'},class6={'Death Knight','죽음의 기사'},class7={'Shaman','주술사'},class8={'Mage','마법사'},class9={'Warlock','흑마법사'},class10={'Monk','수도사'},class11={'Druid','드루이드'},class12={'Demon Hunter','악마사냥꾼'},
 quality0={'Poor','하급'},quality1={'Common','일반'},quality2={'Uncommon','고급'},quality3={'Rare','희귀'},quality4={'Epic','영웅'},quality5={'Legendary','전설'},quality6={'Artifact','유물'},quality7={'Heirloom','계승품'},playerCount={'%d players','%d인'},
 skillTier1={'Apprentice','초급'},skillTier2={'Journeyman','수습'},skillTier3={'Expert','숙련'},skillTier4={'Artisan','전문'},skillTier5={'Master','대가'},skillTier6={'Grand Master','거장'},skillTier7={'Cataclysm','대격변'},skillTier8={'Pandaria','판다리아'},skillTier9={'Draenor','드레노어'},skillTier10={'Legion','군단'},
}
for k,v in pairs(browserLabels)do EN[k]=v[1];KO[k]=v[2]end
KO.commands='GM명령어(전체)';EN.commands='GM commands (all)'
EN.cheatHelp='Supported cheat commands';KO.cheatHelp='서버 치트 명령 확인'
EN.rightBinding='Right-click: key binding';KO.rightBinding='오른쪽 클릭: 단축키 설정'
EN.controlBags='Ctrl-click: unified bags';KO.controlBags='Ctrl+클릭: 통합 가방'
EN.alliance='Alliance';KO.alliance='얼라이언스';EN.horde='Horde';KO.horde='호드'
local bagLabels={
 bagSelect={'Select','선택'},bagSelecting={'Select…','선택 중'},bagSelectHint={'Select slots, then choose Sell or Destroy. Clicking a selected slot clears it.','아이템 칸 선택 후 판매 / 파괴 · 다시 클릭하면 선택 해제'},
 bagPin={'Pin items','아이템 고정'},bagPinning={'Pinning…','고정 설정 중'},bagPinHint={'Click an item to pin or unpin its position. Pinned items cannot be moved, used, sorted, sold or destroyed here.','아이템 클릭: 위치 고정 / 해제 · 고정한 아이템은 이동·사용·정렬·판매·파괴에서 제외'},bagPinned={'Pinned item. Use Pin items to unlock it.','고정된 아이템입니다. 아이템 고정 버튼으로 해제해 주세요.'},
 bagDestroy={'Destroy','파괴'},bagSell={'Sell','판매'},bagSort={'Sort','정렬'},close={'Close','닫기'},
 bagSellConditions={'Bulk sell · Conditions','일괄 판매 · 조건 선택'},bagDestroyConditions={'Bulk destroy · Conditions','일괄 파괴 · 조건 선택'},bagPreview={'Review items / Execute','대상 확인 / 실행'},
 bagquest={'Quest items','퀘스트 아이템'},bagconsumable={'Consumables / Healing','소모품 · 회복템'},
 bagFilterHint={'Match quality OR item type.\nQuest items are never sold. Pinned items are excluded.\nIn selection mode, only selected slots are processed.\nConditions are saved immediately.','품질 또는 종류에 해당하면 포함합니다.\n퀘스트템 판매 제외 · 고정 아이템 제외\n선택 모드에서는 선택한 칸만 처리합니다.\n선택 조건은 즉시 저장됩니다.'},
 bagNeedMerchant={'Open a merchant on the Buy tab to sell.','상인 거래창의 구입 탭에서 판매할 수 있습니다.'},bagNoMatches={'No eligible items match these conditions.','선택 조건에 해당하는 처리 가능한 아이템이 없습니다.'},bagBusy={'Finish the current item operation first.','현재 아이템 처리가 끝난 뒤 다시 눌러주세요.'},bagStopped={'Item processing stopped. Check the cursor and item positions.','아이템 처리를 중단했습니다. 커서와 아이템 위치를 확인해 주세요.'},
 bagConfirmSell={'Sell %s item stacks?\n%s','아이템 %s칸을 판매합니까?\n%s'},bagConfirmDestroy={'Permanently destroy %s item stacks? This cannot be undone.\n%s','아이템 %s칸을 영구 파괴합니까? 복구할 수 없습니다.\n%s'},bagProcessed={'Processed %d slots; skipped %d changed slots.','%d칸 처리 완료 · 변경된 %d칸 제외'},bagMore={'… and %d more slots','… 외 %d칸'},bagSelected={'Selected: %d','%d칸 선택'},
 bagQuestProtected={'Quest items cannot be sold from this bag.','퀘스트 아이템은 판매할 수 없습니다.'},bagSortHint={'Left click: sort by type, keeping pinned slots.\nRight click: toggle automatic sorting.','왼쪽 클릭: 종류별 정렬 · 고정 위치 유지\n오른쪽 클릭: 자동 정렬 켜기 / 끄기'},bagSorted={'Bags sorted by type. Pinned slots were kept.','종류별 정렬 완료 · 고정한 위치는 유지했습니다.'},bagAutoOn={'Automatic bag sorting: ON','가방 자동 정렬: 켜짐'},bagAutoOff={'Automatic bag sorting: OFF','가방 자동 정렬: 꺼짐'},bagSearchHint={'Type an item name. Escape clears the search.','아이템 이름 검색 · Esc: 검색어 지우기'},
}
for key,v in pairs(bagLabels)do EN[key]=v[1];KO[key]=v[2]end
local settingsLabels={
 settingsWindowScale={'Window size','창 크기'},settingsMiniScale={'Minibar size','미니바 크기'},
 settingsQuest={'Link quest helper to quest map','퀘스트 창에 도우미 연결'},settingsQuestHint={'Automatically show the helper when the quest map opens.','퀘스트 지도를 열 때 도우미를 자동으로 표시합니다.'},
 settingsCombat={'Hide GM windows during combat','전투 중 GM 창 숨기기'},settingsCombatHint={'Hide GM panels during combat and restore them afterwards. Minibar commands remain available.','전투 중 GM 창을 숨기고 종료 후 다시 표시합니다. 미니바 명령은 계속 사용할 수 있습니다.'},
 settingsLoot={'Automatically loot items','전리품 자동 획득'},settingsLootHint={'Uses the game auto-loot setting; changes apply immediately.','게임 기본 자동 루팅 설정과 연동하며 즉시 반영됩니다.'},
 settingsSort={'Automatically sort bags by type','가방 종류별 자동 정렬'},settingsSortHint={'Sort after inventory changes, preserving pinned slots. Waits while trading or moving items.','아이템 변경 후 고정 칸을 유지하며 종류별로 정렬합니다. 거래·아이템 이동 중에는 기다립니다.'},settingsSortNow={'Sort now','지금 정렬'},
 settingsBags={'Use unified bags','통합 가방 사용'},settingsBagsHint={'OFF restores Blizzard bag keys and merchant/bank bag behavior.','끄면 가방 단축키와 상인·은행 창에서 블리자드 기본 가방을 사용합니다.'},
 settingsSell={'Sell gray junk when visiting merchants','상인 방문 시 회색 잡템 자동 판매'},settingsSellHint={'Sell only gray items with vendor value. Pinned and quest items are excluded. Initially OFF.','판매가 있는 회색 아이템만 판매합니다. 고정·퀘스트 아이템은 제외합니다. 처음에는 꺼져 있습니다.'},
 settingsRestore={'Restore window positions','창 정위치 복원'},settingsImmediate={'Options are saved and applied immediately.\nLanguage changes require Reload UI.','옵션은 즉시 저장·적용됩니다.\n언어 변경 후에는 UI를 다시 불러오세요.'},languageReload={'Language saved. Reload UI to update all panels.','언어를 저장했습니다. UI를 다시 불러오면 모든 창에 반영됩니다.'},
 killSelect={'Select a living target other than yourself.','본인 이외의 살아 있는 대상을 선택하세요.'},killPending={'The target is still alive. Check the server reply and Die.Command.Mode setting.','대상이 아직 살아 있습니다. 서버 응답과 Die.Command.Mode 설정을 확인하세요.'},
}
for key,v in pairs(settingsLabels)do EN[key]=v[1];KO[key]=v[2]end
local questLabels={
 questFinding={'Looking up destination spawns on the server...','서버에서 대상의 배치 위치를 확인하고 있습니다.'},
 questLocationHint={'Move to the quest giver. Prefer the nearest location on the current map.','퀘스트 제공자에게 이동합니다. 현재 지도에서 가까운 위치를 우선합니다.'},
 questTravelCancelled={'Quest travel cancelled. Select the quest and try again.','이동이 취소되었습니다. 퀘스트를 선택하고 다시 눌러주세요.'},
 questSpawnMissing={'No spawn found. Check the server reply and GM permissions.','서버에서 배치 위치를 찾지 못했습니다. 서버 응답과 GM 권한을 확인하세요.'},
 questChooseDestination={'Choose a quest destination','퀘스트 이동 위치 선택'},
 questTravelling={'Moving to the quest destination...','퀘스트 대상 위치로 이동 중입니다.'},
 questArrived={'Arrived at the quest destination.','퀘스트 대상 위치에 도착했습니다.'},
 questArrivedNearby={'Arrived near the creature spawn (within 15 yards).','대상 배치 위치 근처에 도착했습니다. (15미터 이내)'},
 questArrivalUnknown={'Arrival not confirmed. Check the server reply.','도착을 확인하지 못했습니다. 서버 응답을 확인하세요.'},
 locationUnknown={'No location data for this quest/action. Item and automatic quests may have no giver.','이 퀘스트·동작의 위치 정보가 없습니다. 아이템·자동 퀘스트에는 제공자가 없을 수 있습니다.'},
 questObjectiveHint={'Find an unfinished objective: creature, object or item source. Choose when there are several objectives.','미완료 목표의 몬스터·오브젝트·아이템 출처로 이동합니다. 목표가 여럿이면 선택합니다.'},
 questChooseObjective={'Choose an unfinished objective','미완료 조건 선택'},
 questChooseSource={'Many item sources. Select a creature or object from the list.','출처가 많습니다. 목록에서 몬스터·오브젝트를 선택하세요.'},
 questObjectivesDone={'All visible objectives are complete. Use Quest end.','표시된 조건을 모두 완료했습니다. 종료 위치를 이용하세요.'},
 questObjectiveMissing={'No mapped location for this objective (event, currency or missing source data). Use the quest map.','이 조건의 이동 자료가 없습니다. 이벤트·화폐·미등록 출처는 퀘스트 지도를 확인하세요.'},
 questObjectiveMismatch={'Server objectives differ from the catalogue. No teleport was sent.','서버의 조건 목록이 자료와 달라 이동하지 않았습니다.'},
 questCreature={'Creature','몬스터'},questObject={'Object','오브젝트'},
}
for key,v in pairs(questLabels)do EN[key]=v[1];KO[key]=v[2]end
function A:L(key)
 local code=GMMLegionDB and GMMLegionDB.locale or 'auto';if code=='auto' then code=GetLocale() end
 return (self.locales[code] and self.locales[code][key]) or EN[key] or key
end
BINDING_HEADER_GMMLEGION='GM MINI BAR · Legion'
BINDING_NAME_GMMLEGION_BAGS=A:L('bags')
BINDING_NAME_GMMLEGION_MENU=A:L('menu')
