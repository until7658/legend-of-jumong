# 북방 황야 타일맵 애셋 제작 사양

## 목적

지면, 고저차, 장식, 충돌 오브젝트를 분리해 Godot에서 반복 배치, Y 정렬, 충돌과 교체가 가능하도록 유지한다.

## 레이어 구분

| 레이어 | 포함 대상 | 배경 | 충돌 | 정렬 기준 |
| --- | --- | --- | --- | --- |
| Ground | 풀, 흙, 진흙, 자갈, 물 | 불투명 | 없음 | TileMap 바닥 |
| Path | 흙길, 모서리, 교차로, 길 끝 | 불투명 | 없음 | Ground 위 Terrain 레이어 |
| Elevation | 절벽 상단·전면, 모서리, 경사, 계단 | 불투명 | 절벽 전면만 필요 | 높이별 TileMap 레이어 |
| Ground Detail | 잔풀, 갈대, 꽃, 자갈, 낙엽, 잔가지 | 투명 | 없음 | 지면 위 장식 레이어 |
| World Object | 나무, 큰 바위, 통나무, 그루터기 | 투명 | 발밑 또는 하단 실루엣 | 오브젝트의 하단 중앙 피벗 |

지면 텍스처에 나무나 큰 바위를 합치지 않는다. 소형 장식도 맵 반복 패턴을 숨기는 용도로만 사용하고 이동 판정에는 관여시키지 않는다.

## 현재 애셋 분류

- `assets/tiles/basic_northern_wilderness_tiles.png`: 기본 지면 콘셉트
- `assets/tiles/northern_wilderness_path_tiles.png`: 길과 교차로 콘셉트
- `assets/tiles/northern_wilderness_elevation_tiles.png`: 절벽과 한 단계 고저차 콘셉트
- `assets/tiles/northern_wilderness_water_terrain.png`: 얕은 물, 물가, 수로, 여울 콘셉트
- `assets/tiles/northern_wilderness_ground_transitions.png`: 풀과 흙·진흙·자갈의 경계 콘셉트
- `assets/tiles/northern_wilderness_cliff_connections.png`: 절벽 직선·모서리·경사·계단 연결 콘셉트
- `assets/objects/northern_ground_detail_objects.png`: 충돌 없는 소형 투명 오버레이
- `assets/objects/northern_tree_objects.png`: 나무·관목·통나무 독립 오브젝트
- `assets/objects/northern_rock_objects.png`: 바위·돌무더기 독립 오브젝트
- `assets/tiles/northern_wilderness_props_tiles.png`: 지면과 오브젝트가 합쳐진 폐기 예정 참고본

## 셀과 피벗

- 투명 오브젝트 시트는 모든 셀 크기가 정수로 나뉘어야 한다.
- 현재 3×3 나무·바위 시트는 1254×1254이며 셀은 418×418이다.
- 소형 디테일 시트는 실제 통합 전에 4로 나누어지는 규격으로 정규화한다.
- 나무와 선돌의 피벗은 하단 중앙의 접지점으로 둔다.
- 넓은 바위와 통나무는 하단 실루엣 중심을 피벗으로 사용한다.
- 잔풀·자갈 같은 소형 디테일은 셀 중앙 피벗을 사용한다.

## 충돌과 가림

- 나무 충돌은 수관이 아니라 줄기 하단만 막는다.
- 큰 바위는 실제 접지 면적보다 약간 작은 충돌 영역을 사용한다.
- 그루터기와 통나무는 크기에 따라 통과 가능 여부를 데이터로 구분한다.
- 캐릭터가 나무 뒤로 이동할 수 있도록 하단 피벗 기반 Y 정렬을 사용한다.
- 절벽 전면은 충돌시키고 경사로·계단 타일만 높이 이동을 허용한다.

## 시각 밀도 기준

- 이동 경로 중앙에는 큰 오브젝트를 배치하지 않는다.
- 한 화면에서 큰 나무는 3~6개, 큰 바위는 2~4개를 기본 상한으로 삼는다.
- 소형 디테일은 빈 타일의 20~35%에만 배치해 반복감을 줄이되 전투 가독성을 유지한다.
- 꽃 색상은 저채도를 유지하고 퀘스트 마커나 진영색보다 눈에 띄지 않게 한다.

## 실제 통합 전 필수 후처리

1. 정규화본은 `assets/tiles/normalized/`의 1024×1024 아틀라스와 256×256 셀을 사용한다.
2. 타일 테두리의 생성형 격자 흔적을 제거한다.
3. 길과 절벽의 반대편 셀 경계를 반복 배치로 검사한다.
4. 오브젝트별 AtlasTexture 리전과 피벗을 정의한다.
5. 나무·바위 충돌과 Y 정렬을 테스트 씬에서 검증한다.
6. Godot Terrain Set 규칙은 화면 증거와 함께 별도 검증한다.

## 남은 타일 제작 우선순위

1. 길과 여울·계단·경사·다리 입구의 특수 연결
2. 수풀, 급경사, 깊은 물처럼 맵 경계를 표현하는 타일과 오브젝트
3. 젖은 흙, 물웅덩이, 밟힌 풀, 불탄 지면 같은 환경 상태 변형
4. 실제 Terrain Set에 사용할 정수 셀 규격 정규화본

## 정규화 결과

- 원본 콘셉트 시트는 보존한다.
- 지면·길·물가·지면 전환·절벽 연결·고저차는 `assets/tiles/normalized/`에 1024×1024로 저장한다.
- 각 정규화 타일 시트는 4×4, 셀 크기 256×256이다.
- 소형 지면 디테일은 `assets/objects/normalized/`에 동일 규격과 알파 채널을 유지한다.
- `data/tilesets/northern_wilderness_tile_catalog.json`을 레이어·텍스처·충돌 정책의 기준으로 사용한다.
- 생성형 원본의 연결 관계는 화면 검증 전까지 `needs_visual_peering_validation` 상태로 유지한다.
