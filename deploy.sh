#!/opt/homebrew/bin/bash
set -e

DIST="dist"

# stage
git add "$DIST"

# generate timestamp
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# commit
git commit -m "Deployment commit $timestamp"

# push
git push origin HEAD
