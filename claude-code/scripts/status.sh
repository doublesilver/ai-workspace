#!/usr/bin/env bash
# SessionStart 단일 대시보드 (CCPM식 bash 추적 — LLM 토큰 0)
# 견고성: 셸 무관(글롭 1개/테스트), retrofit(틀 도입 전 시작) 및 비표준 위치 인식.
set -u

has_md() { ls "$1"/*.md >/dev/null 2>&1; }   # 디렉토리에 .md 존재?

in_git=0; git rev-parse --git-dir >/dev/null 2>&1 && in_git=1
is_out=0
{ [ -d ./intake ] || [ -d ./contracts ] || [ -f ./CLAUDE.md ] || [ -d ./uat ] || [ -d ./reports ] || [ -d ./docs/uat ]; } && is_out=1
[ "$in_git" = 1 ] || [ "$is_out" = 1 ] || exit 0

D="[v]"; T="[ ]"
mark() { [ -n "$1" ] && printf '%s' "$D" || printf '%s' "$T"; }

if [ "$is_out" = 1 ]; then
  RETRO=""
  if [ -f ./CLAUDE.md ] && grep -qE '계약금|착수금|견적|In-Scope|Out-of-Scope' ./CLAUDE.md 2>/dev/null && [ ! -d ./contracts ]; then RETRO=y; fi

  S0=$( has_md ./intake && echo y )
  S1=$( has_md ./contracts && echo y )
  S2=$( [ -f ./CLAUDE.md ] && echo y )
  S3=$( [ -d ./docs/design ] && echo y )
  S4=$( { [ -d ./src ] || [ -d ./app ] || [ -d ./lib ] || [ -d ./pages ]; } && echo y )
  S5=$( has_md ./reports && echo y )                              # 검수: reports/ 의 임의 .md
  S6=$( { has_md ./uat || has_md ./docs/uat; } && echo y )        # UAT: uat/ 또는 docs/uat/
  S7=$( git tag 2>/dev/null | grep -qiE 'prod|release|^v[0-9]' && echo y )
  S8=$( has_md ./acceptance && echo y )
  [ -z "$S8" ] && grep -rl "인수확인서" ./docs ./reports >/dev/null 2>&1 && S8=y
  [ -n "$RETRO" ] && { S0=${S0:-retro}; S1=${S1:-retro}; }

  # 게이트
  PAID=$( grep -rhE '착수금.*✅|✅.*착수금' ./contracts 2>/dev/null | head -1 )
  UATR=$( grep -rlE '미통과' ./uat ./docs/uat 2>/dev/null | head -1 )
  MISS=0
  [ -n "$UATR" ] && MISS=$( grep -ohE '미통과[^0-9]{0,4}[0-9]+' "$UATR" 2>/dev/null | grep -oE '[0-9]+' | tail -1 )
  MISS=${MISS:-0}
  LASTREP=$( ls -t ./reports/*.md 2>/dev/null | head -1 )

  echo "═══ 외주 진행상황 · $(basename "$PWD") ═══"
  [ -n "$RETRO" ] && echo "ℹ retrofit — 계약·Discovery는 CLAUDE.md 내부 문서화(표준 ./intake·./contracts 아님)"
  echo "$(mark "$S0") 0 Discovery     $(mark "$S1") 1 견적·계약    $(mark "$S2") 2 기획"
  echo "$(mark "$S3") 3 디자인        $(mark "$S4") 4 개발         $(mark "$S5") 5 검수"
  echo "$(mark "$S6") 6 UAT           $(mark "$S7") 7 배포         $(mark "$S8") 8 인수"
  echo "─── 게이트 ───"
  if [ -n "$RETRO" ]; then echo "ⓘ 게이트① 계약·입금은 CLAUDE.md/외부 기록 확인 (표준 입금트래커 없음)"
  elif [ -n "$PAID" ]; then echo "$D 게이트① 착수금 확인됨"
  else echo "$T 게이트① 착수금 미확인 → 2단계(기획) 진입 불가"; fi
  if [ -n "$UATR" ]; then
    [ "$MISS" -gt 0 ] && echo "$T 게이트② UAT 미통과 ${MISS}건 → Production 배포 불가" || echo "$D 게이트② UAT 미통과 0건"
  else echo "$T 게이트② UAT 결과파일 없음 (시나리오·체크리스트만 존재 가능)"; fi
  [ -n "$LASTREP" ] && echo "최근 검수: $(basename "$LASTREP")"
  echo "─── 다음 권장 행동 ───"
  if   [ -z "$S0" ]; then echo "→ 0단계: /인테이크 로 요구사항 정리"
  elif [ -z "$S1" ]; then echo "→ 1단계: /견적 으로 견적·계약서 작성"
  elif [ -z "$RETRO" ] && [ -z "$PAID" ]; then echo "→ 게이트①: 착수금 입금 확인 후 /입금확인 착수금"
  elif [ -z "$S2" ]; then echo "→ 2단계: /기획 으로 Living CLAUDE.md 작성"
  elif [ -z "$S5" ]; then echo "→ 4~5단계: 개발 진행 → /전수검사 로 검수"
  elif [ -z "$S6" ] || { [ -n "$UATR" ] && [ "$MISS" -gt 0 ]; }; then echo "→ 6단계: /UAT (미통과 0건까지)"
  elif [ -z "$S8" ]; then echo "→ 7~8단계: 배포 마무리 → /인수 (인수확인서·잔금·하자보수)"
  else echo "→ 인수 완료. /하자보수 모니터링 단계."; fi
fi

if [ "$in_git" = 1 ]; then
  [ "$is_out" = 1 ] && echo ""
  echo "─── git 현황 ───"
  ST=$(git status --short 2>/dev/null | head -15)
  [ -n "$ST" ] && echo "$ST" || echo "(작업트리 깨끗)"
  echo "최근 커밋:"; git log --oneline -5 2>/dev/null
fi
