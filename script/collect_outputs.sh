#!/bin/bash

set -euo pipefail

PROJECT="/work/rr151/Julia_Riley"

SAMPLES=(
    D1-ab-ex
    D1-cntrl
    D1-dyna-ex
    D2-ab-ex
    D2-cntrl
    D2-dyna-ex
    D3-ab-ex
    D3-cntrl
    D3-dyna-ex
)

mkdir -p "$PROJECT/results"

for SAMPLE in "${SAMPLES[@]}"
do
    echo "========================================"
    echo "Collecting: $SAMPLE"
    echo "========================================"

    META="$PROJECT/runs/$SAMPLE/metadata.json"
    OUT="$PROJECT/results/$SAMPLE"

    if [[ ! -f "$META" ]]; then
        echo "WARNING: no metadata.json for $SAMPLE"
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

    # Save metadata
    cp "$META" "$OUT/metadata.json"

    echo "Finished $SAMPLE"
done

echo
echo "All available outputs collected."
