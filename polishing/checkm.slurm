#!/usr/bin/env bash
# 
#SBATCH --job-name=checkM
#
# Specifies using a centos7 node
#SBATCH -C centos7
#
# wall clock limit:
#SBATCH --time 96:00:00
#
# Partition to use:
#SBATCH --partition sched_mit_chisholm
#
# Number of tasks/cores for job
#SBATCH -n 1
#
#SBATCH --comment="CheckM on all assemblies"
#
# emails all notifications
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kve@mit.edu
#
#SBATCH --mem 250G
#
#
#SBATCH -o logs/checkm/%j_slurm_output.txt
#SBATCH -e logs/checkm/%j_slurm_error.txt


BATCH_DIR="/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project"
ASSEMBLY_DIR=${BATCH_DIR}/"all_circ_genomes"
CHECKM_DIR=${BATCH_DIR}/"all_circ_genomes_checkm"

source activate checkm

checkm lineage_wf -t ${SLURM_NTASKS} -x fasta ${ASSEMBLY_DIR} ${CHECKM_DIR}
