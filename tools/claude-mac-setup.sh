#!/bin/bash
# Makes the Claude Code CLI on this Mac aware of work done in Claude Code
# cloud sessions (claude.ai/code, the Claude app, GitHub Actions, ...).
#
# What it installs (safe to re-run; nothing is duplicated):
#   1. ~/.claude/hooks/cloud-work-context.sh
#      Runs at the start of every local Claude session. Inside a git repo it
#      fetches the claude/* branches that cloud sessions push to and shows
#      Claude the most recent ones, so it knows what changed elsewhere.
#   2. A SessionStart hook entry in ~/.claude/settings.json (merged, a backup
#      is kept as settings.json.bak).
#   3. A "Cloud work" section in ~/.claude/CLAUDE.md, the global memory file
#      every local session reads.
#
# Run it with:  bash claude-mac-setup.sh
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
HOOK="$CLAUDE_DIR/hooks/cloud-work-context.sh"
SETTINGS="$CLAUDE_DIR/settings.json"
MEMORY="$CLAUDE_DIR/CLAUDE.md"
mkdir -p "$CLAUDE_DIR/hooks"

# ---------------------------------------------------------------- 1. hook
cat > "$HOOK" <<'HOOK_EOF'
#!/bin/bash
# SessionStart hook: tell Claude about cloud-session work in this repo.
# Anything printed here is added to Claude's context. Never fails the session.
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
remote=$(git remote | head -n1)
[ -n "$remote" ] || exit 0

# Fetch only claude/* branches, quietly, giving up after ~8 seconds.
GIT_TERMINAL_PROMPT=0 git fetch --quiet --prune "$remote" \
  "+refs/heads/claude/*:refs/remotes/$remote/claude/*" >/dev/null 2>&1 &
pid=$!
for _ in 1 2 3 4 5 6 7 8; do kill -0 "$pid" 2>/dev/null || break; sleep 1; done
kill "$pid" 2>/dev/null || true

branches=$(git for-each-ref --sort=-committerdate --count=8 \
  --format='- %(refname:lstrip=3)  (%(committerdate:relative)): %(subject)' \
  "refs/remotes/$remote/claude/" 2>/dev/null)
[ -n "$branches" ] || exit 0

current=$(git branch --show-current 2>/dev/null)
echo "## Work from Claude Code cloud sessions in this repo"
echo "Cloud sessions push to claude/* branches on '$remote'. Most recent:"
echo "$branches"
echo "You are on branch '${current:-detached HEAD}'. Before starting related work,"
echo "check these branches (git log / git diff against them) so nothing is redone or lost."
exit 0
HOOK_EOF
chmod +x "$HOOK"
echo "✓ Installed $HOOK"

# ------------------------------------------------------------ 2. settings
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
cp "$SETTINGS" "$SETTINGS.bak"
HOOK_CMD='~/.claude/hooks/cloud-work-context.sh'
if grep -q 'cloud-work-context.sh' "$SETTINGS"; then
  echo "✓ Hook already registered in $SETTINGS"
elif command -v jq >/dev/null 2>&1; then
  tmp=$(mktemp)
  jq --arg cmd "$HOOK_CMD" \
    '.hooks.SessionStart = ((.hooks.SessionStart // []) + [{"hooks":[{"type":"command","command":$cmd}]}])' \
    "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  echo "✓ Registered hook in $SETTINGS"
elif python3 -c '' >/dev/null 2>&1; then
  python3 - "$SETTINGS" "$HOOK_CMD" <<'PY'
import json, sys
path, cmd = sys.argv[1], sys.argv[2]
with open(path) as f:
    data = json.load(f)
data.setdefault("hooks", {}).setdefault("SessionStart", []).append(
    {"hooks": [{"type": "command", "command": cmd}]})
with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY
  echo "✓ Registered hook in $SETTINGS"
else
  echo "! Could not edit $SETTINGS (no jq or python3). Add this under \"hooks\":"
  echo "  \"SessionStart\": [{\"hooks\":[{\"type\":\"command\",\"command\":\"$HOOK_CMD\"}]}]"
fi

# -------------------------------------------------------------- 3. memory
START='<!-- cloud-work:start -->'
END='<!-- cloud-work:end -->'
touch "$MEMORY"
if grep -qF "$START" "$MEMORY"; then
  # Remove the old section so the new one replaces it.
  awk -v s="$START" -v e="$END" '$0==s{skip=1} !skip{print} $0==e{skip=0}' \
    "$MEMORY" > "$MEMORY.tmp" && mv "$MEMORY.tmp" "$MEMORY"
fi
cat >> "$MEMORY" <<EOF

$START
## Cloud work (Claude Code on the web / Claude app)
- I also run Claude Code in cloud sessions (claude.ai/code and the Claude app).
  Those sessions commit to branches named \`claude/<topic>\` and push them to GitHub.
  They cannot see this Mac; this Mac only learns about them through git.
- At the start of a session, a hook lists recent \`claude/*\` branches for the
  current repo. Treat them as in-progress work of mine: look at them before
  starting related changes, and offer to merge or continue from them.
- When I ask "what was I working on" or similar, check \`git log --all\`, recent
  \`claude/*\` branches, and open pull requests (\`gh pr list\`) in addition to local state.
- To continue a specific cloud session here, I can run \`claude --teleport\`.
$END
EOF
echo "✓ Updated $MEMORY"
echo
echo "Done. Start a new 'claude' session inside any repo to see it in effect."
