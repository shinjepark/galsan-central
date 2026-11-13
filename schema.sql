-- 중앙하이츠 갈산역 센트럴 : 관심고객 / 방문 DB (Cloudflare D1)
--   npx wrangler d1 create galsan-central
--   npx wrangler d1 execute galsan-central --remote --file=./schema.sql

CREATE TABLE IF NOT EXISTS leads (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  created_at   TEXT NOT NULL,          -- KST 'YYYY-MM-DD HH:MM:SS'
  name         TEXT NOT NULL,
  phone        TEXT NOT NULL,
  contact_time TEXT,                   -- 연락가능 시간
  channel      TEXT,                   -- 유입경로 (카카오톡 / 인스타그램 / 네이버 ...)
  utm_source   TEXT,
  utm_medium   TEXT,
  utm_campaign TEXT,
  referrer     TEXT,
  event_id     TEXT,                   -- 픽셀 중복 집계 방지용 (메타 event_id)
  page_url     TEXT
);
CREATE INDEX IF NOT EXISTS idx_leads_created ON leads (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_leads_phone   ON leads (phone);

-- 방문(세션) 집계 — 전환율 계산용
CREATE TABLE IF NOT EXISTS visits (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  created_at   TEXT NOT NULL,
  day          TEXT NOT NULL,          -- KST 'YYYY-MM-DD'
  channel      TEXT,
  utm_source   TEXT,
  utm_medium   TEXT,
  utm_campaign TEXT,
  referrer     TEXT,
  page_url     TEXT,
  vid          TEXT,                   -- 방문자 식별자 (localStorage)
  is_new       INTEGER                 -- 1 = 신규 방문자
);
CREATE INDEX IF NOT EXISTS idx_visits_day ON visits (day DESC);
CREATE INDEX IF NOT EXISTS idx_visits_vid ON visits (vid);

-- 카운터 (하단 말풍선 숫자). v 를 원하는 시작값으로 바꾸면 그 값부터 시작합니다.
CREATE TABLE IF NOT EXISTS stats (
  k TEXT PRIMARY KEY,
  v INTEGER NOT NULL
);
INSERT INTO stats (k, v) VALUES ('reservations', 0) ON CONFLICT(k) DO NOTHING;
