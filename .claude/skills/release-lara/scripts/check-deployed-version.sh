#!/usr/bin/env bash
# Verify LARA is consistently serving an expected version.
#
# During an ECS rolling deploy the load balancer serves both the old and new task
# generations, so the footer version flaps. A single request is not evidence: half
# of all traffic can still be on the old code while one lucky curl reports success.
# Require a run of agreeing responses.
#
# The footer comes from app/views/layouts/application.html.erb, which prints
# ENV['LARA_IMAGE_VERSION'] (baked into the image from the git ref, so it carries
# the "v" prefix) falling back to ENV['LARA_VERSION'] (from the stack, no prefix).
#
# usage: check-deployed-version.sh <host> <expected-version> [streak] [max-seconds]
#   expected-version is the git tag WITH the v prefix, e.g. v2.20.0-pre.0
set -uo pipefail

if [ "$#" -lt 2 ]; then
  echo "usage: $(basename "$0") <host> <expected-version> [streak] [max-seconds]" >&2
  echo "  e.g. $(basename "$0") authoring.lara.staging.concord.org v2.20.0-pre.0 3 900" >&2
  exit 2
fi

HOST="$1"; EXPECTED="$2"; NEED="${3:-10}"; MAX="${4:-900}"
DEADLINE=$((SECONDS + MAX))
streak=0; last=""

echo "checking https://${HOST}/ for ${EXPECTED} (need ${NEED} consecutive)"
# Strip tags and collapse newlines before matching, so the extraction survives the
# footer being indented, wrapped in elements, or rendered on one line.
extract_version() {
  curl -s --max-time 15 "https://${HOST}/" \
    | tr '\n' ' ' \
    | sed 's/<[^>]*>/ /g' \
    | grep -oE 'Version:[[:space:]]*v?[0-9][^[:space:]<]*' \
    | head -1 | sed -E 's/^Version:[[:space:]]*//'
}

while [ $SECONDS -lt $DEADLINE ]; do
  v=$(extract_version)
  if [ -z "$v" ]; then
    echo "  no version found in footer (request failed or markup changed)"
    streak=0
  elif [ "$v" = "$EXPECTED" ]; then
    streak=$((streak + 1))
  else
    [ "$v" != "$last" ] && echo "  serving $v (still rolling)"
    streak=0
  fi
  last="$v"
  if [ $streak -ge $NEED ]; then
    echo "OK: ${NEED} consecutive responses report ${EXPECTED}"
    exit 0
  fi
  sleep 5
done

echo "FAIL: did not reach ${NEED} consecutive responses reporting ${EXPECTED} within ${MAX}s (last saw '${last}')"
exit 1
