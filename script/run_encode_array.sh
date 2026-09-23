#!/bin/bash
#SBATCH --job-name=encode_rna
#SBATCH --array=1-9%3
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --output=/work/rr151/Julia_Riley/logs/slurm-%A_%a.out
#SBATCH --error=/work/rr151/Julia_Riley/logs/slurm-%A_%a.err

set -euo pipefail

PROJECT="/work/rr151/Julia_Riley"

WDL="/hpc/group/gersbachlab/rr151/software/ENCODE_DCC/rna-seq-pipeline/rna-seq-pipeline.wdl"

LINE=$((SLURM_ARRAY_TASK_ID + 1))

IFS=$'\t' read -r CONDITION SAMPLE REPLICATE R1 R2 \
    < <(sed -n "${LINE}p" "$PROJECT/samples.tsv")

if [[ -z "${SAMPLE:-}" ]]; then
    echo "ERROR: No sample found for array task $SLURM_ARRAY_TASK_ID"
    exit 1
fi

echo "========================================"
echo "Sample:       $SAMPLE"
echo "SLURM job:    $SLURM_JOB_ID"
echo "Array task:   $SLURM_ARRAY_TASK_ID"
echo "Node:         $(hostname)"
echo "CPUs:         $SLURM_CPUS_PER_TASK"
echo "Start:        $(date)"
echo "========================================"

INPUT="${PROJECT}/inputs/${SAMPLE}.json"
RUNDIR="${PROJECT}/runs/${SAMPLE}"

if [[ ! -f "$INPUT" ]]; then
    echo "ERROR: Input JSON not found:"
    echo "$INPUT"
    exit 1
fi

mkdir -p "$RUNDIR"

cd "$RUNDIR"

caper run "$WDL" \
    -i "$INPUT" \
    -m metadata.json \
    -b local \
    --singularity

echo "========================================"
echo "Finished: $SAMPLE"
echo "End:      $(date)"
echo "========================================"
