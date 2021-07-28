#! /usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --time=24:00:00
#SBATCH --job-name=NF_assemblyStat
#SBATCH --output=R-%x.%J.out
#SBATCH --error=R-%x.%J.err
# --mail-user=someone@email.com
# --mail-type=begin
# --mail-type=end
# --account=project_name    # <= put HPC account name here, required on Atlas

# === Load Modules here
# ==  Atlas HPC (will need a local install of nextflow)
# module load singularity
# NEXTFLOW=/project/isu_gif_vrsc/programs/nextflow

# == Ceres HPC
module load nextflow
NEXTFLOW=nextflow

# == Nova HPC
# module load gcc/7.3.0-xegsmw4 nextflow
# module load singularity
# NEXTFLOW=nextflow

# === Set working directory and in/out variables
cd ${SLURM_SUBMIT_DIR}

# === Main Program
${NEXTFLOW} run main.nf \
  --genome "8_consensus.fasta" \
  -profile singularity,ceres \
  -resume

