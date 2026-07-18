# 분대 교전 계산·연출 계약 v1

## 목적과 경계

`SquadCombatResolver`는 분대 교전 한 번의 결과를 결정론적으로 계산한다. 전술 맵 컨트롤러는 계산 전 스냅샷을 전달하고, 계산 후 반환된 분대 상태를 정본으로 반영한다. 2D 교전 컷인과 승인된 3D 미니 필드 배경 버전은 모두 동일한 `payload`만 읽는다.

연출 계층은 피해, 상성, 방어, 병사 감소나 승패를 다시 계산하지 않는다. 컷인을 건너뛰거나 2D 폴백으로 전환해도 계산 결과는 변하지 않는다. 3D 배경은 전투 충돌·물리·내비게이션을 소유하지 않는다.

## 계산 입출력

```gdscript
var result := SquadCombatResolver.resolve_clash(attacker, defender, distance, rules)
```

입력 사전은 변경되지 않는다. 반환 사전은 다음 값을 가진다.

| 키 | 의미 |
|---|---|
| `attacker` | 계산 후 공격자 스냅샷. 현재 규칙에서는 공격 전과 동일하다. |
| `defender` | 병사·지휘관 기세를 반영한 계산 후 방어자 스냅샷 |
| `payload` | 컷인·HUD·오디오가 소비하는 버전 고정 데이터 |
| `raw_damage` | 기본 피해와 상성 보너스의 합 |
| `defend_reduction` | 대열 방어가 감소시킨 예정치 |
| `resolved_damage` | 방어 적용 후 분대에 전달된 피해 |
| `soldier_damage` | 병사 기세가 흡수한 피해와 제압·후퇴 인원 |
| `commander_damage` | 병사 기세 소진 뒤 지휘관에게 적용된 피해 |

## M4 결정 규칙

1. 기본 피해는 `2`다.
2. 궁병이 창병을 거리 2칸 이상에서 공격하면 거리 우위 `+2`다.
3. 창병이 궁병을 인접 거리 1칸에서 공격하면 인접 우위 `+2`다.
4. 방어 중인 분대는 최종 피해를 `1` 줄인다. 피해는 0 미만이 되지 않는다.
5. 병사 기세가 피해를 먼저 흡수하며, 흡수한 만큼 병사 수가 감소한다.
6. 병사 기세를 초과한 피해만 지휘관 기세를 줄인다.
7. 훈련전의 감소 병사는 사망자가 아니라 제압되어 후퇴한 인원이다.

입력 데이터의 `rules.soldier_count_range`는 정식 데이터가 병사 6~12명을 허용한다는 검증 범위다. M4 조우의 양측 시작 병력은 각각 8명이다.

## 컷인 payload v1

다음 필드는 필수다.

| 필드 | 형식 | 설명 |
|---|---|---|
| `payload_version` | int | 현재 `1` |
| `attacker_id`, `defender_id` | String | 분대 식별자 |
| `attacker_troop_type`, `defender_troop_type` | String | 병종 식별자 |
| `attacker_soldiers_before`, `attacker_soldiers_after` | int | 공격자 표시 인원 |
| `defender_soldiers_before`, `defender_soldiers_after` | int | 방어자 표시 인원 |
| `commander_damage` | int | 방어 지휘관 기세 감소량 |
| `distance` | int | 계산에 사용한 맨해튼 거리 |
| `advantage` | String | `range`, `adjacent`, `none` 중 하나 |
| `nonlethal` | bool | 비살상 제압·후퇴 연출 여부 |

연출은 `before` 인원으로 시작해 타격 시점에 `after` 인원으로 전환하고, `nonlethal == true`이면 쓰러짐·사망 표현 대신 전열 이탈과 후퇴를 사용한다. `presentation_finished` 뒤에만 컨트롤러가 다음 전투 상태로 진행한다.

## 통합 체크

- 컨트롤러는 공격자와 방어자 모두 같은 resolver를 호출한다.
- 컨트롤러는 반환된 `defender` 전체를 정본 상태로 반영한다.
- 2D 컷인과 하이브리드 배경 컷인에 서로 다른 계산 경로를 만들지 않는다.
- 스킵·고속 재생·2D 폴백 전환 전후의 payload와 최종 스냅샷을 비교한다.
- UI·오디오·연출은 payload에 새 수치를 덧셈하거나 차감하지 않는다.
