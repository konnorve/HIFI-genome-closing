#!/usr/bin/env bash
# 
#SBATCH --job-name=gtdbtk
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
#SBATCH -n 20
#
#SBATCH --comment="DTDBTK identification of de novo syn isolates"
#
# emails all notifications
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kve@mit.edu
#
# Request nodes:
#SBATCH --nodes=1
#
#SBATCH --mem 250G
#
#SBATCH --array=0,1
#
#SBATCH -o logs/gtdbtk/%j_%a_slurm_output.txt
#SBATCH -e logs/gtdbtk/%j_%a_slurm_error.txt

source activate gtdbtk

wd="/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/trouble"
arr=("batch1.bc1020" "batch4.bc1015")
strain_dir=${wd}/${arr[$SLURM_ARRAY_TASK_ID]}
echo $strain_dir

bin_dir=${strain_dir}/metagenomic_bins
gtdbtk_dir=${strain_dir}/gtdbtk_classify_wf

gtdbtk classify_wf --genome_dir ${bin_dir} --out_dir ${gtdbtk_dir} --extension fa --cpus 10