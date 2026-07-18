---
name: jumong-character
description: 주몽신화전기의 파티, NPC, 적 캐릭터 설정과 데이터, 2D 액터 씬, 애니메이션 상태, 성장 구조를 설계하고 통합한다. character 문서·데이터·씬·스크립트를 만들거나 캐릭터 역할과 스프라이트 요구사항을 정의할 때 사용한다.
---

# 주몽 캐릭터

## 소유 영역

- `docs/characters/`
- `data/characters/`
- `scenes/characters/`
- `scripts/characters/`

## 작업 절차

1. 서사상 역할, 감정선, 전투 역할과 필요한 2D 동작을 확인한다.
2. 데이터, 액터 로직, 시각 애셋 요구사항을 분리한다.
3. 상태·방향·프레임 규격과 씬 연결 계획을 먼저 제출한다.
4. 정적 타입과 명시적인 애니메이션 상태를 사용한다.
5. 관련 씬 로드와 화면 검증 기준을 `$jumong-verify`에 전달한다.

## 협업 경계

- 원본 스프라이트와 애니메이션 시트는 `$jumong-2d-art`가 소유한다.
- 스킬 수치·데미지·전투 상태는 `$jumong-combat`가 소유한다.
- 대사와 관계 변화는 `$jumong-narrative`가 소유한다.
- 필드 충돌과 맵 배치는 `$jumong-level-2d`가 소유한다.

## 전체 2D 기준

- 캐릭터는 Sprite2D·AnimatedSprite2D 등 2D 노드로 통합한다.
- 3D 모델, 3D 리깅 또는 3D 물리를 제작 기준으로 도입하지 않는다.
