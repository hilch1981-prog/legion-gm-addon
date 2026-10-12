# GM MINI BAR — Legion / SPP v1.0.0

## 한국어

군단 **7.3.5 (26972), Interface 70300 / SPP Legion V2 Praevius 2026.2a**용 최초 배포본입니다. 현재 완성된 소스를 v1.0.0 기준으로 등록했습니다.

- 기존 GM MINI BAR 화면 구성, GM 편의 기능, 주문·아이템 검색, 전문기술, 통합 가방과 장착 가방 4칸, 순간이동, 퀘스트 도우미를 포함합니다.
- 한글 DB 적용 후 **조건 찾기·시작 위치·종료 위치**가 멈추던 서버 응답 해석 문제를 수정했습니다. 한글·영문 응답을 애드온 UI 언어와 별개로 처리합니다.
- 한국어/영어 UI와 언어 전환 설명서를 제공합니다. README에 실제 군단 스크린샷과 각 클라이언트 버전별 저장소 링크가 있습니다.
- 설치 파일은 **GMminibar_SPP_Legion_7.3.5_v1.0.0.zip 하나**입니다. 압축 안의 `GMminibar` 폴더를 `Interface/AddOns`에 넣으세요. 기존 설치는 폴더를 교체하고 `WTF` 설정은 보존하세요. 추가 MPQ·DLL·SQL은 필요하지 않습니다.

**검증:** Lua 14개 문법 검사, 한국어·영어 각각 295개 모의 API 검사 통과. 기능 코드가 같은 개발 시험본에서 한글 클라이언트+한글 DB의 퀘스트 27168 조건 찾기·시작·종료 이동, 진단 24/24 및 해당 시험 세션 오류 0건을 확인했습니다. 배포판은 버전 표기와 문서를 정리한 패키지이며 전체 실게임 재시험을 뜻하지 않습니다.

**범위:** 영문 클라이언트의 실제 게임 실행, 모든 퀘스트·착지·명령·전문기술 단계와 파티 동시 적용을 전수 확인하지 않았습니다. 서버 명령과 GM 권한이 필요하며 애드온이 GM 권한을 부여하지 않습니다. 상세 시험 기록과 개발 당시 스크린샷 식별자는 저장소에 보존합니다.

## English

Initial **v1.0.0** release for **WoW Legion 7.3.5 (26972), Interface 70300 / SPP Legion V2 Praevius 2026.2a**.

Includes the established GM MINI BAR layout, GM utilities, spell/item browsers, professions, unified bags with four equipment slots, teleport browser and quest helper. Korean server reply parsing now supports Find Objective / Quest Start / Quest End independently of the addon UI language; English replies remain supported.

Download **GMminibar_SPP_Legion_7.3.5_v1.0.0.zip** and place its single `GMminibar` folder in `Interface/AddOns`. Replace an older addon folder while preserving `WTF`. No extra MPQ, DLL or SQL import is required. Bilingual guides, actual Legion screenshots and links to other client editions are in the repository.

Validation passed: **14 Lua syntax files and 295 mocked API contracts per language**. The same gameplay implementation was tested with the Korean client and localized server: quest 27168 objective/start/end travel, 24/24 diagnostics and no errors in that test session. Release renumbering and documentation changes are not a new full gameplay test. Actual English-client gameplay, all quests/landings/commands/profession ranks and multiplayer actions remain unverified. Server GM permissions are required.
