---
name: jumong-level-2d
description: 주몽신화전기의 전체 2D 필드, 마을, 전투 공간, 이동 동선, 조우, TileMapLayer, Camera2D와 컷신 무대를 설계하고 구현한다. 맵 씬이나 level_map 스크립트·데이터를 변경하거나 기존 HD-2D·3D 구성을 2D로 전환할 때 사용한다.
---

# 주몽 2D 레벨

## 전체 2D 규칙

- `Node2D`, `TileMapLayer`, `CharacterBody2D`, `Area2D`, `Camera2D`, `CanvasItem` 계열을 사용한다.
- `Node3D`, `Camera3D`, 3D 조명·물리·메시를 새로 도입하지 않는다.
- 깊이감은 레이어 순서, Y 정렬, 원근형 스케일 규칙, 패럴랙스, 안개·색보정 2D 효과로 표현한다.
- 기존 HD-2D·3D 테스트 씬은 명시적 승인 없이 확장하지 않는다.

## 소유 영역

- `scenes/maps/`
- `scripts/level_map/`
- `data/maps/`

## 작업 절차

1. 서사 목적과 이동·조우 요구사항을 확인한다.
2. 화면 단위 레이아웃, 충돌, 진입점, Camera2D 범위와 레이어 구조를 계획한다.
3. 동일 맵 씬의 단일 소유권을 유지한다.
4. 2D 캐릭터 실루엣과 상호작용 가독성을 우선한다.
5. 변경 후 Godot 재탐색과 관련 씬 검증을 요청한다.

## 협업 경계

- 사건·대사 데이터는 `$jumong-narrative`가 소유한다.
- 배경·타일·프롭 이미지는 `$jumong-2d-art`가 제작한다.
- 공통 장면 전환은 `$jumong-core-systems`가 소유한다.
