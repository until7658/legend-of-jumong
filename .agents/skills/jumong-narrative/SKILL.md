---
name: jumong-narrative
description: 주몽신화전기의 메인 시나리오, 퀘스트, 컷신 사건, 대사, 로어, 역사 용어와 각색 기록을 설계하고 구조화한다. 서사 문서나 narrative 데이터·스크립트를 생성 또는 수정하거나 캐릭터 감정선과 분기를 검토할 때 사용한다.
---

# 주몽 서사

## 작업 절차

1. `AGENTS.md`와 `$jumong-production-governor`의 전체 2D 원칙을 확인한다.
2. 원사료 명칭, 기존 시나리오 바이블, 관계·복선 문서를 먼저 조사한다.
3. 사건 목적, 플레이어 경험, 진입·종료 조건과 필요한 2D 연출을 계획한다.
4. 대사와 이벤트 데이터를 코드에서 분리한다.
5. 승인된 범위만 구현하고 `$jumong-verify`에 기대 흐름을 전달한다.

## 소유 영역

- `docs/narrative/`
- `data/narrative/`
- `scripts/narrative/`
- `scenes/narrative/`

## 협업 경계

- 맵 배치와 Camera2D 연출은 `$jumong-level-2d`에 전달한다.
- 캐릭터 외형·액터 구현은 `$jumong-character`와 `$jumong-2d-art`에 전달한다.
- 전투 수치와 승패 규칙은 `$jumong-combat`에 전달한다.
- BGM·효과음 타이밍은 `$jumong-audio`에 큐 요구사항으로 전달한다.

## 품질 기준

- 사실, 전승, 게임 각색을 구분한다.
- 인명·지명·호칭을 일관되게 사용한다.
- 모든 컷신 지시는 2D 화면 구성으로 작성한다.
- 실제 포함되는 AI 생성 대사와 로어는 AI 콘텐츠 대장에 기록한다.
