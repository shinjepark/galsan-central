# 중앙하이츠 갈산역 센트럴 — Cloudflare Pages 배포 가이드

기존에 운영하던 더샵 송도그란테르 랜딩페이지와 **동일한 파일 구성 · 동일한 운영 방식**으로 제작되었습니다.

## 1. 폴더 구성

```
galsan/
├── index.html            메인 (히어로·프리미엄·단지배치·평면·입지·사업개요·FAQ·관심고객 등록)
├── images/               이미지 (전체 WebP · hero/danji/unitmap/unit3d/traffic/life/complex/fitness)
├── og_image.jpg          카카오톡·SNS 공유 썸네일 (1200×630)
├── admin.html            관리자 페이지 (신청내역·집계·CSV·수정·삭제)
├── thankyou.html         등록 완료 페이지 (광고 전환 발화 지점)
├── oc-pixel-config.js    광고 채널 전환추적 설정 (index·thankyou 공유)
├── schema.sql            D1 테이블 생성 스크립트
├── _headers              관리자·완료페이지 검색 제외 + 캐시 설정
└── functions/
    ├── submit.js         POST /submit  →  D1 저장 + 텔레그램 알림 + 카운터 +1
    ├── admin.js          POST /admin   →  비밀번호 확인 후 조회/수정/삭제 + 집계
    ├── count.js          GET  /count   →  현재 등록 수 (말풍선 숫자)
    └── visit.js          POST /visit   →  방문 세션 기록 (하루 1회·봇 제외)
```

## 2. 데이터 흐름 (기존 방식과 동일)

```
방문자가 이름·연락처·연락가능시간 입력 후 [관심고객 등록하기]
  → POST /submit (이름·연락처·연락가능시간 + 유입경로·utm·event_id·접속페이지)
     ├── ① D1 에 1건 저장        → admin.html 에서 조회
     ├── ② 카운터 +1            → 하단 말풍선 숫자에 반영
     └── ③ 텔레그램 알림 전송    → 기존 채팅방에 즉시 도착
  → thankyou.html 이동 (?ch=유입경로&eid=이벤트ID) — 여기서 광고 채널 전환(Lead) 발화
```

## 3. D1 생성

```bash
npx wrangler d1 create galsan-central
npx wrangler d1 execute galsan-central --remote --file=./schema.sql
```

테이블: `leads`(신청내역) · `visits`(방문 세션) · `stats`(카운터)

## 4. 환경변수 · 바인딩 (Pages → Settings → Variables and Secrets)

| 종류 | 이름 | 값 |
|---|---|---|
| Secret | `TG_BOT_TOKEN` | 기존 텔레그램 봇 토큰 (그대로 재사용) |
| Secret | `TG_CHAT_ID` | 기존 알림 채팅방 ID (그대로 재사용) |
| Secret | `ADMIN_PASSWORD` | 관리자 페이지 비밀번호 (신규 지정) |
| 선택 | `SITE_NAME` | 텔레그램 알림 표기명 (미지정 시 "중앙하이츠 갈산역 센트럴") |

Functions → D1 database bindings: `DB` ← galsan-central (변수명 `DB` 그대로)

## 5. 광고 픽셀

`oc-pixel-config.js` 에 기존 채널 ID를 그대로 넣으면 index(방문)·thankyou(전환)에 동시 적용됩니다.
빈 값인 채널은 아무 스크립트도 불러오지 않습니다.

## 6. 배포 후 확인할 것

- [ ] index.html `<head>` 안 `og:image` / `og:image:secure_url` 두 줄을 실제 배포 도메인으로 수정
- [ ] `https://<배포주소>/` 접속 → 히어로·이미지 정상 노출
- [ ] 관심고객 등록 1건 테스트 → 텔레그램 알림 도착 + admin.html 에서 확인
- [ ] 하단 말풍선 카운터 노출 (등록 1건부터 표시)
