# v1.0.0 — Korean server reply compatibility

2026-10-12. Included in the v1.0.0 initial release. RC8/RC8.1 below identify the internal builds used to reproduce and verify the fix.

## 한국어

SPP의 `_SQL_Kor` 한글 패치를 적용하면 서버의 위치 조회 응답도 한글로 바뀝니다. RC8은 `MapId`만 인식해 실제 NPC/오브젝트가 검색되어도 좌표를 읽지 못했습니다. 조건 찾기, 시작 위치, 종료 위치가 이 공통 처리 경로를 사용합니다.

RC8.1은 영문 응답과 함께 `지도`, `(입장): 번호)` 및 `(입장: 번호)`, `발견된 생물`, `게임물들을 찾았다`를 처리합니다. 서버 응답 언어는 애드온 화면의 한국어/영어 설정과 별개로 인식합니다. 조회 종류와 대상 번호가 맞는 응답만 처리하며, 좌표 범위·중복·취소·도착 검사를 유지합니다.

설치 파일은 `GMminibar_SPP_Legion_7.3.5_v1.0.0.zip` 하나입니다. `Interface/AddOns/GMminibar`를 교체하고 `/reload`하거나 게임에 다시 접속합니다. `WTF`는 보존합니다. 한글 SQL을 되돌리거나 GM 권한·서버 설정을 변경할 필요가 없습니다.

2026-10-12, 한글 패치를 적용한 현재 PC에서 RC8의 실패를 재현했고 RC8.1로 퀘스트 27168의 조건 찾기·시작 위치·종료 위치가 모두 실제 NPC 앞으로 이동함을 확인했습니다. 진단 24/24, 이번 시험 세션 오류 0건입니다. 오브젝트 응답은 SQL 형식 그대로 모의 검사했습니다. 자세한 [게임 시험 기록](../GMminibar/GAME_TEST.md)에 실제 확인 범위와 시험 중 탐험 경험치 발생을 기록했습니다. 다른 사용자의 PC에서 성공했다는 뜻은 아닙니다.

## English

The SPP `_SQL_Kor` localization changes server lookup replies as well as game text. RC8 accepted only `MapId`, so valid localized spawn replies were discarded before Find Objective / Quest Start / Quest End could send a teleport.

RC8.1 accepts the English and supplied Korean field/terminator formats independently of the addon UI locale. Query-kind/entry matching, coordinate bounds, deduplication, cancellation and arrival checks remain in place. Unknown formats still stop without inventing a destination.

Replace the single `GMminibar` folder with the v1.0.0 installation ZIP and reload the UI. Preserve `WTF`. No SQL rollback, GM permission change or server restart is needed for this correction. Live checks on 2026-10-12 reproduced the old failure, then confirmed all three travel buttons for quest 27168, 24/24 diagnostics and zero current-session errors. Korean object replies are covered by exact SQL-template mocks, not a new live object test. See the separate game-test record for scope and the 376 exploration XP awarded during travel.

## Evidence

- `056_legion_world_trinity_string.sql`, SHA-256 `d04bccc971835d38cd2ab5e97b8055a118f347d6878640e33fcb1e97531e98ef`.
- Relevant `trinity_string.content_loc1` entries: **439, 441, 515, 517**.
- Tests use the four exact templates retained in `tests/fixtures/quest_server_strings_koKR.json`, with screenshot-derived example names/coordinates. They are reconstructed fixtures, not raw captured packets.
- The original parser failed the Korean object-row regression before the fix. English behavior and Korean replies are tested under both addon UI locales.
