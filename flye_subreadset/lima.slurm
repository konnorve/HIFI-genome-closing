#!/usr/bin/env bash
# 
#SBATCH --job-name=lima7
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
#SBATCH -n 20
#
#SBATCH --comment="Lima demultiplexing for HIFI Genome Closing Batch 6"
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

raw_reads_path="/nfs/chisholmlab001/chisholmlab/experiment_repository/2021/HIFI_Genome_Closing_Project/220826Chi/raw2/1_A01/m54030R1_220923_142224.subreadset.xml"
barcodes_path="/nfs/chisholmlab001/chisholmlab/experiment_repository/2021/HIFI_Genome_Closing_Project/analysis/raw_barcodes/Sequel_384_barcodes_v1.fasta"
lima_out_path="/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/flye_subreadset/batch8/lima_2/lima_demultiplexed.bam"

/home/kve/bin/smrtlink/smrtcmds/bin/lima --same --peek-guess --split-named --num-threads ${SLURM_NTASKS} ${raw_reads_path} ${barcodes_path} ${lima_out_path}

source activate samtools
for bam_file in $(dirname $lima_out_path)/*.bam
do
    samtools fastq ${bam_file} > ${bam_file%.*}.fastq
done