---
description: Side 변경 요청 (Change Request) — 추가 요구의 In-Scope 침범 여부 자동 판정, 별도 견적 산출, 입금 확인 후 미니 1-5 사이클 실행.
argument-hint: 변경 요청 내용 (자연어, 길어도 됨)
allowed-tools: Read, Write, Bash, ExitPlanMode, AskUserQuestion, Glob
---

# Side — 변경 요청 (Change Request)

당신은 외주 프로젝트에 들어온 **추가 요구**를 처리합니다.
**핵심 원칙**: Out-of-Scope 요청은 무조건 별도 견적. 살라미식 추가 요구 방어.

## 입력
$ARGUMENTS

## 절차

### Step 1 — 컨텍스트 수집
- 프로젝트 루트 `CLAUDE.md` 읽기 (기획문서 In/Out-Scope)
- `./contracts/계약서-*.md` 읽기 (5조항 확인)
- `./acceptance/` 있으면 인수확인서 읽기 (인수 후 CR 여부)
- 메모리 `[[feedback-outsource-scope-protection]]` 인용

### Step 2 — In/Out-Scope 자동 판정

요청 내용을 §1-2-3 매트릭스로 판정:

| 신호 | 판정 |
|---|---|
| 기획문서 In-Scope 항목과 정확히 일치 | **하자보수 또는 추가 작업** (인수 전/후에 따라) |
| 기획문서 Out-of-Scope에 명시 | **명백한 CR (별도 견적 필수)** |
| In/Out 어디에도 없음 | **암묵적 CR** — 사용자 판단 필요 |
| In-Scope 기능의 "확장" (사용자 수/매장 수/디바이스) | **CR (별도 견적)** — 메모리 §4-O-13 인용 |
| 디자인 변경 | **CR** (시안 합의 이후 변경은 별도) |

판정이 모호하면 AskUserQuestion으로 사용자에게 1-2개 질문.

### Step 3 — 처리 분기

#### 분기 A — In-Scope (CR 아님)
- 일반 작업으로 진행 (인수 전이면 §4 개발, 인수 후면 하자보수)
- 사용자에게 "이건 In-Scope입니다. 별도 청구 없이 진행합니다" 보고
- 종료

#### 분기 B — Out-of-Scope (CR 확정)
미니 견적 산출:

```markdown
# CR-N 견적 — {요청 요약}

작성일: YYYY-MM-DD
원 프로젝트: {이름}
CR 번호: N (./change-requests/에서 자동 카운트)

## 1. 요청 내용
> [클라이언트 원문]

## 2. Out-of-Scope 판정 근거
- 기획문서 §4-O-XX: "..."
- 또는 계약서 §X: "..."
- 또는 인수확인서 §3 유상 범위 §X-X: "..."

## 3. 추가 범위 (이번 CR)
- ...

## 4. 추가 일정·금액
| 항목 | 금액 |
|---|---|
| 개발비 | ₩... |
| 토큰비·리스크 | ₩... |
| 합계 | ₩... (VAT 별도) |

추가 일정: 마일스톤 N개, 총 X주 추가

## 5. 결제
- 100% 선입금 (소액) 또는 50%-50% (대형)
- 입금 확인 후 미니 1→5 사이클 진입

## 6. 본 CR이 다루지 않는 것
- ...
```

저장: `./change-requests/CR-N-YYYY-MM-DD.md`

### Step 4 — ExitPlanMode 검토
사용자에게 CR 견적 검토 + 클라이언트 전달 권유.
ExitPlanMode 호출.

### Step 5 — 클라이언트 합의 + 입금
사용자가 클라이언트 합의·입금 확인 후 알리면:
- 입금 트래커 갱신 (`./change-requests/입금트래커-CR.md`)
- 미니 사이클 진입: §2 미니기획 → §4 개발 → §5 검수 → §7 배포

### Step 6 — 미니 1-5 사이클
원 프로젝트 워크플로의 축소판:
1. **미니 기획** — 원 CLAUDE.md에 §4 또는 별도 `cr-N.md`로 추가 범위 명문화
2. (디자인 필요 시 미니 디자인)
3. **미니 개발** — TaskCreate로 분해 후 commit 단위 구현
4. **미니 검수** — 영향받는 영역만 부분 `/전수검사`
5. **미니 배포** — Preview → Production (사용자 확인)

### Step 7 — CR 인수
- CR 인수확인서 (`./change-requests/CR-N-인수확인서.md`) — 원 인수확인서의 축소판
- 클라이언트 서명 후 잔금 청구

### Step 8 — 살라미 방어
- 같은 클라이언트가 짧은 기간(예: 30일) 내 CR 3건 이상 발생 시:
  - 사용자에게 알림: "추가 요구 패턴 — 정식 추가 외주 계약 또는 유지보수 월 계약 전환 권장"
  - 메모리 `[[feedback-outsource-pricing-strategy]]`의 "다음 정식 의뢰 우선 협상권" 회수 기회로 활용

## 모델 권장
**Opus 4.7** — In/Out 판정이 외주 책임 한계 직결. 정확도 최우선.
