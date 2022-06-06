#!/usr/bin/env bash
# 
#SBATCH --job-name=mapext
#
# Specifies using a centos7 node
#SBATCH -C centos7
#
# wall clock limit:
#SBATCH --time 12:00:00
#
# Partition to use:
#SBATCH --partition newnodes
#
# Number of tasks/cores for job
#SBATCH -n 48
#
#SBATCH --comment="filter batch1 bc1020 subreadset using bowtie2, samtools, and classified contigs"
#
# emails all notifications
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kve@mit.edu
#
# Request nodes:
#SBATCH --nodes=1
#
#SBATCH --mem 1000G
#
#SBATCH -o logs/map_and_extract/%j_%a_slurm_output.txt
#SBATCH -e logs/map_and_extract/%j_%a_slurm_error.txt

wd="/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/trouble/batch4.bc1015"

readset=$wd/"subreadset.fastq"
filtered_readset=${wd}/"subreadset.filtered.local.fastq"
filtered_contigs=$wd/"filtered_contigs.fasta"
sam_out=$wd/"subreadset_mapped.sam"

source activate bowtie2

bowtie2-build ${filtered_contigs} ${filtered_contigs} --threads ${SLURM_NTASKS}
bowtie2 --local -x ${filtered_contigs} -p ${SLURM_NTASKS} -U ${readset} -S ${sam_out}

conda deactivate
source activate samtools

samtools fastq -F 4 -@ ${SLURM_NTASKS} ${sam_out} > ${filtered_readset}

rm ${sam_out}