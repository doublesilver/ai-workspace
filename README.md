# AI Workspace

이은석(korea5410@gmail.com)의 AI 운영을 한곳에서 관리하는 저장소.
Claude Code 글로벌 설정·거버넌스 규칙·재사용 프롬프트·AI 활용 지식을 버전 관리한다.

## 구조

```
ai-workspace/
├── claude-code/      # Claude Code 글로벌 설정 (단일 원본, ~/.claude 가 심볼릭 링크로 가리킴)
│   ├── CLAUDE.md     # 글로벌 작업 규칙 (외주 워크플로 v2.0 + 운영 철학 + 엔지니어링/품질 표준)
│   ├── settings.json # 권한·hook·게이트 강제·statusLine 설정
│   ├── commands/     # 슬래시 스킬 16종 (/견적 /기획 /전수검사 /배포-production 등)
│   ├── agents/       # 검수 서브에이전트 5종 (security/accessibility/performance/ux/plan-compliance)
│   └── templates/    # 문서 템플릿 (견적서·기획안·인수인계·진행보고서)
├── prompts/          # 재사용 프롬프트 라이브러리
├── knowledge/        # "AI를 더 잘 쓰는 법" 지식·노트
└── tools/            # 기타 AI 도구 설정·메모
```

## claude-code/ 와 ~/.claude 의 관계 (중요)

`claude-code/` 안의 파일이 **진짜 원본**이다. `~/.claude/` 의 같은 이름 항목들은
이 저장소를 가리키는 **심볼릭 링크**다.

```
~/.claude/CLAUDE.md     -> ~/ai-workspace/claude-code/CLAUDE.md
~/.claude/settings.json -> ~/ai-workspace/claude-code/settings.json
~/.claude/commands      -> ~/ai-workspace/claude-code/commands
~/.claude/agents        -> ~/ai-workspace/claude-code/agents
~/.claude/templates     -> ~/ai-workspace/claude-code/templates
```

따라서 평소처럼 `~/.claude/CLAUDE.md` 를 수정하면 곧 이 저장소의 파일이 바뀌고,
`git add`/`commit` 으로 이력이 남는다. 별도 동기화 작업이 필요 없다.

주의: 만약 어떤 도구가 위 파일 중 하나를 **링크가 아니라 새 파일로 덮어쓰면**
심볼릭 링크가 끊어진다. `ls -la ~/.claude` 로 `->` 표시가 사라졌으면 다시 링크하면 된다:
`ln -sf ~/ai-workspace/claude-code/<파일> ~/.claude/<파일>`

## 추적하지 않는 것 (의도적 제외)

개인정보·시크릿·런타임 데이터는 `.gitignore` 로 차단한다:
- `~/.claude/projects/` (세션 메모리·대화 이력 — 클라이언트 정보 포함)
- `~/.claude/jobs`, `sessions`, `history.jsonl`, `daemon*`, `cache`, `telemetry` 등 런타임
- 인증 토큰·API 키·`.env`·`settings.local.json`

## 백업·복구

이 저장소를 GitHub(private) 등 원격에 push 해두면, 새 기기에서 clone 후
위 심볼릭 링크만 다시 걸면 동일한 AI 운영 환경이 복원된다.
