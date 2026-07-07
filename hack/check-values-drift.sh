#!/bin/bash

# Detect structural drift between Giant Swarm's hand-maintained chart values
# (helm/kueue/values.yaml) and the pristine upstream copy vendored under
# upstream/charts/kueue/values.yaml.
#
# vendir never touches helm/kueue/values.yaml (it lives outside any managed
# path -- see vendir.yml), so when an upstream bump adds, renames or removes a
# value key, GS's copy silently falls behind. This check surfaces that so a
# maintainer can reconcile it as part of the bump PR.
#
# It compares only the KEY STRUCTURE (map keys), never values, so intentional
# Giant Swarm overrides (image repository, enableCertManager, the disabled
# pod/deployment/... frameworks, etc.) do NOT register as drift. It inspects
# both the top-level document and the embedded controllerManagerConfigYaml
# block-scalar (which holds the integrations config as raw YAML text).
#
# Exit codes: 0 = in sync, 1 = drift detected, 2 = usage/dependency error.
set -euo pipefail

GS=helm/kueue/values.yaml
UP=upstream/charts/kueue/values.yaml

command -v yq >/dev/null || { echo "❌ yq is required but not installed"; exit 2; }
for f in "$GS" "$UP"; do
  [ -f "$f" ] || { echo "❌ missing $f (run ./sync-upstream.sh first)"; exit 2; }
done

# Emit the set of map-key paths of a YAML document read from stdin. Comments and
# blank lines are dropped, and numeric (sequence-index) path segments are
# stripped so list-content differences do not count as structural drift.
mapkeys() {
  yq -o=props - 2>/dev/null \
    | sed 's/ = .*//' \
    | grep -v '^#' | grep -v '^$' \
    | sed -E 's/\.[0-9]+//g' \
    | sort -u
}

drift=0
report() { # $1=label  $2=gs-keys-file  $3=up-keys-file
  local missing extra
  missing=$(comm -13 "$2" "$3")
  extra=$(comm -23 "$2" "$3")
  if [ -n "$missing" ]; then
    drift=1
    echo "⚠️  [$1] keys present upstream but MISSING in GS values.yaml:"
    echo "$missing" | sed 's/^/      + /'
  fi
  if [ -n "$extra" ]; then
    drift=1
    echo "⚠️  [$1] keys in GS values.yaml no longer present upstream (removed/renamed):"
    echo "$extra" | sed 's/^/      - /'
  fi
}

tmp=$(mktemp -d "${TMPDIR:-/tmp}/values-drift.XXXXXX")
trap 'rm -rf "$tmp"' EXIT

# Top-level document.
mapkeys < "$GS" > "$tmp/gs-top"
mapkeys < "$UP" > "$tmp/up-top"
report "values.yaml" "$tmp/gs-top" "$tmp/up-top"

# Embedded controllerManagerConfigYaml block-scalar, re-parsed as YAML.
yq '.managerConfig.controllerManagerConfigYaml' "$GS" | mapkeys > "$tmp/gs-cfg"
yq '.managerConfig.controllerManagerConfigYaml' "$UP" | mapkeys > "$tmp/up-cfg"
report "controllerManagerConfigYaml" "$tmp/gs-cfg" "$tmp/up-cfg"

if [ "$drift" -ne 0 ]; then
  echo ""
  echo "➡️  Upstream changed the values contract. Reconcile helm/kueue/values.yaml"
  echo "    against upstream/charts/kueue/values.yaml, then re-run this check."
  exit 1
fi

echo "✅ helm/kueue/values.yaml is structurally in sync with upstream."
