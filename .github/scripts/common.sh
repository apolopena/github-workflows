#!/usr/bin/env bash
set -euo pipefail
: "${API_VER:=2022-11-28}"

# TOKEN must be set by the caller
api_get() {
  curl -fsS \
    -H "Authorization: token ${TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: ${API_VER}" \
    "$1"
}

# TOKEN must be set by the caller
api_post() {
  local url="$1" data="$2"
  curl -fsS -X POST \
    -H "Authorization: token ${TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: ${API_VER}" \
    -H "Content-Type: application/json" \
    --data "${data}" \
    "${url}"
}

# TODO: add an argument for ai code assistant actor
# ACTOR should be set by the caller (for attribution only)
provenance_block() {
  local pvt
  pvt="$(cat <<'EOF'
<!-- AI-PROVENANCE: DO NOT EDIT -->
initiated-by: @__ACTOR__
EOF
)"
  printf '%s' "${pvt/__ACTOR__/${ACTOR:-unknown}}"
}
