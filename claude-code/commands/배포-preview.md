---
description: 7단계 배포 — Preview/Staging 환경에 자동 배포 (확인 없이 진행 가능). Vercel/Railway 자동 감지.
allowed-tools: Read, Bash, Grep, Glob
---

# Preview 배포

Production이 아닌 안전한 환경에 자동 배포.

## 절차

### Step 1 — 사전 점검
- 변경되지 않은 commit이 있는지 확인 (`git status` 깨끗한지)
- 깨끗하지 않으면 사용자에게 보고 후 중단

### Step 2 — 배포 도구 감지
- `vercel.json` 또는 `.vercel/` → Vercel 사용
- `railway.json` 또는 `railway.toml` → Railway 사용
- 둘 다 없으면 사용자에게 어떤 도구 쓸지 질문

### Step 3 — 가벼운 검수 (빠른 / Opus 안 씀)
배포 전 자동 점검:
- `npm run build` 또는 동등 명령 성공하는지
- 환경변수 누락 없는지 (.env.example 대비)
- 린트 통과하는지

실패 시 중단하고 보고. 우회 절대 금지.

### Step 4 — 배포 실행
- Vercel: `vercel` (preview)
- Railway: `railway up --service <service-name>` (preview environment)

### Step 5 — 결과 보고
- Preview URL 표시
- 배포 시간
- 클라이언트 공유용 한 줄 메시지 한국어로 생성:
  "[프로젝트명] 미리보기가 준비됐습니다: <URL>"

## Production 배포가 필요하면
`/배포-production`을 안내. 절대 자동으로 production 배포하지 않음.
