# 실제 게임 테스트 / In-game checks

> v1.0.0 initial release / 최초 배포: the gameplay-tested RC8.1 implementation is retained; only version identifiers and distribution documentation were changed. Historical RC labels below preserve the actual test provenance. No new full gameplay test is claimed. / 실게임 시험한 RC8.1의 기능 코드를 유지하고 버전 표기와 배포 문서를 변경했습니다. 아래 RC 표기는 개발 시험 당시 기록이며 전체 기능을 새로 실게임 시험했다는 뜻이 아닙니다.

## RC8.1 한글 서버 응답 / Localized quest replies

2026-10-12 · **1.0.0-legion-rc8.1** · SPP Legion V2 Praevius 2026.2a, supplied `_SQL_Kor` localization, 32-bit koKR 7.3.5.26972 client.

기존 RC8에서는 **떠나지 못하는 자들(27168)**의 종료 위치를 눌러 한글 조회 응답을 받았지만, 배치 위치를 찾지 못했다는 안내와 함께 이동이 멈췄습니다. 같은 캐릭터에 RC8.1을 적용하고 UI를 다시 불러온 뒤 다음을 실제 게임에서 확인했습니다.

| 버튼 | 실제 이동 결과 | 서버 배치 번호 |
|---|---|---|
| 종료 위치 | High Priestess MacDonnell 앞으로 이동, 도착 확인 | NPC 11053 / GUID 137581 |
| 조건 찾기 | 홀로 떠도는 영혼(Withdrawn Soul) 앞으로 이동, 도착 확인 | NPC 45166 / GUID 366067 |
| 시작 위치 | High Priestess MacDonnell 앞으로 돌아옴, 도착 확인 | NPC 11053 / GUID 137581 |

- 게임 내 API 진단 **24/24**, 이번 시험 세션의 오류 **0건**. 누적 기록에 남아 있던 이전 오류 1건은 보존했습니다.
- 세 이동 모두 저장된 진단에서 `arrived`와 지도 0 / 실제 XY 이동을 확인했습니다. 이 클라이언트의 `UnitPosition` Z값은 0이므로 착지는 화면에서 별도로 확인했습니다.
- 레벨 59, 체력 10,368 및 표시된 퀘스트 진행 수치(0/12, 0/9, 0/5)는 그대로입니다. 퀘스트 완료·보상·전투·아이템 지급은 수행하지 않았습니다. 슬픔의 언덕 발견으로 탐험 경험치 **376**이 발생했습니다.
- 서리바람 야영지의 시험 전 좌표 `972.729797, -1456.330322, 63.015888`, 지도 0, 방향 `0.358288`로 복귀하고 서버 GPS 출력으로 확인했습니다. 마지막 UI 재로딩 후 정상 화면과 진단 24/24를 확인했습니다.
- SQL·서버 설정·계정 권한을 변경하지 않았습니다. 설치된 애드온의 세 실행 파일만 교체하여 시험했습니다.

**검증 범위:** 한국어/영어 UI에서 각각 **295개 모의 API 검사**, Lua **14개 문법 검사**를 통과했습니다. 실제 SQL의 네 응답 형식(439, 441, 515, 517)을 사용해 오브젝트 번호의 `(입장): 번호)` 형식과 제보된 죽음풀 퀘스트(24994) 흐름도 모의 검사했습니다. 이번 실게임 검증은 위 27168 퀘스트의 NPC 이동에 한정되며, 한글 응답으로 오브젝트 이동·모든 퀘스트·다른 사용자의 PC·파티 동작까지 확인했다는 뜻은 아닙니다.

**English:** The old RC8 End button failed with a Korean server reply on quest 27168. With the same logged-in character and RC8.1, End, Find Objective and Start each sent the server spawn teleport and reached the intended NPC; all three saved checks report `arrived`. Runtime diagnostics passed 24/24 with zero errors in this test session; one historical error remains. The original position was restored and checked with server GPS. No quest progress or server settings were changed; discovering Sorrow Hill awarded 376 exploration XP. Korean gameobject replies and the reported quest 24994 are covered by mock fixtures only. Previous RC8 results below remain historical.

## RC8 편의 기능 명령 수정 / Utility compatibility

2026-10-10 · **1.0.0-legion-rc8** · SPP 2026.2a · 7.3.5.26972 32비트 koKR. 원래 2열 편의 기능 배치와 단일 GMminibar 폴더를 유지했습니다.

실행 중인 서버에서 43개 명령 목록/도움말을 확인했습니다. 이 SPP에는 `.cheat explore`, `.explore`, `.maxskill`, `.unstuck`와 여러 `.learn all...` 하위 명령이 없습니다. 공개 코어의 명령이 현재 리팩에 그대로 있다고 가정하던 부분을 수정했습니다. 리스폰은 플레이어를 자동 선택하던 공통 처리 때문에 실패하므로 별도의 대상 처리로 분리했습니다.

| 실제 시험 | 관찰 결과 |
|---|---|
| 지도 개방 | 돌발톱 산맥 지도에서 왼쪽 클릭 후 미탐험 지도 그림/지명이 표시됨. 오른쪽 클릭 후 다시 열어 원래 가려진 모습 복원 확인. |
| 선택 리스폰 | 숲거미를 즉사 버튼 한 번으로 처치 → 시체를 선택해 ‘죽음’ 표시 확인 → 리스폰 오른쪽 클릭 → 살아 움직이는 숲거미와 생명력 2,212/2,212 확인. |
| 주변 리스폰 | 같은 시험 장소에서 숲거미를 다시 처치 → 시체 확인 → 리스폰 왼쪽 클릭 → 대상 해제 후 주변 숲거미 생명력 2,212/2,212와 전투 재개 확인. |
| 캐릭터 탈출 | `.start`로 고립 상태 벗어나기 시전 후 칼바람 광산에서 로르다넬 귀환 지점으로 실제 이동. |
| 주문 선택 | 40레벨 전사의 특성 주문 53개, 내 레벨 이하 직업 주문 127개 표시. 이번 시험에서는 추가 주문을 배우지 않음. |
| 전문기술/숙련 | 응급치료 75/75 표시. 이미 최대인 상태에서 숙련 최대는 불필요한 명령 없이 안내. 미습득 조리법 보기로 35개→32개 필터 확인. 실제 숙련 증가 시험과 구분. |
| 최종 진단 | API/자료 24/24. 시험 후 34.9 MiB, 재로딩 직후 약 37.0 MiB. 이번 시험 세션의 추가 오류 없음. 이전 Hide 차단 오류 1건은 누적 기록에 보존. |
| 복귀 | 칼바람 광산의 기록해 둔 원래 지도/좌표로 복귀. 40레벨·생존 상태 및 UI 재로딩 확인. |

지도 개방은 클라이언트에 있는 지도 그림을 표시하는 기능입니다. 서버의 탐험 완료·경험치·업적·비행 경로를 부여하지 않습니다. 111개 지도/1,521개 그림의 메타데이터를 포함하며 실제 지도 전수 검증은 아닙니다. 현재 지도만 해석하고 텍스처를 재사용합니다. 추가 MPQ나 클라이언트 파일 수정은 없습니다.

지원하지 않는 일괄 습득 버튼은 **GM 주문 검색(전체), 직업 주문 선택, 특성 주문 선택, 전문기술/조리법 선택**으로 연결했습니다. 이는 전체 자동 습득 기능이 아닙니다. 특성 주문을 배우는 것과 특성창에서 해당 특성을 선택·활성화하는 것도 다릅니다. 현재 클라이언트 자료의 GM 전용 분류는 비어 있으므로 임의의 GM 주문 목록을 만들지 않고 전체 주문 검색을 제공합니다. 숙련 최대는 이미 배운 기술의 현재 등급 한도만 사용합니다.

자기 자신에게만 적용되는 SPP 명령은 다른 사람 적용으로 오인하지 않게 안내합니다. 다른 플레이어의 레벨 변경은 `.levelup 이름 증감값` 순서를 사용합니다. 일반 기능의 왼쪽 본인/오른쪽 대상·이름 입력은 유지합니다. 리스폰은 왼쪽 주변/오른쪽 선택한 죽은 몬스터이고, 이름으로 시체를 조회하지 않습니다. 서버 응답은 화면에 표시하며, 요청 전송만으로 성공했다고 표시하지 않습니다.

숲거미 두 번 처치/리스폰과 앞선 크롬가르 일꾼 즉사 요청을 실행했습니다. 일꾼은 선택이 풀려 사망 전후 비교가 불충분하므로 성공 근거로 사용하지 않았습니다. 아이템 지급·판매·파괴, 주문/등급 습득, 퀘스트 완료·보상, 레벨/GM·무적·비행 상태 변경, 계정·서버 설정·DB 수정 및 서버/게임 프로세스 재시작은 하지 않았습니다. 시험 이동/처치에 따른 경험치 변화량은 측정하지 않았습니다. 캐릭터 위치와 지도 표시 OFF를 복원했습니다.

SavedVariables의 RC8 기록은 오른쪽 리스폰 전에 실제 Creature GUID와 사망 상태를 기록했습니다. 서버가 리스폰 때 대상을 다시 생성해 선택이 풀리므로 자동 상태는 `sent`로 남아 있습니다. 이 기록을 성공 응답으로 바꾸지 않았고, 실제 사망/생존 화면을 결과 증거로 사용했습니다. 화면 35–49는 로컬 QA 자료로만 보관하며 설치 ZIP에 포함하지 않습니다.

Lua 5.1 파일 14개와 한국어/영어 각각 270개 모의 동작 검사가 통과했습니다. 모의 검사는 실제 게임 테스트와 별도입니다. 모든 지도, 모든 명령과 대상 조합, 오브젝트 리스폰, 파티 기능은 게임 내 전수 검증하지 않았습니다.

RC8 live checks verified Stonetalon map artwork ON/OFF, dead-to-alive selected and nearby Forest Spider respawn, one-click kill, actual unstuck travel, class/talent pickers, recipe filtering, the already-max skill no-op and return to the original position. Diagnostics passed 24/24 with no new errors in the tested UI session. Bulk learning is replaced by explicit selection, and map artwork does not grant exploration credit. Other command combinations, all maps and multiplayer remain outside full acceptance. Earlier sections below are historical tests.

## RC7 조건 찾기 / Find objective

2026-10-10 · **1.0.0-legion-rc7**. 사용자 PC의 SPP 2026.2a와 7.3.5.26972 32비트 koKR 클라이언트에서 확인했습니다.

RC6에는 목표 관계 자료와 실행 경로가 없어 조건 찾기가 비활성 상태로 남아 있었습니다. RC7은 공개 군단 자료의 퀘스트 17,822개·목표 28,061개를 추가하고, 현재 퀘스트의 미완료 조건을 실제 목표 NPC/오브젝트/아이템 획득처와 연결합니다. 수집 퀘스트는 아이템 ID를 NPC ID로 취급하지 않고 전리품·상인·오브젝트 관계를 따라갑니다. 아이템 목표 ID 7,632개 중 4,513개에 공개 획득처 관계가 있습니다. 이 수치는 실제 서버 전체 동작 보장을 뜻하지 않습니다.

실행 시 서버의 `.list creature`/`.list object` 응답에서 실제 스폰 GUID를 읽고 `.go creature`/`.go object`로 이동합니다. 오브젝트 응답의 `Entry:`를 Y좌표로 잘못 읽던 경계 검사도 수정했습니다. 여러 미완료 목표는 선택 목록을 표시하며, 획득처가 8개보다 많으면 먼저 출처를 선택합니다. 현재 지도에서 가까운 실제 배치를 우선하고 완료한 조건은 건너뜁니다. 누락·공개 자료 불일치·서버 조회 실패는 안내 후 중단합니다.

| 실제 시험 | 관찰 결과 |
|---|---|
| 해방의 날 24575 → 조건 찾기 | 족쇄 오브젝트 201775의 서버 배치 47115로 이동. 사로잡힌 주민 옆 족쇄 위치와 지면 접촉을 화면으로 확인. |
| 마지막 식사 24675 → 조건 찾기 | 퀘스트 아이템 50219의 획득처인 사슴 NPC 37786, 서버 배치 148903으로 이동. 실제 지면 접촉 확인. |
| 이동하는 NPC 도착 판정 | 최종 사슴 이동은 조회 좌표에서 약 12.6야드 떨어진 위치. 실제 이동 후 15야드 이내인 NPC는 “근처 도착”으로 구분하고, 이동하지 않은 실패 요청은 이 판정에서 제외. 오브젝트는 6야드 기준 유지. |
| 마지막 식사 → 종료 위치 | 마그다 화이트월 NPC 38143, 배치 149658 옆으로 복귀. |
| 목표 이동 후 전투·Escape | 해방의 날 목표 이동을 반복한 뒤 실제 전투 상태에서 지도/도우미 닫힘과 추가 Escape 입력 확인. 수정 후 마지막 UI 세션의 차단 오류 0건. |
| 최종 상태 | 17레벨 유지, 퀘스트 진행 0/5·0/10 유지. 원래 전초기지로 복귀 후 UI 재로딩. |
| 검사 | 실제 API·자료 진단 24/24, 메모리 약 36.9 MiB. Lua 14개 문법 및 한국어·영어 각각 232개 모의 검사 통과. |

누적 오류에는 `ADDON_ACTION_BLOCKED: GMMLegionQuests:Hide()` 한 건이 남아 있습니다. 최초 발생 시점은 확정하지 못했으며 기록을 지우지 않았습니다. 보호된 퀘스트 도우미를 일반 Escape 닫기 목록에서 제외하고 전투 여부를 검사하는 지도 닫기 경로를 사용하도록 수정했습니다. 그 뒤 목표 이동·전투·Escape를 재검증한 마지막 세션에서는 추가 차단 오류가 기록되지 않았습니다.

이 군단 클라이언트의 UnitPosition Z는 0으로 반환됩니다. 지도/XY 도착 검사와 화면으로 확인한 지면 상태는 별도 증거입니다. 스크립트 이벤트·화폐·평판·지역 도달처럼 연결된 이동 대상이 없는 목표, 서버 고유 퀘스트, 모든 위상·획득처는 전수 검증하지 않았습니다. 다중 목표/출처 선택과 파티 이동은 모의 검사까지만 확인했습니다. 일반 `.go quest`는 계속 사용하지 않습니다.

조건 완료·보상 수령·목표 NPC 처치·아이템 지급/삭제는 실행하지 않았습니다. 목표 근처의 적에게 잠깐 공격받았고 전초기지 복귀 후 자연 회복했습니다. 계정 권한·GM/무적/비행 상태·서버 설정·DB 변경, 서버/게임 프로세스 재시작은 없었습니다.

RC7 live checks cover object objective 24575, item-source objective 24675, ground contact, nearby-arrival reporting, return to the turn-in NPC, combat/Escape behavior and UI reload. Diagnostics passed 24/24. One historical blocked Hide error is preserved; the final test session after the Escape-path fix recorded no new errors. Public catalog coverage and 232 mocked contracts per language are separate from game acceptance. Other quests and multiplayer remain unverified. Previous release sections below describe historical tests.

## RC6 퀘스트 시작·종료 위치 / Quest giver travel

2026-10-10 · **1.0.0-legion-rc6**. 사용자 PC의 SPP 2026.2a와 7.3.5.26972 32비트 koKR 클라이언트에서 버튼을 직접 눌러 확인했습니다.

RC5에는 위치 연결 자료가 없어 시작·종료 버튼이 꺼져 있었습니다. RC6는 공식 AshamaneProject ADB_735.10에서 퀘스트 22,353개의 제공자 관계를 추출했습니다(시작 15,455개, 완료 22,198개). 원본 좌표나 다른 서버의 스폰 GUID를 고정하지 않습니다. 실행 중인 SPP에 `.list creature`/`.list object`로 배치를 요청하고, 응답에 있는 실제 GUID로 `.go creature`/`.go object`를 보냅니다. 현재 지도에서 가까운 후보를 우선하고, 여러 후보가 모두 다른 지도에 있으면 선택 창을 엽니다. 누락·응답 실패 시 임의 좌표로 이동하지 않습니다.

| 실제 시험 | 결과 |
|---|---|
| 상업 지구에서의 철수 14098: 시작 위치 | 리암 그레이메인(34913), 실제 스폰 149782로 이동. 없는 대체 NPC 35830은 건너뜀. |
| 상업 지구에서의 철수 14098: 종료 위치 | 동일 퀘스트의 완료 NPC 위치로 이동하고 도착 문구 표시. |
| 엄청난 혼란 14093: 종료 위치 | 노스렌드(map 571)의 별도 후보가 조회되어도 길니아스(map 654)의 리암 선택. |
| 걸어서 떨어진 뒤 종료 위치 버튼 | NPC에서 떨어진 시장 안쪽에서 버튼을 눌러 NPC로 복귀. 저장된 이동 전후 XY 변화와 화면 확인. |
| 지면·상태 | NPC 위치의 지면에 서 있음. 퀘스트 목표 진행은 0/6, 0/3으로 유지. 레벨 2 유지. |
| 도착 판정 | 이 클라이언트는 UnitPosition의 Z를 0으로 반환함. 서버 NPC 높이 35.556으로 이동하며, 애드온은 지도/XY로 도착 확인. 높이 자체는 화면으로 검증. |
| 진단·정적 검사 | 실제 진단 23/23, 기록된 오류 0건. 초기 메모리 약 33.2 MiB. Lua 14개 문법, 한국어·영어 각각 196개 모의 동작 검사 통과. |

파티원 적용은 시작·종료 버튼 모두에 연결했고 도착 후 연결 상태·GUID가 같은 파티원만 소환합니다. 실제 다중 캐릭터 및 오브젝트 제공자 이동은 미검증이며 모의 검사와 구분합니다. 전체 퀘스트와 위상별 NPC를 전수 시험한 것은 아닙니다. 아이템·자동·서버 고유 퀘스트는 제공자 자료나 실제 배치가 없을 수 있습니다. 일반 `.go quest`를 사용하는 조건 찾기는 계속 꺼져 있습니다.

테스트 중 퀘스트 완료·보상·아이템 지급·삭제, 계정·서버 설정·월드 DB 변경은 하지 않았습니다. 서버/클라이언트 프로세스 재시작 없이 UI만 다시 불러왔습니다.

RC6 live evidence covers start/end controls, server GUID resolution, same-map preference, a walk-away/return teleport and ground contact for quests 14098/14093. All-quest, phase and multiplayer behavior is not fully game-tested. See the separate mocked validation for timeout, cancellation, object routing and party guards. Previous release results below are historical.

## RC5 설정·즉사·전투 단축키 / RC5 settings and combat commands

2026-10-10 · **1.0.0-legion-rc5**, 실제 7.3.5.26972 32비트 한국어 클라이언트와 SPP 2026.2a에서 확인했습니다. 서버/게임 프로세스는 재시작하지 않았습니다.

| 항목 / Check | 실제 결과 / Observed result |
|---|---|
| 설정 화면 | 언어, 창/미니바 크기, 퀘스트 연결, 전투 중 창 숨김, 자동 전리품, 자동 정렬, 통합 가방, 회색 잡템 자동 판매, 창 위치 복원 표시. 1026×813 화면에 모두 보임. |
| 자동 전리품 | 체크 ON/OFF가 클라이언트 설정에 반영됨. 시험 후 원래 OFF 복원. |
| 통합 가방 | 설정 OFF 후 B 키로 블리자드 기본 가방이 열림. 시험 후 ON 복원. |
| 크기와 저장 | 100→95% 클릭 즉시 GM 창 축소. UI 다시 불러온 뒤 설정 화면과 SavedVariables 모두 95% 확인. 최종 100% 복원. |
| 퀘스트 연결 | ON 상태에서 L로 지도를 열면 도우미가 표시되고 같이 닫힘. OFF에서는 지도만 열림. OFF 저장·재로딩 확인 뒤 ON 복원. |
| 전투 중 숨김 | 전투 시작 시 이미 열려 있던 GM 창만 숨고 미니바는 유지됨. 전투 종료 시 GM 창 복원. |
| 즉사 단축키 | 전투 중 Ctrl+Shift+F12를 한 번 눌러 공격대 훈련용 허수아비 처치 메시지 확인. 일반 실버문 순찰자도 버튼 한 번 클릭 후 시체 확인. 저장된 `.die` 요청은 정확히 두 번. |
| 전투 중 다른 명령 | 비행 ON/OFF와 GM 모드 ON의 자동 본인 선택 및 서버 응답 확인. 전체 슬롯/키 조합을 모두 실행한 것은 아님. |
| 부활 | 사망한 본인에게 미니바 부활을 실행해 살아나는 것 확인. |
| 서버 설정 | `Die.Command.Mode` 0→1. `.reload config`에 “World config settings reloaded.” 응답 확인. 애드온 ZIP에는 서버 설정 파일이 없음. |
| 진단 | 최종 22/22, 초기 29.9 MiB, 전투 검증 뒤 28.2 MiB. 저장된 오류/차단 기록 0건. 시험용 키 해제 확인. |

Lua 5.1 문법 14개 및 한국어·영어 각각 **167개 모의 API 동작 검사**를 통과했습니다. 자동 판매의 회색 품질 제한·고정/퀘스트 제외·상인 종료/전투 중단·자료 재시도 제한은 모의 검사로 확인했으며 **실제 자동 판매는 실행하지 않았습니다**. 기본 자동 판매는 OFF입니다. 전투 중 창 열기·배치/옵션 변경·단축키 재지정은 제한되며 미니바의 사전 지정 명령 실행과 구분합니다.

시험 준비 중 `.go creature id 31146`이 기존 실버문 훈련용 허수아비를 선택했고, 보호 설정 전에 1레벨 캐릭터가 경비병에게 한 번 사망했습니다. 이후 부활·무적 보호 아래 시험하고 장비를 수리했습니다. `.recall`로 원래 GM 섬 위치에 복귀했으며 시험용 GM/무적/비행·키를 해제했습니다. 레벨은 1을 유지했지만 지역 발견 경험치 55와 ‘명예로운 메달’ 능력/업적 안내가 발생했습니다. 해당 진행 기록은 임의로 되돌리지 않았습니다. NPC 영구 생성, 아이템 지급·판매·파괴, 계정 권한 변경은 하지 않았습니다.

RC5 was directly tested for settings application and reload persistence, secure combat visibility, one-key/one-click kill, flight/GM commands, and dead self resurrection. Tests used existing creatures; the private server does not support the upstream temporary-spawn command. One preparation death was recovered by resurrection and repair; the character returned to the original GM island position at level one. Exploration XP and the observed ability/achievement were retained. Automatic junk sale and every combat shortcut remain outside live acceptance. Earlier release results below are historical.

2026-10-10 · GM MINI BAR 1.0.0-legion-rc4 · SPP 2026.2a

사용자가 접속한 Legion 7.3.5 build 26972, Interface 70300, **32비트 koKR 클라이언트**를 PC 제어로 직접 조작했습니다. 아래 결과는 이 환경과 테스트한 기능에 한정됩니다. 전체 기능 완료 판정은 아닙니다.

The user's running 32-bit build 26972 client was controlled directly. These results cover the listed operations on this SPP instance; they are not full acceptance of every feature or destination.

## 이전 RC4 기존 통합 가방 구성 복원 / RC4 bag controls

기존 리치왕 가방 소스의 화면과 동작을 기준으로 선택·높이 조절·파괴·정렬·판매 도구줄, 하단 검색·아이템 고정·빈칸·소지금·장착 가방 4칸을 연결했습니다. 품질/종류 조건과 실행 전 목록 확인, 캐릭터별 위치 고정, 고정 칸을 보존하는 정렬을 추가했습니다. 기본 가방 단축키(B 및 전체 가방 키)는 통합 가방을 엽니다. 블리자드 전역 가방 함수는 교체하지 않습니다.

아이템 버튼은 군단 `ContainerFrameItemButtonTemplate`의 원래 클릭·드래그 처리를 사용합니다. 장착 우선인 보안 `item` 액션만으로 모든 상황을 처리하던 RC3 방식은 교체했습니다. 일반 Lua 콜백에서 물약을 `UseContainerItem`으로 사용하지 않습니다.

| 항목 / Check | 실제 결과 / Observed result |
|---|---|
| 전체 배치 / Layout | 1920×1034 게임 창에서 8열·4줄, 선택·높이·파괴·정렬·판매·잠금, 검색·고정·빈칸 30/32·소지금·장착 4칸 표시. 기본 검정/금색 칸의 불필요한 파란 오버레이 제거 확인. |
| 단축키 / Binding | UI 새로고침 후 B 키로 통합 가방 열기 확인. |
| 고정 / Pins | 첫 칸 귀환석 고정 표시, 고정 모드 종료 후 유지, 오른쪽 클릭 사용 차단 안내 확인. 시험 후 고정 해제. |
| 물약 / Potion | 118 물약 2개 생성 후 오른쪽 클릭. 회복 효과와 수량 2→1 확인. 애드온 차단 경고 없음. |
| 선택과 확인 / Selection and preview | 물약 체크와 선택 1개 표시. 소모품 조건의 파괴 미리보기에 물약 1개만 표시. 취소 후 아이템 유지. 실제 파괴는 실행하지 않음. |
| 정렬 / Sorting | 자동 정렬을 끄고 물약을 8번째 칸으로 옮긴 뒤 수동 정렬해 2번째 칸 복귀. 고정한 첫 칸 귀환석 유지. 자동 정렬 복구 및 같은 재정렬 동작 확인. |
| 조건 창 / Conditions | 품질 색상, 퀘스트 아이템/소모품 구분, 기본 회색 품질 체크 표시. UI 새로고침 뒤 퀘스트 라벨 수정 반영 확인. |
| 저장·진단 / Persistence and diagnostics | 저장 자료에서 RC4, 22/22, 초기 29.9 MiB, 기록된 오류 0건, 가방 4줄, 자동 정렬 ON, 시험 고정 0개 확인. |

게임 내 일괄 판매·파괴의 실제 실행, Shift+클릭/드래그 제스처, 은행·우편 전송과 전투 중 사용은 확인하지 않았습니다. 133개 모의 API 검사(언어별)는 고정/선택/품질 판정, 스택 변경 후 실행 중단, 상인 종료·커서·전투 방어, 판매/파괴 큐, 특수 가방 정렬과 시간 제한을 다룹니다. 모의 실행은 게임에서 아이템이 실제 판매·삭제되었다는 증거가 아닙니다.

시험용 물약 2개 중 1개를 사용해 1개가 남았습니다. 판매·파괴한 아이템은 없습니다. 고정 시험을 해제하고 조건은 회색 품질만, 자동 정렬은 켜짐으로 복원했습니다. 캐릭터 위치·레벨·퀘스트와 서버/클라이언트 프로세스는 유지했으며 UI만 다시 불러왔습니다.

RC4 was tested through the actual Korean client: toolbar/footer, B binding, pin protection, potion use, selection, destruction preview/cancel, pinned manual/automatic sorting and persisted settings. Actual bulk sale/destruction, modifier/drag gestures and service transfers remain unverified in game. No items were sold or destroyed. Earlier release results below are historical and are not claimed as repeated RC4 acceptance.

## 이전 RC3 통합 가방 수정 및 실제 확인 / Earlier RC3 bag fixes

고정 64칸 높이 때문에 생기던 빈 공간을 없애고 기존 방식의 가로 8칸·36px 아이콘·높이 조절·행 스크롤로 바꿨습니다. 검색과 소지금은 하단, 장착 가방 4칸은 번호·용량·빈칸 아이콘과 함께 표시합니다. Shift+클릭은 채팅 링크가 실제로 처리되지 않은 경우 수량 나누기로 이어지며, 군단의 전역 `OpenStackSplitFrame`을 호출하도록 수정했습니다.

| 항목 / Check | 실제 결과 / Observed result |
|---|---|
| 배치 / Layout | 1026×813 게임 창에서 기본 3줄, 4줄로 확대·다시 축소, 하단 검색·소지금·장착칸 전체 표시 확인. |
| 스크롤 / Scrolling | 마우스 휠로 한 줄 이동하여 숨겨진 마지막 가방칸 접근. 위·아래 버튼 상태와 첫 줄 복귀 확인. |
| 검색·사용 / Search and use | 치유 물약만 검색한 상태에서 오른쪽 클릭. 실제 회복 효과, 물약 소멸, 검색 결과 0건, 빈칸 24→25 확인. 애드온 차단 경고 없음. |
| 이동·정렬 / Move and sort | 귀환석을 첫 칸에서 둘째 칸으로 두 번 클릭해 이동. 정렬 버튼으로 첫 칸 복귀 확인. |
| 가방 열기 / Open equipped bag | 하단 1번 장착 가방 클릭 시 블리자드의 해당 6칸 가방이 열리고 기존 장착 상태는 유지됨. |
| 추가 가방 장착 / Equip another bag | 시험용 4496 가방 1개를 지급하고 통합 가방에서 집어 하단 빈 2번 칸 클릭. 전체 26→32칸, 빈칸 31/32, 장착 가방 1·2번 각각 6칸 표시 확인. |

시험 후 UI를 다시 불러와 저장된 진단 오류 0건, 진단 22/22, 초기 메모리 29.8 MiB, 가방 높이 4줄 유지까지 확인했습니다.

RC3 시험에서 물약 1개를 사용했고 6칸 가방 1개를 추가 장착했습니다. 캐릭터의 위치·레벨·기존 퀘스트는 바꾸지 않았습니다. 높이는 4줄로 남겨 32칸이 모두 보이도록 했습니다.

Shift+클릭 수량 나누기와 64칸 초과 탐색, 전투 중 보안 버튼 재연결 금지는 자동 검사로 검증했습니다. 이번 PC 제어에서는 Shift+마우스 클릭을 직접 수행하지 못했고, 드래그 입력으로 가방을 꺼내는 동작도 성공 확인에 이르지 못했습니다. 위 장착과 아이템 이동은 집기·놓기 클릭 방식으로 확인한 결과입니다. 전투 중 아이템 사용은 재검증하지 않았습니다.

Automated checks cover 100 contracts per locale and 14 Lua syntax files. The live checks above cover the actual compact bag UI, filtered potion use, click-based item movement, sorting and bag equipment. Shift-click and drag gestures are not claimed as live-verified.

## 이전 RC2에서 직접 확인 / Earlier direct RC2 checks

| 항목 / Check | 실제 결과 / Observed result |
|---|---|
| 메뉴와 창 / Menu and windows | 기존 리치왕형 검정·금색 패널, 붙어 있는 비활성 메뉴 제목, 톱니바퀴 설정, 2열 편의 기능 확인. 1026×813 및 1920×1035 게임 창에서 메뉴·검색·목록·페이지 버튼이 화면 안에 표시됨. |
| 주문 분류 / Spell classification | 전사 147건. 필사의 일격 12294 검색 성공. 습득 주문 제외 선택 시 147→140건. 전문화·특성 관계를 포함하는 새 분류 자료가 실제 클라이언트에서 로드됨. |
| 주문 습득·취소 / Learn and unlearn | 12294 습득 클릭 시 본인 자동 선택, 서버의 새 능력 습득 메시지, 파란색 습득 표시·배우기 비활성 확인. 습득 취소 후 미습득 상태·배우기 활성·취소 비활성으로 복귀. |
| 아이템 목록 / Item browser | 전체 103,892건, 기본 2열 20개/5,195페이지, 상세 필터 16개/6,494페이지. 분류 트리·품질·레벨 필터와 목록이 겹치지 않음. |
| 아이템 지급 / Add item | ID 118 검색, 수량 창에서 1개 지급. 본인 자동 선택과 서버 생성 메시지 확인. 이번에 추가한 물약은 사용하지 않음. |
| 순간이동 표 / Travel browser | 전체·지역·도시·던전·공격대·전장 6개 탭, 대륙·지역/도시·목적지·유형·권장 레벨·진영 표시. 공격대 97건/6페이지와 난이도·인원수 표시. 레벨 열 클릭으로 110→100 내림차순 전환 확인. |
| 전문기술 / Professions | 응급치료 75/75, 초급 완료·수습 습득 활성·이후 등급 비활성. 습득만 필터에서 레시피 3275·3276·3277 표시. 최종 작은 창에서 검색 버튼이 패널 뒤에 가려지지 않음. |
| 진단 / Diagnostics | 최종 Lua 재설치·UI 새로고침 후 22/22 API/data checks. 초기 메모리 약 29.8 MiB. 저장된 진단 오류 목록은 비어 있었음. |

RC2는 RC1의 `Data/Travel.lua` 좌표를 변경하지 않습니다. 이 파일의 SHA-256은 `ade827730b8a51ab4c576db3cd2a8a25d1036ce6dd7a6a45ca269a634cf0c746`입니다. RC2에서는 순간이동 목록·분류·정렬을 확인했으며, RC1의 착지 시험을 전체 재실행하지 않았습니다.

RC2 data and UI checks cover the visible browser, real spell learning/unlearning and item creation. Travel coordinates remain byte-identical to RC1; no complete landing retest was performed. Korean and English mock checks are separate from the Korean gameplay observations.

이번 RC2 시험에서 임시로 배운 필사의 일격은 다시 취소했습니다. 물약 1개는 남아 있습니다. 사용자 조작으로 바뀐 캐릭터 위치와 레벨은 되돌리지 않았으며, 최종 화면은 스톰윈드에서 확인했습니다. 서버·클라이언트를 재시작하거나 계정 권한을 변경하지 않았습니다.

## RC1에서 확인한 결과 / Earlier RC1 observations

아래 항목은 앞선 RC1 실제 시험 기록입니다. RC2에서 모두 반복 확인한 것으로 해석하지 마세요.

| 항목 / Check | 실제 결과 / Observed result |
|---|---|
| GM 권한 / Permissions | 기존 계정 권한 3 확인. `.account`도 3 반환. 비밀번호·계정 권한 변경 없이 미니바에서 GM 모드 ON 확인. |
| 기본 진단 / Diagnostics | 19/19 API/data checks; initial addon memory about 26.1 MiB. Saved diagnostic errors and blocked-action records were empty after the exercised operations and reload. |
| 레벨 / Level | 편의 기능 버튼으로 1→2→1. 원래 레벨 복구. |
| 전문기술 / Professions | 응급치료 1/75 습득→숙련 최대 75/75. 배운 단계 비활성, 다음 단계 활성, 이후 단계 비활성 확인. |
| 주문 / Spells | NPC 선택 상태에서 레시피 3276 습득 시 본인 자동 선택. 갱신 수정 후 3277 습득 즉시 녹색·습득 완료·배우기 비활성 확인. 습득 제외 필터는 0건 표시. |
| 아이템 / Items | 118 물약 및 4496 6칸 가방을 ID 검색하여 각 1개 지급. 서버 생성 메시지 확인. |
| 물약 / Potion use | 통합 가방에서 118 오른쪽 클릭 사용, 아이콘 소멸·빈칸 증가. 애드온 차단 경고 없음. |
| 가방 장착 / Bag equipment | 통합 가방의 4496을 집어 하단 첫 장착칸에 놓음. 총 20→26칸, 빈칸 25 확인. 네 장착칸 표시. 드래그 자동화 제스처는 검증하지 못했으며 두 번 클릭 방식으로 확인. |
| 비행 / Flight | 미니바에서 ON/OFF 서버 응답 확인. 착지 테스트 중 OFF 유지. |
| GM 섬 / GM Island | 실제 이동 및 지면 위 캐릭터 확인. |
| 던전 / Dungeon | 아즈샤라의 눈 외부 입구 이동. 화면상 지면 위 캐릭터, 서버 `.gps` FloorZ 4.201206 확인. |
| 난이도 / Difficulty | 아즈샤라의 눈 영웅 항목에서 서버 변경 응답과 이동 요청 확인. 일반 항목으로 다시 변경하여 복구. 실제 인스턴스 입장은 테스트하지 않음. |
| 비행 지점 / Flight node | TaxiNodes 1870 도착. 라젠 스윙블레이드(비행 조련사) 옆, 서버 FloorZ 17.553398 / GetPositionZH 17.554174 확인. 처음에는 천막이 카메라를 가렸고 시야 변경 후 NPC·캐릭터 확인. |
| 창 / Windows | 가방·설정·편의 기능 겹침 수정 후 앞 창이 제대로 가림. 작은 화면에서 퀘스트 도우미 제목·파티 체크칸·버튼 전체 표시. |
| 언어 / Language | 영문 미니바·편의 기능·순간이동·퀘스트 도우미 확인 후 한국어로 복구. |
| 퀘스트 / Quest | 선택 퀘스트 14078 인식. 서버 `.go quest 14078`은 지형 밖 이동이 관찰됨. 이전 위치 복귀 성공. 최종 수정본은 미검증 퀘스트 이동을 비활성화하며, 한국어 화면에서 확인. 조건 완료는 기존 퀘스트 진행을 바꾸지 않도록 실행하지 않음. |

테스트에서 수정한 문제: `NEW_RECIPE_LEARNED` 처리 및 선택 주문 갱신, 창 전면 표시 순서, 화면 크기 변경 대응, 저장 아이콘, 미니바 손잡이, 작은 지도에서 퀘스트 도우미 가림, 저장된 언어 선택 표시, 미검증 퀘스트 좌표 실행 방지.

Fixes prompted by these checks: recipe events and selected detail refresh; window levels and resizing; save icon and grip; quest-helper placement; stored language selection; prevention of unverified quest movement.

## 미완성 및 미검증 / Remaining scope

- 여관 및 퀘스트 조건·시작·종료 위치 자료는 미포함. SPP 월드 DB 읽기 권한이 필요하며, 권한 우회·DB 계정 초기화는 하지 않았습니다. 퀘스트 이동 버튼은 확인된 좌표가 있을 때만 활성화합니다.
- 전체 833개 이동 항목, 모든 전문기술 단계·명령, 사망 부활, 전투 중 아이템 사용/차단, 탈것 상태 착지, 파티원 동시 처리 및 다른 캐릭터 대상 적용은 전부 테스트한 것이 아닙니다.
- 일반 `.go quest`에 대한 호환 문제는 애드온에서 무조건 실행하지 않도록 처리했으며, 서버 자체 좌표 처리를 고친 것은 아닙니다.
- No innkeeper or quest location database is bundled. Complete destination coverage, mounted/combat use, all profession ranks, dead resurrection and multiplayer actions remain unverified. The server's generic quest teleport is no longer invoked; its server-side coordinate logic was not repaired.

앞선 RC1 시험 종료 당시 캐릭터는 기존 위치와 레벨 1로 복귀했고, GM ON·비행 OFF·던전 일반·애드온 한국어 상태였습니다. RC1에서 배운 응급치료 75/75와 레시피 3276·3277, 장착한 6칸 가방은 남겨 두었으며 당시 지급한 물약 1개는 사용했습니다. 기존 퀘스트는 완료·삭제하지 않았습니다. 이는 현재 캐릭터 상태를 고정하여 설명하는 문장이 아닙니다.

RC2 Lua 5.1 정적 검사: 14개 파일, 한국어·영어 각각 84개 모의 API 계약 검사 통과. 직업 주문·던전 전리품 관계, 2,000건 이후 검색, 표 정렬, 실제 상위 지역 관계, 버튼 대상 지정 및 패널 경계를 포함합니다. `VALIDATION.json`의 `inGameVerified: false`는 해당 자동 검사가 실제 게임 검사가 아니라는 뜻입니다. 게임 결과는 이 문서와 `GAME_TEST.json`에서 별도로 기록합니다.
