#!/usr/bin/env bash
# 
#SBATCH --job-name=ccsd7
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
#SBATCH --comment="CCS demultiplexing for HIFI Genome Closing Batch 6"
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

raw_reads_path="/nfs/chisholmlab001/chisholmlab/experiment_repository/2021/HIFI_Genome_Closing_Project/220718Chi/raw/1_A01/m54030R1_220728_180547.subreadset.xml"
barcodes_xml_path="/nfs/chisholmlab001/chisholmlab/experiment_repository/2021/HIFI_Genome_Closing_Project/analysis/raw_barcodes/Sequel_384_barcodes_v1.xml"
demul_out_path="/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/flye_ccs/batch7/ccs_demul"

mkdir -p ${demul_out_path}

pbcromwell run pb_ccs_demux -e ${raw_reads_path} -e ${barcodes_xml_path} --output-dir ${demul_out_path} --overwrite --nproc ${SLURM_NTASKS}