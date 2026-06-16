set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FRAGPIPE_IMG="fcyucn/fragpipe:24.0"
FRAGPIPE_BIN="/fragpipe_bin/fragpipe-24.0/fragpipe-24.0/bin/fragpipe"

MANIFEST="${MANIFEST:-workflows/manifest.fp-manifest}"
WORKFLOW="${WORKFLOW:-workflows/grlcl_ethcd_nonspecific.workflow}"
WORKDIR_OUT="${WORKDIR_OUT:-results/search}"

mkdir -p "$WORKDIR_OUT"

# 1. Tool-created decoys + contaminants (rev_ tag). Idempotent.
bash "$SCRIPT_DIR/03_build_decoy_db.sh"

docker pull --platform linux/amd64 "$FRAGPIPE_IMG" >/dev/null

# 2. FragPipe headless — MSFragger -> Percolator -> ProteinProphet -> report.
docker run --rm --platform linux/amd64 \
  -v "$(pwd):/work" -w /work \
  "$FRAGPIPE_IMG" \
  "$FRAGPIPE_BIN" --headless \
    --workflow "$WORKFLOW" \
    --manifest "$MANIFEST" \
    --workdir  "$WORKDIR_OUT" \
    --config-tools-folder /work/tools/msfragger
