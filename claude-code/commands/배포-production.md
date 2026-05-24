---
description: 7단계 배포 — Production 배포. 필수 사전 검수 + CI green + 사용자 명시 확인 후 진행.
allowed-tools: Read, Bash, Grep, Glob, Agent, ExitPlanMode
---

# Production 배포 (책임 가중)

이것은 **클라이언트가 직접 보는 환경**입니다. 한 번 잘못되면 외주 책임이 발생합니다.
다음 절차를 **빠짐없이** 수행합니다.

## 필수 사전 절차

### Step 0 — §11 게이트 ② UAT 통과 확인 (★ v2.0)
- `./uat/*결과*.md` 파일 존재 확인
- 없으면 중단: "먼저 `/UAT`로 클라이언트 인수시험을 진행하세요."
- `grep -c '❌ 미통과' ./uat/*-결과.md` 결과가 0이어야 진행
- 미통과 항목이 1건이라도 있으면 **즉시 중단** 후 미통과 목록 사용자에 보고
- (참고) settings.json PreToolUse hook이 `vercel --prod` / `railway up`을 동일 기준으로 차단합니다 — 이 스킬은 hook 도달 전 사전 안내.

### Step 1 — 검수 이력 확인
- 최근 24시간 내 `/전수검사`가 실행됐는지 확인 (보고서 파일 존재 여부)
- 없으면 중단하고 사용자에게: "전수검사를 먼저 실행해주세요."
- 검수 보고서에 Critical/High 이슈가 남아있으면 중단

### Step 1.5 — CI green 확인 (★ §15.2 게이트)
- CI 파이프라인(GitHub Actions 등)이 최신 commit 기준 **green(성공)**인지 확인: `gh run list --branch <branch> --limit 1` 또는 워크플로 상태 조회
- lint·typecheck·test·build 중 하나라도 실패(red)면 **즉시 중단** → §11 "CI 실패 상태 배포 금지"에 의해 차단, 사용자에 실패 잡 보고
- CI 파이프라인이 아예 없는 repo면: "CI 미구성 — §15.2 위반. 배포 전 최소 파이프라인 구성을 권장합니다" 경고 후 사용자 판단 요청

### Step 2 — 기획 준수 최종 확인
plan-compliance-checker 에이전트를 1회 더 호출 → 모든 In-Scope 완료 확인

### Step 3 — Preview 환경 동작 확인
- 최근 Preview 배포 URL이 실제 동작하는지 (가능하면 curl로 health check)
- 사용자에게 "Preview에서 직접 확인하셨나요?" 명시 질문 (AskUserQuestion)

### Step 4 — 롤백 계획 준비
- 이전 production 버전 (commit SHA) 기록
- 롤백 명령 미리 작성 (Vercel: `vercel rollback`, Railway: `railway rollback`)

### Step 5 — ExitPlanMode 필수
다음 정보를 plan으로 정리해 사용자 승인 받음:
- 배포 대상: 서비스명 + 환경 + commit SHA
- 변경 요약
- 검수 결과 요약 (Critical 0건 확인)
- 롤백 계획
- 예상 다운타임

### Step 6 — 사용자 명시 승인 후에만 배포
승인 후:
- Vercel: `vercel --prod`
- Railway: `railway up --service <service-name> --environment production`

### Step 7 — 배포 후 모니터링 + 자동 롤백 (★ §15.2)
- 배포 직후 health check (production URL `curl` 등)
- 5분간 에러 로그 확인 (Sentry / Vercel / Railway logs)
- **자동 롤백 트리거**: health check 실패 또는 에러율 급증 감지 시 → 사용자에 즉시 알리고 Step 4의 롤백 명령(`vercel rollback` / `railway rollback`)으로 **직전 버전 복귀**. "괜찮아지겠지" 판단 금지 — 이상 징후면 롤백이 기본값.
- 정상 확인 후 클라이언트 보고서 자동 생성 (`~/.claude/templates/진행보고서.md` 활용)

## 절대 금지
- 검수 없이 바로 배포
- ExitPlanMode 생략
- "괜찮을 거예요" 식 자가 판단 → 반드시 사용자 승인
