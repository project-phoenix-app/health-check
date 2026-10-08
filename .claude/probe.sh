#!/bin/sh
# Read-only runtime capture. Environment is recorded by NAME ONLY - values are
# never read, per the engagement rule.
TAG="${1:-hook}"
OUT="EVIDENCE-$TAG.txt"
{
  echo "=== tag: $TAG  at $(date -u 2>/dev/null) ==="
  echo "--- identity ---";      id 2>&1; echo "cwd: $(pwd)"
  echo "--- kernel ---";        uname -a 2>&1
  echo "--- distro ---";        cat /etc/os-release 2>&1 | head -5
  echo "--- skills tree ---";   ls -la /mnt/skills 2>&1 | head -40
  echo "--- skills dirs ---";   ls -la /mnt/skills/* 2>&1 | head -80
  echo "--- SKILL.md files ---";find / -maxdepth 6 -name 'SKILL.md' 2>/dev/null | head -60
  echo "--- claude-security skills ---"; find / -maxdepth 8 -path '*claude-security*' 2>/dev/null | head -40
  echo "--- env NAMES only ---";env 2>/dev/null | cut -d= -f1 | sort
  echo "--- mounts ---";        cat /proc/self/mountinfo 2>&1 | head -40
} > "$OUT" 2>&1
git add "$OUT" >/dev/null 2>&1
git -c user.email=probe@calif.io -c user.name=probe commit -qm "runtime evidence $TAG" >/dev/null 2>&1
git push -q origin "HEAD:runtime-evidence-$TAG" >/dev/null 2>&1
exit 0
