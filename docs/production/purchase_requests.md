# 애셋·플러그인 조달 검토 대장

## 운영 원칙

- 구매·결제·로그인·다운로드·약관 수락은 사용자 승인 뒤 수행한다.
- 무료 항목도 새 런타임 의존성이나 독점 라이선스를 포함하면 결정 요청 대상으로 본다.
- Godot Store 등록만으로 품질·상업 적합성이 보장된다고 판단하지 않는다.

## 2026-07-18 조사

즉시 금전 구매 승인이 필요한 유료 후보는 발견하지 못했다. 다음 후보는 도입 전에 사용자 결정을 받는다.

| 우선순위 | 후보 | 조건 | 추천 | 결정 이유 |
| --- | --- | --- | --- | --- |
| P0 | [Controls Remap](https://store.godotengine.org/asset/kobewi/controls-remap/) | 표시 가격 없음, MIT, Godot 4.6+ | 파일럿 도입 | 키보드·게임패드 리바인딩과 충돌 검사를 직접 구현하는 비용 절감 |
| P0 | [Action Icon](https://store.godotengine.org/asset/kobewi/action-icon/) | 표시 가격 없음, MIT/기본 아이콘 CC0 | Controls Remap과 함께 파일럿 | 입력 장치별 글리프와 Steam Deck UX 대응 |
| P0 | [AutoSizeText](https://store.godotengine.org/asset/spielmannspiel/autosizetext/) | 표시 가격 없음, MIT, Godot 4.4+ | CJK 회귀 테스트 후 도입 | 현지화 길이 변화와 UI 오버플로 감소 |
| P0 | [GodotSteam GDExtension](https://store.godotengine.org/asset/godotsteam/godotsteam-gdextension/) | 무료, MIT, Godot 4.4.1~4.7 | Steam App ID·기능 범위 확정 뒤 도입 | Steam 초기화·업적·클라우드·통계 통합 비용 절감 |
| P1 | [Better Terrain](https://store.godotengine.org/asset/portponky/better-terrain/) | 표시 가격 없음, Unlicense, Godot 4.3+ | 비생산 맵 A/B 파일럿 | 2D 자연지형 반복 제작 절감 가능, v0.2·리뷰 0 위험 |
| P1 | [Dialogue Manager](https://store.godotengine.org/asset/nathanhoad/dialogue-manager/) | 표시 가격 없음, MIT, Godot 4.5+ | 한 시퀀스 변환 스파이크 후 결정 | 기능은 풍부하지만 기존 JSON 정본과 마이그레이션 충돌 가능 |
| P1 | [Sound FX Starter Pack Vol.1](https://store.godotengine.org/asset/ovani-sound/sound-fx-starter-pack-vol/) | 무료, 독점 royalty-free 상업 라이선스 | 약관 승인 후 선별 도입 | 누락 SFX 절감 가능, 라이선스 보관·재배포 금지 검토 필요 |

## 자율 진행 후보

- 위 항목의 다운로드·도입 없이 API, 라이선스와 통합 비용을 읽기 전용으로 비교한다.
- 전체 2D 아트팩은 고대 부여·고구려 화풍과 맞는 후보를 찾지 못했으므로 직접 제작·커미션 비교를 계속한다.
- 상업 RPG급 저장 복구 체계와 현재 오디오 큐 계약에 맞는 런타임은 적합 제품을 찾지 못해 자체 구현안을 우선 검토한다.

## 대기 결정

- `ASSET-2026-001`: Controls Remap + Action Icon + AutoSizeText 파일럿 도입 승인
- `ASSET-2026-002`: Ovani Sound FX Starter Pack의 독점 라이선스 수락 및 프로젝트 편입 승인
- `ASSET-2026-003`: Better Terrain 비생산 A/B 파일럿 승인
- `ASSET-2026-004`: Dialogue Manager 한 시퀀스 스파이크 승인
