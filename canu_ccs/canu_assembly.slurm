#!/usr/bin/env bash
# 
#SBATCH --job-name=ccanu
#
# Specifies using a centos7 node
#SBATCH -C centos7
#
# wall clock limit:
#SBATCH --time 48:00:00
#
# Partition to use:
#SBATCH --partition sched_mit_chisholm
#
# Number of tasks/cores for job
#SBATCH -n 20
#
#SBATCH --comment="canu assembly on ccs"
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
#SBATCH --array=1001,1002,1003,1008,1009,1010,1011,1012
#
#SBATCH -o logs/canu/%j_%a_slurm_output.txt
#SBATCH -e logs/canu/%j_%a_slurm_error.txt


# batch 1: "bc1012" "bc1016" "bc1017" "bc1018" "bc1019" "bc1020" "bc1021" "bc1022"
#           1012,1016,1017,1018,1019,1020,1021,1022
# batch 2: "bc1015" "bc1016" "bc1017" "bc1018" "bc1019" "bc1020" "bc1021" "bc1022"
#           1015,1016,1017,1018,1019,1020,1021,1022
# batch 3: "bc1001" "bc1002" "bc1003" "bc1008" "bc1009" "bc1010" "bc1011" "bc1012"
#           1001,1002,1003,1008,1009,1010,1011,1012
# batch 4: "bc1015" "bc1016" "bc1017" "bc1018" "bc1019" "bc1020" "bc1021" "bc1022"
#           1015,1016,1017,1018,1019,1020,1021,1022
# batch 5: "bc1001" "bc1002" "bc1003" "bc1008" "bc1009" "bc1010" "bc1011" "bc1012"
#           1001,1002,1003,1008,1009,1010,1011,1012
# batch 6: "bc1010" "bc1011" "bc1012" "bc1015" "bc1016" "bc1017" "bc1018" "bc1019"
#           1010,1011,1012,1015,1016,1017,1018,1019
# batch 7: "bc1015" "bc1016" "bc1017" "bc1018" "bc1019" "bc1020" "bc1021" "bc1022"
#           1015,1016,1017,1018,1019,1020,1021,1022
# batch 8: "bc1001" "bc1002" "bc1003" "bc1008" "bc1009" "bc1010" "bc1011" "bc1012"
#           1001,1002,1003,1008,1009,1010,1011,1012

barcode="bc${SLURM_ARRAY_TASK_ID}"

echo ${barcode}
batch_dir="/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/canu_ccs/batch8"

fastq_path=${batch_dir}/"ccs_demul_output"/"demultiplex.${barcode}--${barcode}.hifi_reads.fastq.gz"

assem_bc_dir=${batch_dir}/"canu"/${barcode}

mkdir -p ${assem_bc_dir}

/home/kve/bin/canu-2.2/bin/canu \
   -p assembly \
   -d ${assem_bc_dir} \
   genomeSize=1.5m \
   -pacbio-hifi ${fastq_path} \
   useGrid=false \
   batThreads="${SLURM_NTASKS}"