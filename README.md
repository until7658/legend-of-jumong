# 주몽신화전기

Godot 4.x 기반 2D SD 도트 캐릭터 중심의 쿼터뷰 턴제 RPG 프로젝트입니다. 캐릭터, 전술 맵, UI와 핵심 게임플레이는 Godot 2D 노드 및 2D 애셋으로 제작합니다.

과거 HD-2D·3D 시험 씬과 전용 자산은 프로젝트에서 삭제했습니다. 승인된 교전 컷인의 작은 3D 배경 무대는 과거 자산을 복원하지 않고 별도 경로에서 새로 시험합니다.

## 요구 환경

- Godot 4.7.1
- GL Compatibility 렌더러
- 기준 해상도 1280×720
- PC Steam 배포, 키보드·마우스와 게임패드
- 한국어 원문·영어 1차 지원을 시작으로 확장 가능한 다국어 구조

## 실행

Godot에서 `project.godot`을 열고 프로젝트를 실행합니다. 메인 씬은 `scenes/bootstrap/main.tscn`입니다.

## 디렉터리

- `scenes/`: 게임과 부트스트랩 씬
- `scripts/`: 정적 타입을 사용하는 GDScript
- `data/`: 대사, 이벤트, 스킬 수치 등 로직과 분리된 데이터
- `assets/`: 플레이스홀더와 검토 완료 애셋
- `tests/`: 자동 및 수동 검증 자료
- `docs/`: 개발 환경과 설계 문서
- `.agents/skills/`: 전체 2D 제작 방향, 전문 영역과 검증을 담당하는 프로젝트 에이전트 스킬

게임플레이·전술 맵·전술 카메라·충돌·캐릭터는 2D를 기준으로 유지합니다. 승인된 교전 컷인 배경과 특수한 하이브리드 이펙트는 계산과 분리된 전용 경로 및 2D 폴백을 갖추며, `tests/2d_identity_smoke.gd`가 핵심 게임 경로의 2D 정체성을 회귀 검사합니다.

## 에이전트 운영

모든 제작 요청은 `jumong-production-governor`의 전체 2D 적합성 검토, `jumong-game-director`의 승인 계획, 전문 에이전트 구현, `jumong-verify`의 읽기 전용 검증 순서로 진행합니다. Steam 전략은 `jumong-steam-strategy`가 조사·협의합니다. 에이전트 제작 주기는 한국시간 매일 09:00에 시작하고, 21:00 일일 보고·검증·안전한 fast-forward 커밋·푸시 후 종료합니다. 세부 규칙은 `AGENTS.md`를 따릅니다.

## 프리프로덕션 자료

- `docs/narrative/main_scenario.md`: 사실주의 방향의 메인 시나리오와 오프닝
- `docs/characters/jumong_character_bible.md`: 유화·어부·금와·주몽 초기 설정
- `docs/art/jumong_visual_guide.md`: 유화와 성년 주몽의 비주얼 기준
- `data/narrative/`, `data/characters/`: 이후 게임 구현에서 사용할 구조화 데이터
