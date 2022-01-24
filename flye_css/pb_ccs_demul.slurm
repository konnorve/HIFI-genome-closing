#!/usr/bin/env bash
# 
#SBATCH --job-name=ccs_demul_5
#
# Specifies using a centos7 node
#SBATCH -C centos7
#
# wall clock limit:
#SBATCH --time 24:00:00
#
# Partition to use:
#SBATCH --partition sched_mit_chisholm
#
# Number of tasks/cores for job
#SBATCH -n 10
#
#SBATCH --comment="PacBio CCS and Demultiplexing batch 5"
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
#SBATCH -o logs/ccs_demul/%j_slurm_output.txt
#SBATCH -e logs/ccs_demul/%j_slurm_error.txt

barcodes_xml_path="/nfs/chisholmlab001/experiment_repository/2021/HIFI_Genome_Closing_Project/analysis/raw_barcodes/Sequel_384_barcodes_v1.xml"
raw_reads_path="/nfs/chisholmlab001/experiment_repository/2021/HIFI_Genome_Closing_Project/211029Chi/m54030R1_211124_203007.subreadset.xml"
demul_out_path="/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/flye_ccs_assemblies/batch5/ccs_demul"

mkdir -p ${demul_out_path}

pbcromwell run pb_ccs_demux -e ${raw_reads_path} -e ${barcodes_xml_path} --output-dir ${demul_out_path} --overwrite
