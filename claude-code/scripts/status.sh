#!/usr/bin/env bash
# 외주 진행상황 대시보드 — CCPM식 bash 추적 (LLM 토큰 0, 즉시 출력)
# 현 디렉토리 산출물을 스캔해 9단계 중 어디까지 왔는지 / 다음 / 막힌 게이트를 표시.
set -u

# 외주 프로젝트 신호가 없으면 조용히 종료 (홈·설정 디렉토리 등)
[ -d ./intake ] || [ -d ./contracts ] || [ -f ./CLAUDE.md ] || [ -d ./uat ] || [ -d ./reports ] || exit 0

D="[v]"; T="[ ]"
mark() { [ -n "$1" ] && printf '%s' "$D" || printf '%s' "$T"; }

# ── 단계별 산출물 판정 ──
S0=$(ls -1 ./intake/*.md 2>/dev/null | head -1)
S1=$(ls -1 ./contracts/*.md 2>/dev/null | head -1)
S2=$( [ -f ./CLAUDE.md ] && echo y )
S3=$(ls -1 ./docs/design/* 2>/dev/null | head -1)
S4=$( { [ -d ./src ] || [ -d ./app ] || [ -d ./lib ] || [ -d ./pages ]; } && echo y )
S5=$(ls -1 ./reports/inspection-report-*.md 2>/dev/null | head -1)
S6=$(ls -1 ./uat/*결과*.md 2>/dev/null | head -1)
S7=$( git tag 2>/dev/null | grep -qiE 'prod|release|^v[0-9]' && echo y )
S8=$(ls -1 ./acceptance/*인수확인서*.md 2>/dev/null | head -1)

# ── 게이트 상태 ──
TRK=$(ls -1 ./contracts/입금트래커*.md 2>/dev/null | head -1)
PAID=""
[ -n "$TRK" ] && grep '착수금' "$TRK" 2>/dev/null | grep -q '✅' && PAID=y
UAT=$(ls -1t ./uat/*결과*.md 2>/dev/null | head -1)
MISS=0
[ -n "$UAT" ] && MISS=$(grep -oE '미통과:[[:space:]]*[0-9]+' "$UAT" 2>/dev/null | tail -1 | grep -oE '[0-9]+')
MISS=${MISS:-0}

echo "═══ 외주 진행상황 · $(basename "$PWD") ═══"
echo "$(mark "$S0") 0 Discovery     $(mark "$S1") 1 견적·계약    $(mark "$S2") 2 기획"
echo "$(mark "$S3") 3 디자인        $(mark "$S4") 4 개발         $(mark "$S5") 5 검수"
echo "$(mark "$S6") 6 UAT           $(mark "$S7") 7 배포         $(mark "$S8") 8 인수"
echo ""
echo "─── 게이트 ───"
[ -n "$PAID" ] && echo "$D 게이트① 착수금 확인됨" || echo "$T 게이트① 착수금 미확인 → 2단계(기획) 진입 불가"
if [ -n "$UAT" ]; then
  [ "$MISS" -gt 0 ] && echo "$T 게이트② UAT 미통과 ${MISS}건 → Production 배포 불가" || echo "$D 게이트② UAT 전항목 통과"
else
  echo "$T 게이트② UAT 결과 없음 (6단계 /UAT 필요)"
fi
echo ""
echo "─── 다음 권장 행동 ───"
if   [ -z "$S0" ]; then echo "→ 0단계: /인테이크 로 요구사항 정리"
elif [ -z "$S1" ]; then echo "→ 1단계: /견적 으로 견적·계약서 작성"
elif [ -z "$PAID" ]; then echo "→ 게이트①: 착수금 입금 확인 후 /입금확인 착수금"
elif [ -z "$S2" ]; then echo "→ 2단계: /기획 으로 Living CLAUDE.md 작성"
elif [ -z "$S5" ]; then echo "→ 4~5단계: 개발 진행 → /전수검사 로 검수"
elif [ -z "$S6" ] || [ "$MISS" -gt 0 ]; then echo "→ 6단계: /UAT (미통과 0건까지)"
elif [ -z "$S8" ]; then echo "→ 7~8단계: /배포-production → /인수"
else echo "→ 인수 완료. /하자보수 모니터링 단계."
fi
