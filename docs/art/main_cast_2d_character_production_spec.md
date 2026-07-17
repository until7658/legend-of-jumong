# 주요 등장인물 2D 캐릭터 제작 사양 v1

## 목표와 정본

승인 가능한 기존 일러스트를 원화 축소가 아닌 **비픽셀 384×384 게임 전용 2D 캐릭터**로 재구성한다. 기존 주몽 골든 시트는 프린지·프레임 구조·무기 일관성 문제로 게임에 직접 사용하지 않는다.

- 서사 정본: `docs/characters/full_character_design_bible.md`, `docs/narrative/chapter_01_production_script.md`
- 스타일 정본: `docs/art/unified_visual_style_bible.md`, `docs/art/production_visual_acceptance.md`
- 제1장 주몽 연령: **17세**. `data/characters/jumong.json`의 `age_at_escape: 19`는 정본과 충돌하므로 수정 전까지 자동 제작 입력으로 사용하지 않는다.
- 최상위 원화 후보: `assets/concept/cartoon_v1/`. 구조 교정 전에는 `approved source`가 아니라 `conditional reference`다.
- 보조 원화: `assets/concept/main_cast_v1/`. 인물 구분·복식·표정 참고용이며 거친 선과 2.5단 채색으로 재통일해야 한다.

## 공통 출력 계약

- 캔버스: 384×384 RGBA PNG, sRGB, 자동 트림 금지
- 피벗: 필드·전투 공통 `(192, 340)`; 발 최하단 `y=338~342`
- 안전 영역: 불투명 픽셀 `x=16~368`, `y=16~340`; 승인된 그림자·옷자락만 예외
- 필드 표시 신장: 110~155px, 전투 145~210px
- 선: 외곽선은 원화보다 20~35% 굵게, 내부선은 40~60% 축소
- 채색: 기본색+큰 그림자+접촉 암부의 2.5단 셀 채색, 질감은 면적 10~20%
- 파일명: `<character_id>_<animation_id>_<direction>_<frame:02>.png`
- 방향 키: `front`, `front_left`, `left`, `back_left`, `back`, `back_right`, `right`, `front_right`
- 좌우 반전 금지 대상: 무기손, 방패, 화살통, 칼집, 주머니, 흉터, 머리 장식, 장비 수선 자국

## 표준 레이어 팩

모든 인물은 다음 레이어를 전체 캔버스 좌표로 보존한다.

1. `shadow_contact`
2. `leg_back`, `leg_front`, `foot_back`, `foot_front`
3. `torso_base`, `waist`
4. `arm_back_upper`, `arm_back_lower`, `hand_back`
5. `arm_front_upper`, `arm_front_lower`, `hand_front`
6. `neck`, `head_base`, `face`, `hair_back`, `hair_front`
7. `garment_back`, `garment_front`, `cloth_secondary`
8. `equipment_back`, `equipment_front`, `prop_hand`
9. `outline_correction`, `rimlight_selective`

활·창·방패·도끼·칼·목간·약재·청동 장식은 인체와 별도 마스터로 만든다. 관절 회전만으로 형태가 깨지는 손·팔꿈치·무릎·옷깃은 방향별 교정 레이어를 둔다.

## 제작 팩 단계

### Gate A — source lock

- 3/4 원화와 캐릭터 바이블을 비교해 나이, 체형, 세력색, 소지품을 잠근다.
- 손, 복식 여밈, 장비 결합, 시대착오를 교정한 정면·측면·후면 턴어라운드를 만든다.
- `source_status`가 `conditional_reference` 또는 `style_rework_required`면 원화를 그대로 트레이싱하지 않는다.

### Gate B — neutral base

- `front`, `left`, `back`의 중립 정지 베이스를 제작한다.
- 머리·어깨·허리·무기·접지의 기준점을 기록한다.
- 좌우 비대칭표와 장비 착용 순서를 승인받는다.

### Gate C — golden motion

- 대기 4f/5fps, 걷기 4f/7fps의 `front`와 `left`만 먼저 만든다.
- 전투 인물은 대표 행동의 키포즈만 추가한다. 중간 프레임과 8방향 양산은 금지한다.
- 밝은색 `#D8D1BE`, 어두운색 `#101827`, 녹색 `#547050` 배경과 실제 맵 1280×720 합성에서 검수한다.

### Gate D — production expansion

- 골든 승인 후 8방향 이동, 상호작용, 달리기, 피격을 확장한다.
- 전투 참여자는 전투 대기, 일반 공격, 고유 행동, 피격, 회피, 방어, 승리, 전투 불능을 확장한다.
- 컷신 전용 NPC는 필요 동작만 제작해 불필요한 전투 세트를 만들지 않는다.

## 우선 골든 샘플

### 1순위 — 주몽

- 목적: 프로젝트 전체 비율·선·접지·무기 구조의 골든 기준
- 범위: `idle_front` 4f, `walk_front` 4f, `walk_left` 4f, `basic_shot_left` 6f
- 고정 키: `(192,340)`, 머리 상단, 양 어깨, 허리, 양 손, 활 그립, 활 팁, 노킹점, 화살통 결합점
- 레이어: 인체 표준팩+`bow_rest`, `bow_half_draw`, `bow_full_draw`, `bow_string`, `arrow`, `quiver`, `arm_guard`, `short_blade`
- 비대칭: 활손/시위손, 화살통, 팔보호대, 소형 칼. 좌우 반전 금지
- 승인 기준: 17세의 마르고 민첩한 체형, 발 ±2px, 머리 ±3px, 활·화살 길이 ±1%, 그립·노킹 ±2px, 프린지 0

### 2순위 — 유화

- 목적: 프롤로그와 제1장의 시간차·감정 절제를 검증하는 비전투 골든
- 범위: 프롤로그 `unconscious_river`, `supported_walk`; 제1장 `idle_front`, `listen_door`, `hide_token`, `straighten_collar`
- 별도 베이스: `prologue_young_wet`과 `chapter01_mother`를 분리하고 같은 얼굴 골격을 유지한다.
- 비대칭: 작은 청동 장식과 천 속 보관 위치, 머리 묶음 방향
- 승인 기준: 성녀 광륜·왕비복 금지, 젖은 천과 구조 자세가 유화를 물건처럼 보이게 하지 않음

### 3순위 — 대소

- 목적: 주몽과 다른 대칭·통제형 실루엣, 평면 악당이 아닌 적대자 연기 검증
- 범위: `idle_front`, `walk_left`, `polite_shoulder_touch`, `command_hand`, `spear_guard`
- 비대칭: 왼쪽 눈썹 흉터, 창 휴대 방향. 복식 자체는 의도적으로 대칭
- 승인 기준: 주몽보다 큰 어깨, 공개적 절제, 검은 악역 로브·비열한 웃음 금지

### 4순위 — 오이·마리·협보 파티 판독 세트

- 목적: 145px에서 머리·어깨·무기만으로 파티 역할 판독
- 범위: 각 `idle_front`, `walk_left`, 대표 행동 키포즈
- 대표 행동: 오이 `shield_cover`, 마리 `inspect_tracks`, 협보 `read_record`
- 승인 기준: 오이는 방패 덩어리, 마리는 세로로 긴 정찰 실루엣, 협보는 목간·약재와 가는 실루엣이 즉시 구분됨

### 5순위 — 프롤로그 노동·권력 대비 세트

- 대상: 어부, 나루 책임자, 금와왕, 왕성 신하
- 목적: 과장된 왕궁 판타지 없이 노동자·실무자·통치자·조언자를 자세와 소품으로 구분
- 범위: 정면 대기와 시나리오 필수 행동만 제작

## 캐릭터별 제작 요약

| character_id | 실루엣 키 | 장비/비대칭 | 첫 제작 동작 |
| --- | --- | --- | --- |
| `jumong` | 높은 묶음머리, 마른 어깨, 합성궁 | 활손·시위손, 화살통, 팔보호대 | 바람 확인, 기본 사격 |
| `yuhwa` | 긴 단정한 얼굴, 낮은 머리 묶음 | 청동 장식, 천 보관 방향 | 문밖 듣기, 장식 숨기기 |
| `king_geumwa` | 넓은 어깨, 노년의 약간 굽은 등 | 짧은 지휘봉 | 목간 정리, 관찰 |
| `daeso` | 큰 어깨, 곧고 대칭인 자세 | 왼 눈썹 흉터, 장창 | 어깨 접촉, 손 지휘 |
| `other_princes` | 체형·무기 3원형 | 창/목간/기마궁 분리 | 관망·동조 |
| `oi` | 짧고 단단한 체형, 원형 방패 | 방패와 도끼 손 | 방패 엄호 |
| `mari` | 키 크고 마름, 짧은 망토 | 투창·소형 활·갈고리 | 흔적 확인 |
| `hyeopbo` | 가는 체형, 목간 주머니 | 잉크 손, 약초·연막 | 기록 확인 |
| `soseono` | 곧은 자세, 여러 갈래 머리 | 짧은 검, 문서 주머니 | 지도 지휘 |
| `yeontabal` | 큰 체격, 열린 손짓 | 저울추·인장 주머니 | 교섭 손짓 |
| `fisherman` | 굽은 어깨, 굵은 손 | 그물·노 | 노 젓기, 구조 |
| `ferry_warden` | 보통 체형, 정돈된 자세 | 목간 주머니 | 전령 호출 |
| `court_official` | 마른 노년, 목간 묶음 | 기록 손 | 우려·보고 |
| `mugol` | 작은 키, 두꺼운 팔 | 오른발 절뚝임, 말솔 | 활 점검 |
| `aran` | 둥근 얼굴, 빠른 걸음 | 약재 주머니, 접은 천 | 긴급 전달 |
| `haemyeong` | 긴 얼굴, 창 중심 수직선 | 오른손 화상, 뿔피리 | 매복 지휘 |
| `bari` | 작은 노년 여성, 굵은 손 | 물깊이 장대 | 여울 측정 |
| `biryuchan` | 큰 체격, 오래된 어깨 부상 | 큰 방패·창 | 길 차단 |

## 검수 배경과 자동 검사

- 배경 3색과 `chapter_01_training_ground` 무보정 캡처 위에서 외곽선·알파·세력색을 확인한다.
- 맵 합성은 1280×720, 직교 45~50°, 골든 표시 신장 145px, 머리 폭 22px 이상, 활 2px 이상으로 고정한다.
- 캐릭터 주변 24~40px에는 충돌하는 세력색·명도의 큰 오브젝트를 두지 않고 국소 명도차 20% 이상, 배경 선명도 한 단계 낮음, 접지 그림자 불투명도 20~38%를 확인한다.
- RGBA, 384×384, 연속 프레임, 안전 영역, 피벗, 접지, 알파 바운딩 박스를 자동 검사한다.
- 25%·50%·100% 썸네일, 단색 실루엣, 전후 프레임 오버레이를 생성한다.
- 녹색 프린지, 반투명 이중선, 프레임마다 달라진 얼굴·여밈·장비는 자동 또는 수동 실패 처리한다.
- 실제 Godot에서 FPS·루프·방향·이벤트 프레임을 검수하며 사용자와 PM 승인 전 최대 상태는 `approval_candidate`다.

## 현재 차단 사항

- `jumong.json`의 연령 충돌 해결 전 주몽 팩은 정본 문서의 17세를 강제한다.
- `cartoon_v1`은 주몽·유화·금와·어부·나루 책임자·신하만 존재한다. 나머지는 `main_cast_v1`을 구조 참고로 쓰되 전면 스타일 재작업이 필요하다.
- 기존 `jumong_gold_*` 3종은 타이밍·실루엣 참고 외 직접 사용과 복사·보간을 금지한다.
- `other_princes`는 확정 이름이 없는 집단이다. 개별 역사 인물처럼 이름을 추가하지 않는다.
