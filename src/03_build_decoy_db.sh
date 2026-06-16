set -euo pipefail

FRAGPIPE_IMG="${FRAGPIPE_IMG:-fcyucn/fragpipe:24.0}"
PHILOSOPHER="/fragpipe_bin/fragpipe-24.0/fragpipe-24.0/tools/Philosopher/philosopher-v5.1.3-RC9"
# INPUT_FASTA is the target-only library written by 02_prepare_db.py (its OUTPUT_FASTA).
INPUT_FASTA="${INPUT_FASTA:-./data/proteome/library/proteome_with_liepe_peptides.fasta}"
OUTPUT_FASTA="${OUTPUT_FASTA:-./data/proteome/library/proteome_with_liepe_peptides_target_decoy.fasta}"

if [[ -f "$OUTPUT_FASTA" ]]; then
  echo "Decoy DB already present: $OUTPUT_FASTA"
  exit 0
fi

docker pull --platform linux/amd64 "$FRAGPIPE_IMG" >/dev/null

# Philosopher is bundled in the image but not on PATH; call it by full path.
# `database` requires an initialized workspace, so init -> database -> clean
# in one container. Writes a timestamped *-decoys-contam-*.fas in the cwd.
docker run --rm --platform linux/amd64 \
  -v "$(pwd):/work" -w /work \
  -e INPUT_FASTA="$INPUT_FASTA" \
  -e PHILOSOPHER="$PHILOSOPHER" \
  --entrypoint bash "$FRAGPIPE_IMG" -c '
    "$PHILOSOPHER" workspace --init
    "$PHILOSOPHER" database --custom "$INPUT_FASTA" --contam --prefix rev_
    "$PHILOSOPHER" workspace --clean'

# Rename to the stable path the workflow's database.db-path points at.
mv ./*-decoys-contam-*.fas "$OUTPUT_FASTA"
echo "Wrote $OUTPUT_FASTA"
