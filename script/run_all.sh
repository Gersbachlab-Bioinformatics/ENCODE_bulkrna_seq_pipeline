#!/bin/bash

set -euo pipefail

PROJECT="/work/rr151/Julia_Riley"

WDL="/hpc/group/gersbachlab/rr151/software/ENCODE_DCC/rna-seq-pipeline/rna-seq-pipeline.wdl"

cd "$PROJECT"

while IFS=$'\t' read -r condition sample replicate R1 R2
do
    # Skip header
    [[ "$sample" == "sample" ]] && continue

    echo "========================================"
    echo "Running: $sample"
    echo "Condition: $condition"
    echo "Replicate: $replicate"
    echo "========================================"

    mkdir -p "$PROJECT/runs/$sample"

    cd "$PROJECT/runs/$sample"

    caper run "$WDL" \
        -i "$PROJECT/inputs/${sample}.json" \
        -m metadata.json \
        -b local \
        --singularity \
        > "$PROJECT/logs/${sample}.log" 2>&1

    echo "$sample finished"

done < "$PROJECT/samples.tsv"
