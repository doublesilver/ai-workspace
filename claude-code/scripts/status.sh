#!/usr/bin/env bash
# SessionStart 단일 대시보드 (CCPM식 bash 추적 — LLM 토큰 0)
# 외주 디렉토리: 9단계 진행+게이트+다음행동, 그리고 git 현황.
# 일반 git repo: git 현황만. 둘 다 아니면 침묵.
set -u

in_git=0; git rev-parse --git-dir >/dev/null 2>&1 && in_git=1
is_out=0
{ [ -d ./intake ] || [ -d ./contracts ] || [ -f ./CLAUDE.md ] || [ -d ./uat ] || [ -d ./reports ]; } && is_out=1
[ "$in_git" = 1 ] || [ "$is_out" = 1 ] || exit 0

D="[v]"; T="[ ]"
mark() { [ -n "$1" ] && printf '%s' "$D" || printf '%s' "$T"; }

# ── 외주 진행 대시보드 ──
if [ "$is_out" = 1 ]; then
  S0=$(ls -1 ./intake/*.md 2>/dev/null | head -1)
  S1=$(ls -1 ./contracts/*.md 2>/dev/null | head -1)
  S2=$( [ -f ./CLAUDE.md ] && echo y )
  S3=$(ls -1 ./docs/design/* 2>/dev/null | head -1)
  S4=$( { [ -d ./src ] || [ -d ./app ] || [ -d ./lib ] || [ -d ./pages ]; } && echo y )
  S5=$(ls -1 ./reports/inspection-report-*.md 2>/dev/null | head -1)
  S6=$(ls -1 ./uat/*결과*.md 2>/dev/null | head -1)
  S7=$( git tag 2>/dev/null | grep -qiE 'prod|release|^v[0-9]' && echo y )
  S8=$(ls -1 ./acceptance/*인수확인서*.md 2>/dev/null | head -1)

  TRK=$(ls -1 ./contracts/입금트래커*.md 2>/dev/null | head -1)
  PAID=""; [ -n "$TRK" ] && grep '착수금' "$TRK" 2>/dev/null | grep -q '✅' && PAID=y
  UAT=$(ls -1t ./uat/*결과*.md 2>/dev/null | head -1)
  MISS=0; [ -n "$UAT" ] && MISS=$(grep -oE '미통과:[[:space:]]*[0-9]+' "$UAT" 2>/dev/null | tail -1 | grep -oE '[0-9]+'); MISS=${MISS:-0}

  echo "═══ 외주 진행상황 · $(basename "$PWD") ═══"
  echo "$(mark "$S0") 0 Discovery     $(mark "$S1") 1 견적·계약    $(mark "$S2") 2 기획"
  echo "$(mark "$S3") 3 디자인        $(mark "$S4") 4 개발         $(mark "$S5") 5 검수"
  echo "$(mark "$S6") 6 UAT           $(mark "$S7") 7 배포         $(mark "$S8") 8 인수"
  echo "─── 게이트 ───"
  [ -n "$PAID" ] && echo "$D 게이트① 착수금 확인됨" || echo "$T 게이트① 착수금 미확인 → 2단계(기획) 진입 불가"
  if [ -n "$UAT" ]; then
    [ "$MISS" -gt 0 ] && echo "$T 게이트② UAT 미통과 ${MISS}건 → Production 배포 불가" || echo "$D 게이트② UAT 전항목 통과"
  else echo "$T 게이트② UAT 결과 없음 (6단계 /UAT 필요)"; fi
  [ -n "$S5" ] && echo "최근 검수: $(basename "$S5")"
  echo "─── 다음 권장 행동 ───"
  if   [ -z "$S0" ]; then echo "→ 0단계: /인테이크 로 요구사항 정리"
  elif [ -z "$S1" ]; then echo "→ 1단계: /견적 으로 견적·계약서 작성"
  elif [ -z "$PAID" ]; then echo "→ 게이트①: 착수금 입금 확인 후 /입금확인 착수금"
  elif [ -z "$S2" ]; then echo "→ 2단계: /기획 으로 Living CLAUDE.md 작성"
  elif [ -z "$S5" ]; then echo "→ 4~5단계: 개발 진행 → /전수검사 로 검수"
  elif [ -z "$S6" ] || [ "$MISS" -gt 0 ]; then echo "→ 6단계: /UAT (미통과 0건까지)"
  elif [ -z "$S8" ]; then echo "→ 7~8단계: /배포-production → /인수"
  else echo "→ 인수 완료. /하자보수 모니터링 단계."; fi
fi

# ── git 현황 (git repo면 항상) ──
if [ "$in_git" = 1 ]; then
  [ "$is_out" = 1 ] && echo ""
  echo "─── git 현황 ───"
  ST=$(git status --short 2>/dev/null | head -15)
  [ -n "$ST" ] && echo "$ST" || echo "(작업트리 깨끗)"
  echo "최근 커밋:"
  git log --oneline -5 2>/dev/null
fi
