#!/bin/bash

# Sync upstream Kueue chart using vendir.
#
# vendir only manages helm/kueue/templates, helm/kueue/tests and upstream/ (see
# vendir.yml). Giant Swarm's hand-maintained files (Chart.yaml, values.yaml,
# OWNERS, values.schema.json, README.md.gotmpl) live in helm/kueue/ and are
# intentionally NOT managed by vendir, so a sync never deletes them.
set -euo pipefail

echo "🔄 Syncing upstream Kueue chart..."
vendir sync --yes

# Because vendir is scoped to specific subdirectories, a brand-new top-level
# file/dir in the upstream chart (e.g. a future crds/ or files/ directory) would
# be missed. The pristine copy under upstream/ always has the full chart, so
# diff its top level against helm/kueue and warn about anything unaccounted for.
echo ""
echo "🔎 Checking for new upstream chart files not wired into helm/kueue ..."
new_files=0
while IFS= read -r entry; do
  base=$(basename "$entry")
  case "$base" in
    # Files Giant Swarm maintains by hand or intentionally does not ship:
    Chart.yaml|values.yaml|values.schema.json|README.md|.helmignore) continue ;;
  esac
  if [ ! -e "helm/kueue/$base" ]; then
    echo "   ⚠️  upstream ships 'charts/kueue/$base' but 'helm/kueue/$base' is absent"
    echo "       -> add it to vendir.yml if the chart needs it."
    new_files=1
  fi
done < <(find upstream/charts/kueue -mindepth 1 -maxdepth 1)
[ "$new_files" -eq 0 ] && echo "   ✅ no new top-level upstream files"

# Flag structural drift between the hand-maintained values.yaml and the fresh
# upstream copy (new/renamed/removed value keys). Non-fatal here so the sync
# still completes; CI runs the same check as a hard gate on the PR.
echo ""
"$(dirname "$0")/hack/check-values-drift.sh" || true

echo ""
echo "✅ Sync completed!"
echo ""
echo "🎯 Next steps:"
echo "   1. Review the templates/tests changes: git diff helm/kueue"
echo "   2. If the values-drift check above reported drift, reconcile"
echo "      helm/kueue/values.yaml (it is hand-maintained by Giant Swarm)."
echo "   3. Bump appVersion in helm/kueue/Chart.yaml to match the new upstream tag."
