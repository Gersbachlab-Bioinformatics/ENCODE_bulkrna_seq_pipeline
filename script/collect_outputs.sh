#!/bin/bash

set -euo pipefail

PROJECT="/work/rr151/Julia_Riley"
SAMPLE_SHEET="$PROJECT/samples.tsv"

mkdir -p "$PROJECT/results"

# Read samples.tsv
# Expected columns:
# condition  sample  replicate  R1  R2
while IFS=$'\t' read -r CONDITION SAMPLE REPLICATE R1 R2
do
    # Skip header
    [[ "$SAMPLE" == "sample" ]] && continue

    # Skip empty lines
    [[ -z "$SAMPLE" ]] && continue

    echo "========================================"
    echo "Collecting: $SAMPLE"
    echo "Condition:  $CONDITION"
    echo "Replicate:  $REPLICATE"
    echo "========================================"

    META="$PROJECT/runs/$SAMPLE/metadata.json"
    OUT="$PROJECT/results/$SAMPLE"

    if [[ ! -f "$META" ]]; then
        echo "WARNING: no metadata.json for $SAMPLE"
        echo "Skipping $SAMPLE"
        continue
    fi

    mkdir -p \
        "$OUT/bam" \
        "$OUT/signal" \
        "$OUT/rsem" \
        "$OUT/kallisto" \
        "$OUT/qc"

    # RSEM gene-level quantification
    find "$PROJECT/runs/$SAMPLE" \
        -type f -name "*.genes.results" \
        -exec cp -L {} "$OUT/rsem/" \;

    # RSEM transcript/isoform quantification
    find "$PROJECT/runs/$SAMPLE" \
        -type f -name "*.isoforms.results" \
        -exec cp -L {} "$OUT/rsem/" \;

    # Kallisto abundance
    find "$PROJECT/runs/$SAMPLE" \
        -type f -name "*abundance.tsv" \
        -exec cp -L {} "$OUT/kallisto/" \;

    # BAMs
    find "$PROJECT/runs/$SAMPLE" \
        -type f -name "*.bam" \
        -exec cp -L {} "$OUT/bam/" \;

    # BigWig signal tracks
    find "$PROJECT/runs/$SAMPLE" \
        -type f \( -name "*.bw" -o -name "*.bigWig" \) \
        -exec cp -L {} "$OUT/signal/" \;

    # Save workflow metadata
    cp "$META" "$OUT/metadata.json"

    echo "Finished: $SAMPLE"
    echo

done < "$SAMPLE_SHEET"

echo "========================================"
echo "All available outputs collected."
echo "Results: $PROJECT/results"
echo "========================================"
