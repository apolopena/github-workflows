#!/usr/bin/env bash
set -euo pipefail
# Inputs: TOKEN REPO ACT NUM TITLE BODY BASE HEAD DRAFT ACTOR LABELS STATE_REASON COLOR
source "$(dirname "$0")/common.sh"

REPO="${REPO:-${GITHUB_REPOSITORY}}"
API="https://api.github.com/repos/${REPO}"

# Normalize DRAFT to "true"/"false"
case "${DRAFT:-}" in true|false) : ;; *) DRAFT="false" ;; esac

PVT="$(provenance_block)"
# Convert literal \n to actual newlines in body
BODY_PROCESSED="$(printf '%b' "${BODY:-}")"
BODY_JOINED="$(printf '%s\n\n%s' "$BODY_PROCESSED" "$PVT")"

# require VALUE NAME: stop when an input the action needs is empty
require() {
  [[ -n "$1" ]] || { echo "Missing '$2' for ${ACT}" >&2; exit 1; }
}

# LABELS is a comma-separated list; print it as a JSON array of trimmed names
labels_json() {
  jq -nc --arg s "${LABELS:-}" \
    '$s | split(",") | map(gsub("^\\s+|\\s+$"; "")) | map(select(length > 0))'
}

post_comment() {
  payload="$(jq -nc --arg b "$BODY_JOINED" '{body:$b}')"
  api_post "${API}/issues/${NUM}/comments" "${payload}" > /dev/null
}

case "${ACT}" in
  open-issue)
    require "${TITLE:-}" title
    payload="$(jq -nc --arg title "$TITLE" --arg body "$BODY_JOINED" \
      --argjson labels "$(labels_json)" \
      '{title:$title, body:$body} + (if $labels == [] then {} else {labels:$labels} end)')"
    api_post "${API}/issues" "${payload}" > /dev/null
    ;;

  pr-comment|issue-comment)
    require "${NUM:-}" number
    post_comment
    ;;

  pr-code)
    require "${NUM:-}" number
    code_body="$(printf '%s\n\n```diff\n%s\n```' "$PVT" "${BODY:-}")"
    payload="$(jq -nc --arg b "$code_body" '{body:$b}')"
    api_post "${API}/issues/${NUM}/comments" "${payload}" > /dev/null
    ;;

  open-pr)
    require "${TITLE:-}" title
    require "${BASE:-}" base
    require "${HEAD:-}" head
    payload="$(jq -nc \
      --arg title "$TITLE" --arg body "$BODY_JOINED" \
      --arg base "$BASE"  --arg head "$HEAD" \
      --argjson draft ${DRAFT:-false} \
      '{title:$title, body:$body, base:$base, head:$head, draft:$draft}')"
    api_post "${API}/pulls" "${payload}" > /dev/null
    ;;

  edit-issue|edit-pr)
    # A new body gets the provenance block; a title-only edit leaves the body alone.
    require "${NUM:-}" number
    require "${TITLE:-}${BODY:-}" "title or body"
    payload="$(jq -nc --arg title "${TITLE:-}" --arg body "$BODY_JOINED" \
      --arg has_body "${BODY:+yes}" \
      '(if $title == "" then {} else {title:$title} end)
       + (if $has_body == "yes" then {body:$body} else {} end)')"
    collection="issues"
    [[ "${ACT}" == "edit-pr" ]] && collection="pulls"
    api_patch "${API}/${collection}/${NUM}" "${payload}" > /dev/null
    ;;

  close-issue)
    # An optional body is posted as a closing comment first.
    require "${NUM:-}" number
    reason="${STATE_REASON:-completed}"
    case "${reason}" in
      completed|not_planned) : ;;
      *) echo "state_reason must be completed or not_planned, not '${reason}'" >&2; exit 1 ;;
    esac
    [[ -n "${BODY:-}" ]] && post_comment
    payload="$(jq -nc --arg reason "$reason" '{state:"closed", state_reason:$reason}')"
    api_patch "${API}/issues/${NUM}" "${payload}" > /dev/null
    ;;

  add-labels)
    require "${NUM:-}" number
    labels="$(labels_json)"
    [[ "${labels}" != "[]" ]] || { echo "Missing 'labels' for ${ACT}" >&2; exit 1; }
    payload="$(jq -nc --argjson labels "$labels" '{labels:$labels}')"
    api_post "${API}/issues/${NUM}/labels" "${payload}" > /dev/null
    ;;

  remove-labels)
    require "${NUM:-}" number
    labels="$(labels_json)"
    [[ "${labels}" != "[]" ]] || { echo "Missing 'labels' for ${ACT}" >&2; exit 1; }
    while IFS= read -r name; do
      api_delete "${API}/issues/${NUM}/labels/${name}" > /dev/null
    done < <(jq -r '.[] | @uri' <<< "${labels}")
    ;;

  create-label)
    # title is the label name, body its description, color six hex digits.
    require "${TITLE:-}" title
    [[ "${COLOR:-}" =~ ^[0-9a-fA-F]{6}$ ]] \
      || { echo "color must be six hex digits, not '${COLOR:-}'" >&2; exit 1; }
    payload="$(jq -nc --arg name "$TITLE" --arg color "$COLOR" --arg description "${BODY:-}" \
      '{name:$name, color:$color, description:$description}')"
    api_post "${API}/labels" "${payload}" > /dev/null
    ;;

  *)
    echo "Unknown action: ${ACT}" >&2; exit 1 ;;
esac
