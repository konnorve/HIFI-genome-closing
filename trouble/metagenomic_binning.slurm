#!/usr/bin/env bash
# 
#SBATCH --job-name=metabat2
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
#SBATCH -n 40
#
#SBATCH --comment="metabat2 troublesome genomes"
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
#SBATCH --array=0,1
#
#SBATCH -o logs/metabat2/%j_%a_slurm_output.txt
#SBATCH -e logs/metabat2/%j_%a_slurm_error.txt


wd="/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/trouble"
genomes=("batch1.bc1020" "batch4.bc1015")
genome=${genomes[$SLURM_ARRAY_TASK_ID]}
wd=${wd}/${genome}
echo $wd

reads=${wd}/"ccs.fastq.gz"
contigs=${wd}/"metaflye_assembly.fasta"
sam_out=${wd}/"mapped.sam"
bam_io=${wd}/"mapped.bam"
depth=${wd}/"covdepth.txt"
bins_dir=${wd}/"metagenomic_bins"
mkdir -p ${bins_dir}

source activate bowtie2

bowtie2-build ${contigs} ${contigs} --threads ${SLURM_NTASKS}
bowtie2 -x ${contigs} -p 20 -U ${reads} -S ${sam_out}

conda deactivate

source activate samtools

samtools view -S -b ${sam_out} > ${bam_io}
rm ${sam_out}
samtools sort ${bam_io} -o ${bam_io} 

conda deactivate

source activate metabat2

jgi_summarize_bam_contig_depths --outputDepth ${depth} --percentIdentity 80 ${bam_io}

metabat2 -i ${contigs} -a ${depth} -o ${bins_dir}

conda deactivate