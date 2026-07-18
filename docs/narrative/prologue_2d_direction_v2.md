# 오프닝 14컷 완전 2D 연출 전환 v2

## 전환 판정

- 모든 공간은 `Node2D` 루트, 모든 카메라는 `Camera2D`, 이동 궤적은 `Path2D/PathFollow2D`, 배우는 `CharacterBody2D` 또는 `AnimatedSprite2D`로 한정한다.
- `Node3D`, `Camera3D`, `Marker3D`, `Sprite3D`, 원근 투영, 3D transform 전제를 금지한다.
- 기준 해상도는 1280×720이며 JSON 좌표는 좌상단 원점 픽셀이다. 해상도 변경은 캔버스 스트레치가 담당하고 타임라인 좌표는 바꾸지 않는다.

## 공간 밀도와 화면 템포

- Graveyard Keeper는 작은 2D 공간에서 전경·중경·배경 오브젝트를 겹쳐 생활 밀도를 만드는 방식과 짧은 행동 템포만 참고한다. 배치, 팔레트, 캐릭터 비율, UI, 애니메이션, 맵 형태는 복제하지 않는다.
- 강변은 전경 갈대, 중경 배우/배, 후경 나무·안개의 세 깊이로 구성한다. 실내는 전경 문틀/기둥이 배우를 부분적으로 감싸 빈 무대처럼 보이지 않게 한다.
- 이동 없는 대화도 8~12초마다 표정 상태, 약한 Camera2D pan, 전경 패럴랙스 중 하나만 바꾼다. 과도한 줌 반복은 피한다.

## 2D 카메라 규칙

- 기본 줌은 0.95~1.3, 손·호흡 같은 인서트만 최대 1.9를 허용한다.
- pan은 Tween 또는 PathFollow2D progress로 구현하며 회전은 사용하지 않는다. 픽셀 스냅을 켜고 최종 위치를 정수 좌표로 맞춘다.
- 패럴랙스 계수는 sky 0.03~0.08, far 0.15~0.2, mid 0.35, front 0.65~0.85 범위다.
- portrait/caption/fade는 `CanvasLayer`에서 카메라와 분리한다. 대사 초상화만 표시하고 내레이션에는 표시하지 않는다.

## 배우 상태와 스킵

- 배우 동선은 자유 3D 좌표가 아니라 명명된 `Path2D`와 상태 전환으로 고정한다. 구조 행동은 `approach → drag → breath_check → resolved`, 각성은 `finger_move → breath_wake → eyes_open → observe` 순서다.
- 스킵 시 PathFollow2D 진행률, AnimatedSprite2D animation/frame, z_index, visibility, 최종 position을 endpoint에 즉시 적용한다.
- 컷 종료 때 Camera2D Tween, 패럴랙스 Tween, 초상화, 덕킹을 모두 정리한다. 음악·SFX 계약은 v1을 그대로 유지한다.

## 레이어 계약

- 0 far parallax, 10 map back, 20 map mid, 30 actors, 40 map front, 50 weather/light, 100 portrait UI, 110 captions, 120 fade.
- 물가에서 유화는 오브젝트처럼 수평 전시하지 않는다. 어부와 전경 갈대가 구조 행위를 감싸고, 호흡 확인 클로즈업은 손·얼굴 관계를 중심으로 한다.
- 햇빛은 `PointLight2D` 또는 반투명 `Polygon2D` 마스크로 자연스럽게 이동한다. 유화를 추적하는 빛, 신성 광륜, 3D 볼류메트릭 광선은 금지한다.

## 유지 항목

- v1의 컷 길이 총 264초, 내레이션·대사·portrait 규칙, 음악 동기, 개별 SFX, 덕킹, skip-safe 의미는 변경하지 않는다.
- v2 JSON은 v1 타이밍/오디오를 상속하고 map/camera/actor 계약만 완전 2D로 덮어쓴다.
