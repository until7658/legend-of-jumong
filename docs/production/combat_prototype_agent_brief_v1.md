# 전투 프로토타입 전 에이전트 공통 브리프 v1

이 문서는 전투 프로토타입에 참여하는 production-governor, game-director, narrative, character, combat, level-2d, 2d-art, core-systems, ui-systems, audio, steam-strategy, verify의 공통 정본이다. 각 담당자는 작업 전에 이 문서를 읽고 결과가 아래 계약과 충돌하지 않는지 스스로 점검한다.

## 정본 조건

1. 우리 게임은 2D SD 도트 캐릭터 중심의 쿼터뷰 게임이다. 전술 맵·조작·충돌·전투 계산·캐릭터는 2D를 기준으로 한다. 승인된 교전 컷인에서는 작은 3D 배경 무대를 별도 렌더로 합성할 수 있으나, 2D 캐릭터·VFX·UI와 동일 payload의 2D 폴백을 유지하고 게임플레이 계산·물리·내비게이션에 관여하지 않는다.
2. 전술 맵은 지면을 45~50도 내려다보는 쿼터뷰다.
3. 인게임 인물은 2~4등신, 기본 약 3등신의 SD 도트 캐릭터다.
4. 분대는 총 4명이 아니다. M4 기본은 지휘관 1명+병사 8명이고, 정식 데이터는 병사 6~12명을 허용한다.
5. 특정 전술 RPG의 UI, 수치, 대형, 캐릭터, 화면 구도, 타격 연출을 복제하지 않는다.
6. 한국어·영어 확장을 고려해 사용자 노출 문자열과 로직을 분리한다.
7. 키보드·마우스와 컨트롤러를 같은 행동 계약으로 지원한다.

## 세 가지 연출 레이어

### 1. 전술 맵

- 플레이어는 지휘관과 병사들을 하나의 분대로 선택·이동·명령한다.
- 지휘관 1명과 현재 생존 병사 수가 쿼터뷰 축약 대형으로 보인다.
- 이동, 공격 범위, 병종, 병사 수, 지휘관 기세를 즉시 읽을 수 있어야 한다.

### 2. 다수 병사 교전 컷인

- 공격 확정 시 별도 교전 무대에서 아군 지휘관+병사 최대 8명과 적 지휘관+병사 최대 8명이 맞붙는다.
- 기준선은 전체 2D 무대이며, 승인된 A/B 스파이크는 고정 직교 카메라의 작은 3D 지면·프롭만 배경으로 합성한다. 캐릭터·접지 그림자·VFX·UI는 2D다.
- 궁병은 후열 일제사격, 창병은 전열 압박으로 병종 실루엣과 상성을 표현한다.
- 1~3초 안에 공격 준비→충돌/사격→피해/후퇴→결과를 보여 준다.
- 컷인은 건너뛰기와 고속 진행을 고려하며 전투 계산을 소유하지 않는다.

### 3. 개인·서사 컷신

- 궁술대회, 결투, 대화, 구조, 즉위는 분대 교전 컷인과 별도다.
- 궁술대회는 주몽 개인의 호흡, 손가락, 활의 휨, 화살 궤적, 과녁과 관중 반응에 집중한다.

## M4 전투 규칙

- 아군: 주몽 지휘관+수련 궁병 8명
- 적군: 훈련대장 지휘관+수련 창병 8명
- 궁병이 2칸 이상에서 창병 공격: 피해 +2
- 창병이 인접한 궁병 공격: 피해 +2
- 대열 방어: 다음 피해 -1
- 훈련전 손실은 사망이 아니라 제압·후퇴다.
- 상태 흐름: `SETUP -> PLAYER_SELECT -> PLAYER_MOVE -> PLAYER_COMMAND -> RESOLVE -> ENEMY_TURN -> ROUND_END -> VICTORY/DEFEAT`
- 계산은 결정론적으로 유지하고 컷인·HUD·오디오는 계산 결과를 표현만 한다.

## 역할과 파일 소유권

| 역할 | 책임 | 주 소유 경로 |
|---|---|---|
| production-governor | 2D 캐릭터 정체성·하이브리드 범위·문서 충돌 감사 | `AGENTS.md`, 운영 브리프 |
| game-director | 작업 분류, 통합 순서, 승인 범위 | 마일스톤·일일 보고 |
| combat | 상태머신, 피해, AI, 결과 payload | `scripts/combat`, `data/combat`, `tests/combat*` |
| character | 지휘관·병사 상태와 애니메이션 요구 | `docs/characters`, `data/characters`, `scenes/characters` |
| level-2d | 쿼터뷰 전술 좌표·대형·무대 | `scenes/maps`, `scripts/level_map`, `data/maps` |
| 2d-art | SD 도트 규격, 병종 실루엣, 2D VFX | `docs/art`, `assets/characters`, `assets/vfx` |
| ui-systems | 명령·상태 HUD, 포커스, 자막 | `scenes/ui`, `scripts/ui`, `docs/ui` |
| audio | 군령·활·창·피격·후퇴 큐와 믹싱 | `docs/audio`, `data/audio`, `assets/audio` |
| core-systems | 메인 흐름, 입력, 세이브, 공통 신호 | `scripts/bootstrap`, `scripts/systems`, `scenes/bootstrap` |
| narrative | 훈련전 목적·대사·비살상 결과 | `docs/narrative`, `data/narrative` |
| verify | 읽기 전용 파싱·실행·화면·2D 정체성 판정 | 검증 로그·증거 |

동일 파일을 여러 에이전트가 수정하지 않는다. 통합 파일인 기존 전투 컨트롤러와 메인 부트스트랩은 각 전문 결과가 끝난 뒤 디렉터가 순차 통합한다.

## 공통 데이터 전달 계약

교전 컷인에는 다음과 같은 계산 완료 payload만 전달한다.

```text
attacker_id, defender_id, attacker_troop_type, defender_troop_type,
attacker_soldiers_before, attacker_soldiers_after,
defender_soldiers_before, defender_soldiers_after,
commander_damage, distance, advantage, nonlethal
```

컷인은 `presentation_finished`를 방출하고 전투 컨트롤러는 그 뒤 다음 상태로 진행한다. 컷인을 건너뛰어도 동일한 계산 결과와 승패가 나와야 한다.

## 완료 기준

- 전술 맵에 양측 지휘관 1명+병사 8명이 명확히 보인다.
- 플레이어 공격과 적 공격 모두 별도 2D 교전 컷인을 호출한다.
- 병사 수 감소가 전술 맵과 컷인에 일치한다.
- 입력, 세이브, 전투, 스토리 회귀 테스트가 통과한다.
- `tests/2d_identity_smoke.gd`가 통과한다.
- 하이브리드 스파이크는 전용 경로 검사, 2D 폴백, 1280×720·1280×800 화면과 반복 재생 성능 검증을 통과한다.
- 1280×720과 1280×800에서 핵심 정보가 잘리지 않는다.
