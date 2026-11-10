#!/usr/bin/env bash
#SBATCH --job-name=cellranger-arc_SN_ivy_sl8_rxn2
#SBATCH --output=slurm-cellranger-arc-%j.out
#SBATCH --error=slurm-cellranger-arc-%j.err
#SBATCH --partition=all
#SBATCH --time=24:50:00
#SBATCH --cpus-per-task=24
#SBATCH --mem-per-cpu=8G

set -euo pipefail

: "${CELLRANGER_REFERENCE:?Set CELLRANGER_REFERENCE to the Cell Ranger ARC reference directory}"
libraries_csv="${LIBRARIES_CSV:-${SLURM_SUBMIT_DIR:-$PWD}/libraries.csv}"
run_id="${RUN_ID:-SN_ivy_sl8_rxn2}"

test -d "$CELLRANGER_REFERENCE" || { printf 'Reference directory missing: %s\n' "$CELLRANGER_REFERENCE" >&2; exit 1; }
test -r "$libraries_csv" || { printf 'Library manifest missing: %s\n' "$libraries_csv" >&2; exit 1; }

module load cellranger-arc/2.0.2
exec cellranger-arc count \
  --id="$run_id" \
  --reference="$CELLRANGER_REFERENCE" \
  --libraries="$libraries_csv" \
  --localcores="${SLURM_CPUS_PER_TASK:-24}" \
  --localmem=192
