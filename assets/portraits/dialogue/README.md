# 대화 초상화 사용 규칙

- 경로: `res://assets/portraits/dialogue/{character_id}/{expression_id}.png`
- 표정 목록과 기본값: `res://data/characters/dialogue_portraits.json`
- 파일 형식: 투명 배경 PNG, 가슴 위 3/4 구도
- 대사 데이터에는 표시 이름이 아니라 `character_id`와 `expression_id`를 기록한다.
- 표정이 지정되지 않았거나 찾을 수 없으면 해당 인물의 `default` 표정을 사용한다.
- 인물의 좌우 배치는 UI가 담당한다. 원본 PNG를 임의로 뒤집어 별도 파일로 복제하지 않는다.
- 이번 세트는 프롤로그와 제1장 기준이다. 이후 장의 표정은 같은 인물 폴더에 상태명으로 추가한다.

예시:

```json
{"speaker_id":"jumong","expression_id":"determined","line":"살아서 돌아오겠습니다."}
```
