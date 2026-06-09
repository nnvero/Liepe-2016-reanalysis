#!/usr/bin/env bash
#
# Batch convert Thermo .raw files to mzML using msconvert via Docker.
#
# USAGE:
#   ./convert_raw.sh [INPUT_DIR] [OUTPUT_DIR]
#
# ARGUMENTS:
#   INPUT_DIR   Directory containing .raw files.  (default: ./data/raw)
#   OUTPUT_DIR  Directory to write .mzML files to. Created if absent. (default: ./data/mzml)
#
# EXAMPLES:
#   ./convert_raw.sh                                   # ./data/raw -> ./data/mzml
#   ./convert_raw.sh ./data/raw ./data/mzml            # explicit paths
#   ./convert_raw.sh ./data/raw                        # explicit input, default output
#
# REQUIRES:
#   Docker with the proteowizard/pwiz-skyline-i-agree-to-the-vendor-licenses image pulled.
#
# NOTES:
#   - Applies centroid peak picking to all MS levels (peakPicking true 1-).
#   - Processes one file per container; a failed conversion does not abort the rest.

set -euo pipefail

IMAGE="proteowizard/pwiz-skyline-i-agree-to-the-vendor-licenses"

if ! docker image inspect "$IMAGE" &>/dev/null; then
    echo "Docker image not found locally. Pulling $IMAGE ..."
    docker pull "$IMAGE"
fi

INPUT_DIR="${1:-./data/raw}"
OUTPUT_DIR="${2:-./data/mzml}"

mkdir -p "$OUTPUT_DIR"

shopt -s nullglob
raw_files=("$INPUT_DIR"/*.raw)

if [[ ${#raw_files[@]} -eq 0 ]]; then
    echo "No .raw files found in $INPUT_DIR"
    exit 1
fi

echo "Found ${#raw_files[@]} .raw file(s) in $INPUT_DIR"

for raw_file in "${raw_files[@]}"; do
    filename=$(basename "$raw_file")
    echo "Converting: $filename"

    docker run --rm \
        -v "$(realpath "$INPUT_DIR")":/data/input \
        -v "$(realpath "$OUTPUT_DIR")":/data/output \
        "$IMAGE" \
        wine msconvert "/data/input/$filename" \
            --mzML \
            --filter "peakPicking true 1-" \
            -o /data/output

    echo "Done: $filename"
done

echo "All conversions complete. mzML files in $OUTPUT_DIR"
