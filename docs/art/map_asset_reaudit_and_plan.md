# 오프닝·제1장 맵 애셋 재감사 및 제작 계획 v1

## 목적과 판정 기준

이 문서는 기존 맵 PNG를 게임용 최종 애셋으로 오인하지 않도록 현재 상태를 다시 판정하고, 오프닝 4개 컷신 세트와 제1장 수직 슬라이스에 필요한 제작 단위를 고정한다. 정본은 `unified_visual_style_bible.md`, `production_visual_acceptance.md`, 오프닝·제1장 제작 시나리오다. 파일별 기계 판독 규격은 `data/maps/map_asset_manifest.json`이 소유한다.

상태 의미:

- `approved_reference`: 방향 참고만 승인. 게임 텍스처로 직접 연결하지 않는다.
- `rework`: 구조는 활용 가능하지만 카툰형 02의 선·색면으로 재도장하거나 알파·반복을 교정해야 한다.
- `blockout_only`: 동선·재질 배치 검사용. 출시 빌드 사용 금지.
- `rejected`: 결함 회귀 비교 외 사용 금지.
- `planned`: 아직 존재하지 않는 제작 항목.

## 기존 애셋 재감사

| 묶음 | 실제 상태 | 판정 | 허용 용도 | 승격 조건 |
| --- | --- | --- | --- | --- |
| `assets/tiles/golden/cartoon_northern_ground_gold_v1.png` | 1254×1254 RGB, 연속 환경 콘셉트 | `approved_reference` | 팔레트·큰 재질면 참고 | 256px 4×4 무봉합 Terrain, 3×3 반복, peering 검증 |
| `assets/objects/golden/cartoon_northern_props_gold_v1.png` | 1536×1024 RGB, 불투명 배경 | `rejected` | 실루엣 참고 | 개별 투명 원본, 수동 알파, 피벗·충돌 검수 |
| `assets/tiles/normalized/*.png` | 1024×1024 ARGB, 4×4/256px 구조 | `blockout_only` | 현재 프리뷰 동선·레이어 확인 | 사진적 노이즈 40~60% 제거, 카툰 재도장, peering 실검증 |
| `assets/objects/normalized/*` | 1024×1024 ARGB | `blockout_only` | 지면 디테일 배치 시험 | 알파 프린지·피벗·1280×720 가독성 검증 |
| `assets/objects/northern_tree_objects.png`, `northern_rock_objects.png` | 1254×1254 ARGB, 3×3 분할 후보 | `rework` | 실루엣·종류 참고 | 256 배수 아틀라스, 개별 bottom-center pivot, 저채도 유색선 재도장 |
| 나머지 1254×1254 원본 타일 | RGB 생성 원본 | `rejected` | 생성 이력·회귀 비교 | 정규 규격으로 수동 재제작하지 않는 한 직접 사용 금지 |

파일명에 `gold`가 있어도 PM 승인 전 `production_ready`가 아니다. 특히 기존 normalized 시트의 알파 채널 보유는 투명 픽셀이 유효하다는 증거가 아니므로 픽셀 검사와 밝은색·어두운색 배경 합성이 별도 필요하다.

## 오프닝 4개 컷신 세트

1. `opening_river_dawn`: 컷 1~4. 새벽 강, 얕은 물가, 작은 배, 구조 동선. 물은 3단 회청색 면과 끊긴 붓결로 표현하며 사실적 반사·광택을 금지한다.
2. `opening_ferry_office`: 컷 5~6. 나루 책임자의 소박한 목재 집무 공간. 젖은 인물 동선, 깔개, 낮은 상, 문밖 전령 실루엣이 한 축에서 읽혀야 한다.
3. `opening_palace_judgment`: 컷 7~9. 금와가 판단하는 목재 방. 거대한 옥좌·황금·조선식 단청 없이 낮은 침상, 목재 기둥, 직물, 실용 가구로 권위를 만든다.
4. `opening_yuhwa_chamber`: 컷 10~14. 유화의 처소와 문밖 처마·깃발·하늘 전환. 같은 공간의 약그릇과 빛 변화로 며칠의 경과를 보이며 마법 광선은 금지한다.

네 세트는 1920×1080 컷신 마스터와 1280×720 검수 캡처를 기준으로 한다. 인물과 자막 안전영역을 침범하는 고주파 디테일을 피하고, 카메라 이동용 전경·중경·후경 레이어를 분리한다.

## 제1장 제작 세트

- `chapter01_training_ground`: 궁술 표적 3개, 바람 깃발, 관중 안전영역, 왕성 연결길.
- `chapter01_stable_courtyard`: 마구간, 작은 활 회상 벽, 공개 동선과 회의실 문턱.
- `chapter01_prince_council`: 왕자들의 목재 방. 좌석 위계는 높이·거리로, 황금 장식으로 표현하지 않는다.
- `opening_yuhwa_chamber` 재사용 변형: 17년 뒤 수선 천·약재·청동 장식과 탈출 준비 상태.
- `chapter01_northern_ridge`: 흔적 조사, 높은 우회로, 밧줄 함정, 비살상 돌파 전투 공간.
- `chapter01_palace_return`: 달라진 순찰, 동쪽 회랑, 물자 수레·무기고 시선 차단.
- `chapter01_drainage_escape`: 유화의 처소→마구간 뒤 배수로→성문 외곽을 잇는 잠입 동선과 경보 횃불.

## Godot 임포트·Terrain 계약

- Terrain 원본: 무손실 PNG, sRGB, 1024×1024, 4×4, 셀 256×256, mipmap 끔, 선형 필터, lossless 압축. 셀 바깥 bleed 금지.
- 투명 오브젝트: RGBA PNG, straight alpha, `fix_alpha_border=true`, premultiply 끔, bottom-center pivot. 원본 피벗은 JSON의 픽셀 좌표로 고정한다.
- Terrain peering: `W,N,E,S` 4방향 bitmask를 정본으로 하고 모서리 장식은 연결 판정을 바꾸지 않는다. 물가·절벽은 충돌용 별도 폴리곤을 사용한다.
- 3D 배치: 텍스처의 고정광을 약하게 하고 직교 45~50° 카메라와 단일 방향광에 맞춘다. 사실적 PBR 광택·노멀 노이즈를 쓰지 않는다.
- 캐릭터 계약: 1280×720 탐색 신장 110~155px(골든 145px), 머리 폭 22px 이상, 활 2px 이상, 캐릭터 주변 24~40px 시각 휴지, 배경과 국소 명도차 20% 이상. 환경 선명도와 선 굵기는 캐릭터보다 한 단계 낮다.
- AI 생성 애셋은 도구·날짜·목적·수정·사용 위치·권리 검토를 기록하고, 사람의 구조 교정과 상업 사용 검수를 통과해야 한다.

## 우선순위와 승인 순서

1. P0: 카툰 Terrain core(풀·흙·길·물·물가), 투명 식생·바위, 작은 배·나루 소품.
2. P0: 오프닝 4세트 블록아웃 및 1280×720 캐릭터 대비 합성.
3. P1: 훈련장·마구간·왕자 방·유화 처소·북쪽 능선·귀환 회랑·배수로 세트.
4. P1: Godot Terrain peering, 물가·절벽 충돌, 카메라 무보정 캡처.
5. P2: 시간대·날씨 변형과 배경 군중·장식 파생.

승인은 JSON의 `acceptance_tests` 전 항목과 실제 Godot 1280×720 무보정 캡처가 함께 있을 때만 가능하다. 현 단계에서 기존 맵 애셋 중 게임용 최종 승인본은 없다.
