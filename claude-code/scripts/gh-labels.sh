#!/usr/bin/env bash
# 클라이언트 가시성용 GitHub 라벨 표준 세트 (멱등 — --force 로 있으면 갱신)
# 현 디렉토리의 GitHub repo에 적용. /이슈동기화 가 호출.
set -e
command -v gh >/dev/null 2>&1 || { echo "✗ gh CLI 필요"; exit 1; }
git rev-parse --git-dir >/dev/null 2>&1 || { echo "✗ git repo 아님"; exit 1; }

gh label create "In-Scope"     --color 0E8A16 --description "계약 범위 내 작업 (클라이언트 가시)" --force
gh label create "진행중"        --color FBCA04 --description "개발 진행 중" --force
gh label create "검수중"        --color 1D76DB --description "검수/UAT 단계" --force
gh label create "보류"          --color D93F0B --description "대기/블록" --force
gh label create "Out-of-Scope"  --color B60205 --description "범위 외 — 별도 견적(CR) 대상" --force
echo "✓ 클라이언트 가시성 라벨 세트 생성/갱신 완료"
