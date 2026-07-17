# 주몽신화전기

Godot 4.x 기반 HD-2D 턴제 RPG 프로젝트입니다. 현재 마일스톤은 **M1 개발 환경 구성**입니다.

## 요구 환경

- Godot 4.7.1
- GL Compatibility 렌더러
- Jolt Physics
- 기준 해상도 1280×720

## 실행

Godot에서 `project.godot`을 열고 프로젝트를 실행합니다. 메인 씬은 `scenes/bootstrap/main.tscn`입니다.

## 디렉터리

- `scenes/`: 게임과 부트스트랩 씬
- `scripts/`: 정적 타입을 사용하는 GDScript
- `data/`: 대사, 이벤트, 스킬 수치 등 로직과 분리된 데이터
- `assets/`: 플레이스홀더와 검토 완료 애셋
- `tests/`: 자동 및 수동 검증 자료
- `docs/`: 개발 환경과 설계 문서

기존 테스트 전투 데모는 M1 구성에 포함하지 않습니다.

## 프리프로덕션 자료

- `docs/narrative/main_scenario.md`: 사실주의 방향의 메인 시나리오와 오프닝
- `docs/characters/jumong_character_bible.md`: 유화·어부·금와·주몽 초기 설정
- `docs/art/jumong_visual_guide.md`: 유화와 성년 주몽의 비주얼 기준
- `data/narrative/`, `data/characters/`: 이후 게임 구현에서 사용할 구조화 데이터
