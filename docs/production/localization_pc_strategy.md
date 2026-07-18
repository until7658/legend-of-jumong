# Steam PC 다국어·기술 기반 전략

## 현재 결정과 가설

- 전체 2D Godot 4.7.1, GL Compatibility, 정적 타입 GDScript를 기본 기술 스택으로 유지한다.
- 기준 캔버스는 1280×720으로 유지하고 `canvas_items`·`expand`로 1280×800 Steam Deck, 16:9, 16:10과 울트라와이드를 별도 검증한다.
- 1차 출시 가설은 한국어 원문과 영어 인터페이스·자막이다. 추가 언어는 중국어 간체, 일본어, 중국어 번체 순으로 상점 관심도·번역 견적·QA 역량을 비교한다.
- 초기 음성은 공통 비언어 음성·효과음 또는 무음성을 우선하고 핵심 정보는 항상 자막으로 제공한다.

지원 언어 확정, 공식 영문 제목·고유명사 표기, 번들 폰트, 네이티브 Linux 빌드는 사용자 결정 게이트다.

## 현지화 구조

1. `localization/messages.pot`, `ko.po`, `en.po`의 gettext 카탈로그를 사용한다.
2. 키는 `ui.title.new_game`, `story.prologue.cut.001.caption`처럼 의미 기반으로 정의한다.
3. 기존 JSON 한국어 필드는 즉시 제거하지 않고 `caption_key`, `speaker_key`, `title_key`를 병행해 점진적으로 이관한다.
4. 언어 메뉴는 `자동 / 한국어 / English`를 제공하고 사용자 설정에 저장한다.
5. 한국어·영어 카탈로그 완성 전에는 한국어를 임시 폴백으로 사용하고, 글로벌 출시 빌드에서는 검증된 영어 카탈로그를 폴백으로 전환한다.
6. 영어 130~150% 길이 의사 현지화, CJK 줄바꿈, 누락 글리프, 잘림, 입력 글리프를 검사한다.
7. 상점 설명은 추가 언어로 시험 번역할 수 있지만 실제 게임 지원이 준비되기 전 Steam 지원 언어로 표시하지 않는다.

공식 참고: [Godot 국제화](https://docs.godotengine.org/en/stable/tutorials/i18n/internationalizing_games.html), [gettext 현지화](https://docs.godotengine.org/en/latest/tutorials/i18n/localization_using_gettext.html)

## PC·Steam Deck 기준

- 키보드·마우스와 Xbox·PlayStation·Steam Deck 계열 게임패드의 재매핑 가능한 액션을 제공한다.
- 1280×720, 1280×800, 1920×1080, 2560×1440과 울트라와이드에서 UI 안전영역을 검사한다.
- UI 배율·텍스트 크기, 30/60fps 제한, VSync, BGM/SFX/음성 개별 음량을 PC 옵션 범위로 둔다.
- Windows Desktop x86_64와 Proton을 1차 검증 대상으로 하고 네이티브 Linux 빌드는 QA 여력 확보 후 결정한다.
- Windows 내보내기 프리셋, 제품 버전, 아이콘, Steam App ID는 출시 준비 마일스톤에서 승인 후 추가한다.

공식 참고: [Godot 다중 해상도](https://docs.godotengine.org/en/latest/tutorials/rendering/multiple_resolutions.html), [Steam Deck 호환성](https://partner.steamgames.com/doc/steamhardware/compat)

## 구현 언어 판단

- GDScript: 현재 게임 로직의 기본 언어로 유지한다. 전체 2D 턴제 RPG에 충분하고 기존 코드·빌드 흐름을 보존한다.
- C#: 전면 전환하지 않는다. .NET Godot와 내보내기 복잡도를 상쇄하는 검증된 라이브러리 이점이 있을 때 기능 단위로만 검토한다.
- C++: 게임 로직 전환에 사용하지 않는다. 프로파일러로 확인된 병목 또는 대체 불가능한 네이티브 SDK가 있을 때 GDExtension으로 제한한다.
- Steam 연동: GodotSteam 같은 검증된 GDExtension은 언어 전환과 별개로 검토하며 새 런타임 의존성 결정 게이트를 거친다.

공식 참고: [Godot 기능과 지원 언어](https://docs.godotengine.org/en/stable/about/list_of_features.html)
