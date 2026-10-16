#!/usr/bin/env bash
# Start the llmgrab logging proxy (127.0.0.1:8080) from the sibling LLMgrab repo, writing its
# captures to ./captures/YYYY-MM-DD.jsonl in this repo. Run it in its own terminal, then start
# `claude` here: .claude/settings.local.json points Claude Code at the proxy.
# Extra args go to mitmdump. LLMGRAB_HOME overrides where the LLMgrab repo is.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
llmgrab="${LLMGRAB_HOME:-$here/../LLMgrab}/.venv/bin/llmgrab"
[[ -x "$llmgrab" ]] || { echo "llmgrab not found at $llmgrab (run 'make install' there, or set LLMGRAB_HOME)" >&2; exit 1; }

export LLMGRAB_CLI_LOGS="$here/captures"   # created owner-only (700) on the first record
echo "llmgrab proxy -> $LLMGRAB_CLI_LOGS"
exec "$llmgrab" proxy "$@"
