#!/opt/homebrew/bin/bash
set -e

echo "[*] Deployment started"

DIST="docs"

# stage
git add "$DIST"

# generate timestamp
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# commit
git commit -m "Deployment commit $timestamp"

# push
git push origin HEAD

echo "[+] Deployment finished"
