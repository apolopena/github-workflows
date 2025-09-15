#!/usr/bin/env bash
set -euo pipefail
: "${API_VER:=2022-11-28}"

# Require provenance label early (even if provided as empty string)
if [ -z "${PROV_LABEL:-}" ]; then
  echo "Missing required PROV_LABEL (provenance label, e.g., AI_CODING_ASSISTANT)" >&2
  exit 1
fi

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

# ACTOR should be set by the caller (for attribution only)
provenance_block() {
  local pvt
  pvt="$(cat <<'EOF'
<!-- AI-PROVENANCE: DO NOT EDIT -->
initiated-by: @__ACTOR__
provenance-label: __LABEL__
EOF
)"
  pvt="${pvt/__ACTOR__/${ACTOR:-unknown}}"
  pvt="${pvt/__LABEL__/${PROV_LABEL}}"
  printf '%s' "$pvt"
}