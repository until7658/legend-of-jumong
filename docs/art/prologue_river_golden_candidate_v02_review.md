# 오프닝 강변 골든 후보 v02 검토

## 결과

v01의 셀 구획선과 소품 피벗 문제를 비파괴 재작업했다. 아직 씬에는 연결하지 않았다.

### Terrain

- `prologue_river_terrain_candidate_v02.png`: 1024×1024, 4×4, 256px 셀.
- 각 셀의 외곽 18px 생성 테두리를 제외한 내부를 재확장하고, 10px 반대 edge를 동기화했다.
- 기본 흙과 물 셀의 LR/TB edge MAD는 모두 `0.00`으로 요구치 `<=15`를 충족한다.
- `prologue_river_terrain_repeat_3x3_v02.png`에서 v01의 검은 격자선은 제거됐다.
- WNES 의도는 `data/maps/prologue_river_assets_v02.json`에 기록했다. 이는 시각 계약이며 Godot Terrain peering 실제 입력 검증은 아직 아니다.

판정: **반복성 수치 통과 / Terrain Set 통합 전 부분 승인**.

### Props

- v02 생성 소스에서 나무·바위·갈대·빈 배·노를 각각 512×512 RGBA로 분리했다.
- loose debris는 생성 단계에서 제거했고 배와 노는 별도 파일이다.
- 모든 피벗은 `(256,480)` bottom-center로 고정했다.
- 다섯 파일 모두 soft alpha 픽셀을 포함하며 strict residual magenta는 0px다.
- `prologue_river_props_background_check_v02.png`에서 밝음·어두움·녹색 배경을 확인했다.

soft alpha 픽셀: boat 2,064; oar 3,239; reeds 19,277; rock 4,599; tree 12,416.

판정: **분리·알파·피벗 통과 / 실제 Godot 축소 검증 전 부분 승인**.

## 최종 게이트

Godot 직교 카메라 1280×720에서 캐릭터 더미 145px, 배경 국소 명도차 20% 이상, Terrain peering과 충돌을 확인하기 전에는 골든 최종 승인 또는 씬 연결을 하지 않는다.
