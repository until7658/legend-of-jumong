# 무료 음악·효과음 조달 및 출처 정책

## 목적

Steam 유료 PC 게임에 포함할 BGM과 효과음은 필요에 따라 무료 음원 사이트에서 조사·다운로드할 수 있다. 무료 표시는 권리 확인을 대신하지 않으며, 사이트가 아니라 개별 파일 단위로 판단한다.

## 채택 순서

1. 직접 제작 또는 커미션·구매 비교
2. 출처와 권리가 명확한 CC0
3. CC BY 4.0
4. 사이트 자체 무료 라이선스

CC0만 승인된 오디오 작업 범위 안에서 자율 도입할 수 있다. CC BY, 사이트 자체 라이선스, 로그인 필요, Content ID, 생성형 AI, 인물 음성과 독점 조항은 일일 보고서의 결정 게이트로 올린다.

CC BY-NC, CC BY-ND, personal/editorial-only, Sampling+, 출처 불명, 게임·영상 리핑과 권리 불명 샘플은 사용하지 않는다. 원본 단독 재배포를 금지하는 파일은 공개 Git 저장소에 커밋하지 않으며 별도 보관·Steam 패키징 계획을 승인받기 전 도입하지 않는다.

## 출처 대장 필수 필드

- 내부 asset/cue ID, 제목, 제작자·업로더
- 정확한 파일 페이지 URL, 라이선스 이름·버전과 공식 URL
- 다운로드 일시(Asia/Seoul), 원본 파일명과 SHA-256
- 상업 이용, 수정, Steam 배포, 원본 재배포와 저작자 표시 조건
- 생성형 AI 표시, Content ID·인증서, 인물 음성·제3자 샘플 여부
- 변환·루프 편집 내역, 게임 내 사용 위치
- 검토자와 상태(`후보/승인/보류/폐기`)

저작자 표시가 필요한 파일은 게임 내 Credits와 배포용 제3자 고지에서 오프라인으로 확인할 수 있게 기록한다.

## 공식 후보 소스

| 우선순위 | 소스 | 기본 판단 | 공식 근거 |
| ---: | --- | --- | --- |
| 1 | Kenney Audio | 개별 페이지 CC0 확인 후 SFX 우선 후보 | [지원·라이선스](https://kenney.nl/support), [RPG Audio](https://kenney.nl/assets/rpg-audio) |
| 2 | Freesound | 사용자 업로드형이므로 CC0만 우선, 로그인·GenAI 태그 확인 | [라이선스 FAQ](https://freesound.org/help/faq/) |
| 3 | Incompetech | BGM 후보, CC BY 4.0 크레딧 필요 | [공식 라이선스](https://incompetech.com/music/royalty-free/licenses/) |
| 보류 | Pixabay | 원본 재배포·업로더 권리·AI·Content ID 위험 별도 승인 | [라이선스](https://pixabay.com/service/license-summary/), [Content ID FAQ](https://pixabay.com/service/faq/) |
| 보류 | ZapSplat | 표시·로그인·파일 형식·원본 재배포 조건 별도 승인 | [Standard License](https://www.zapsplat.com/license-type/standard-license/) |
| 보류 | Mixkit | 사이트 자체 라이선스와 재배포 조건 별도 승인 | [라이선스](https://mixkit.co/license/) |
| 보류 | OpenGameArt | CC0만 우선, BY·BY-SA·GPL은 Steam 패키징 별도 검토 | [라이선스 FAQ](https://opengameart.org/node/5571) |

실제 다운로드는 큐 요구사항을 먼저 정의한 뒤 수행한다. 라이선스 캡처·해시·출처 대장 없이 `assets/audio/`에 포함하지 않는다.
