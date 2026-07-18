# M1 개발 환경

## 목적

프로젝트가 Godot 4.7.1에서 재탐색되고, 메인 씬이 오류 없이 로드되며, 2D SD 캐릭터 중심의 쿼터뷰 필드·전투를 확장할 수 있는 최소 기반을 유지합니다.

## 구조 원칙

- 게임 월드는 `Node2D`, `TileMapLayer`, `Camera2D`, `CharacterBody2D`, `Area2D` 등 2D 노드로 구성합니다.
- `Interface`는 `CanvasLayer`와 `Control` 기반의 2D 화면 표시를 담당합니다.
- 핵심 게임플레이와 전술 맵에는 3D 물리·충돌·내비게이션 의존성을 추가하지 않습니다.
- 과거 HD-2D·3D 시험 씬과 전용 애셋은 복원하지 않습니다. 승인된 교전 컷인의 작은 3D 배경은 전용 경로에서 새로 만들고 동일한 2D 폴백을 유지합니다.
- 전투 규칙과 UI는 직접 결합하지 않고 향후 시그널과 이벤트로 연결합니다.
- 수치, 대사, 이벤트 데이터는 코드에서 분리합니다.
- 실제 애셋과 플레이스홀더는 혼합하지 않습니다.

## 검증

프로젝트 변경 후 다음 순서로 확인합니다.

Windows에서는 Godot 4.7.1을 제한된 Codex 샌드박스에서 직접 실행하지 않습니다. 네이티브 충돌과 Visual Studio JIT 디버거 팝업을 방지하기 위해 정상 사용자 환경에서 아래 runner를 한 번에 하나씩 실행합니다.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\run_godot_check.ps1 -Mode editor
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\run_godot_check.ps1 -Mode script -ScriptPath res://tests/combat_demo_smoke.gd
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\run_godot_check.ps1 -Mode project -QuitAfter 2
```

runner 종료 코드 `86`은 제한된 샌드박스 실행 거부, `87`은 다른 Godot 프로세스 또는 검증 잠금 감지입니다. JIT 디버깅을 전역으로 끄거나 여러 검증을 병렬 실행하지 않습니다.

1. runner의 `editor` 모드로 파일시스템 재탐색 및 파싱 오류를 확인합니다.
2. `tests/2d_identity_smoke.gd`를 실행해 핵심 게임플레이 경로가 승인되지 않은 3D 의존성을 갖지 않는지 확인합니다.
3. 메인 씬을 실행해 `[BOOTSTRAP] M4 title screen ready` 로그를 확인합니다.
4. 타이틀→프롤로그→전체 2D 분대 훈련전 흐름을 확인합니다.
5. 명령, 종료 코드, 로그, 화면 증거를 `jumong-verify` 판정에 포함합니다.
