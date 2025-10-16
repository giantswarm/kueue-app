#!/bin/bash

# Sync upstream Kueue chart using vendir
set -e

echo "🔄 Syncing upstream Kueue chart..."

# Run vendir sync
vendir sync --yes

echo ""
echo "✅ Sync completed!"
echo ""
echo "🎯 Next steps:"
echo "   1. Review the updated chart and templates"
echo "   2. Test the chart with your values"
echo "   3. Update patch files if needed for new upstream options (Chart.yaml and values.yaml)"
echo"
