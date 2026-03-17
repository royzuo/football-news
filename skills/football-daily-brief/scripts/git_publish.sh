#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   GITHUB_TOKEN=... ./scripts/git_publish.sh "commit message"
#
# Safe push: token never appears in command line.

msg=${1:-"Update brief"}

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "GITHUB_TOKEN is not set" >&2
  exit 1
fi

# Commit if there are changes
if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit -m "$msg"
fi

AUTH=$(printf 'x-access-token:%s' "$GITHUB_TOKEN" | base64 -w0)
branch=$(git rev-parse --abbrev-ref HEAD)

git -c http.extraheader="AUTHORIZATION: Basic $AUTH" push origin "$branch"
