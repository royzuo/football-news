---
name: football-daily-brief
description: Generate a daily football brief for the last 24h time window (yesterday 08:00 → today 08:00 Asia/Shanghai) with strict source links + publish times, in four modules (Morning / Reminders / Injuries / Transfer). Use when producing the daily QQ-ready brief and publishing it to a GitHub repo (write markdown to briefs/football/YYYY-MM-DD.md, then commit & push). Also use when debugging hallucinations by enforcing source whitelists, time-window checks, and Sky Sports liveblog item extraction.
---

# Football Daily Brief

## Workflow (deterministic, citation-first)

### Step 0 — Preconditions
- `BRAVE_API_KEY` is configured (for `web_search`).
- `GITHUB_TOKEN` is available (for `git push`).
- Repo layout:
  - output file: `briefs/football/YYYY-MM-DD.md`
  - skill folder: `skills/football-daily-brief/`

### Step 1 — Define the time window (hard rule)
- Window is **Asia/Shanghai**:
  - `start = yesterday 08:00`
  - `end = today 08:00`
- Any item without a clear publish time/date (or that fails the window) is **dropped**, never “filled in”.

### Step 2 — Collect sources (only what you can verify)
Use `web_search` with `freshness=day` and *site filters*.

Recommended whitelist (adjust as needed):
- Core: `bbc.com`, `aljazeera.com`, `nbcsports.com`, `skysports.com`
- Optional: `uefa.com` (may block fetch; treat as best-effort)

For each candidate URL:
- Use `web_fetch` to read content.
- Extract publish time from:
  - explicit “Published …” text,
  - URL date (e.g. `/2026/3/16/…`) **only when the site’s permalink is date-based**,
  - or the page’s own visible timestamp.
- Store: `title`, `url`, `published_time`, `1–2 sentence facts`.

### Step 3 — Build the brief (format locked)
Write Markdown using `references/brief_template.md`.

Rules:
- 4 modules:
  1) 📰 晨讯
  2) ⏰ 提醒
  3) ⚠️ 伤停
  4) 🔮 转会流言
- Each module: **up to 3 items**.
- Each item:
  - has `来源 + 链接 + 发布时间`
  - description is **≤150 Chinese chars**.

### Step 4 — Special handling: Sky Sports liveblog (no “入口链接”)
If a source is a liveblog (e.g. Sky Sports transfer live):
- Do **NOT** link the live index.
- Use browser automation to extract concrete `article` items with:
  - the article headline,
  - its relative/absolute time shown on page,
  - the **Copy link** URL containing `?postid=...`.
- Pick 1–3 relevant items (transfer/contract/leaving/targeting).

### Step 5 — Save, commit, push
- Write file to: `briefs/football/YYYY-MM-DD.md`.
- `git add` → `git commit` → `git push`.
- Never print tokens. If auth is needed, use a header-based push (no token in command line history).

## Resources

### references/
- `brief_template.md` — the canonical brief structure.

### scripts/
- `git_publish.sh` — safe commit/push helper (expects `GITHUB_TOKEN`).
