#!/usr/bin/env bash
# 
#SBATCH --job-name=lima1_demul
#
# Specifies using a centos7 node
#SBATCH -C centos7
#
# wall clock limit:
#SBATCH --time 12:00:00
#
# Partition to use:
#SBATCH --partition sched_mit_chisholm
#
# Number of tasks/cores for job
#SBATCH -n 10
#

#SBATCH --comment="Lima demultiplexing for HIFI Genome Closing Batch 1"
#
# emails all notifications
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kve@mit.edu
#
# Request nodes:
#SBATCH --nodes=1
#
#SBATCH --mem 250000
#
#SBATCH -o logs/alt_lima/%j_slurm_output.txt
#SBATCH -e logs/alt_lima/%j_slurm_error.txt

raw_reads_path="/nfs/chisholmlab001/experiment_repository/2021/HIFI_Genome_Closing_Project/210511Chi/m54030R1_210528_175343.subreadset.xml"
barcodes_path="/nfs/chisholmlab001/experiment_repository/2021/HIFI_Genome_Closing_Project/analysis/raw_barcodes/Sequel_384_barcodes_v1.fasta"
lima_out_path="/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/assembly/batch1-first-pass/lima/lima_demultiplexed.bam"


lima --same --peek-guess --split-named --num-threads 10 ${raw_reads_path} ${barcodes_path} ${lima_out_path}