#!/usr/bin/env bash

OUTPUT_DIR="data/proteome/uniprot"

mkdir -p "$OUTPUT_DIR"

if [[ ! -f "$OUTPUT_DIR/human.fasta" ]]; then
  wget "https://rest.uniprot.org/uniprotkb/stream?compressed=true&format=fasta&query=%28%28proteome%3AUP000005640%29%29" \
    -O "$OUTPUT_DIR/human.fasta.gz"
else
    echo "human.fasta.gz already exists, skipping download"
fi

gunzip "$OUTPUT_DIR/human.fasta.gz"
