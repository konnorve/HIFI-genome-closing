#!/usr/bin/env bash
# 
#SBATCH --job-name=kaiju
#
# Specifies using a centos7 node
#SBATCH -C centos7
#
# wall clock limit:
#SBATCH --time 1:00:00
#
# Partition to use:
#SBATCH --partition sched_mit_chisholm
#
# Number of tasks/cores for job
#SBATCH -n 1
#
#SBATCH --comment="Kaiju on Canu Assembly"
#
# emails all notifications
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kve@mit.edu
#
#SBATCH --mem 150G
#
#   # SBATCH --array=1001,1002,1003,1008,1009,1010,1011,1012
#
#SBATCH -o logs/kaiju/%j_%a_slurm_output.txt
#SBATCH -e logs/kaiju/%j_%a_slurm_error.txt

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
barcode="bc1001" # ${SLURM_ARRAY_TASK_ID}

BATCH_DIR="/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/canu_subreadset/batch5"
ASSEMBLY_DIR=${BATCH_DIR}/"canu"
KAIJU_CLASSIFICATION_DIR=${BATCH_DIR}/"kaiju"
KAIJU_DB_DIR="/pool001/kve/kaiju_db"

echo ${barcode}

mkdir -p ${KAIJU_CLASSIFICATION_DIR}

assembly_path=${ASSEMBLY_DIR}/${barcode}/"assembly.contigs.fasta"
kaiju_bc_result_txt=${KAIJU_CLASSIFICATION_DIR}/"kaiju_classification_output.${barcode}.txt"
kaiju_bc_result_table=${KAIJU_CLASSIFICATION_DIR}/"kaiju_classification_output.${barcode}.tsv"
kaiju_bc_result_names=${KAIJU_CLASSIFICATION_DIR}/"kaiju_classification_output_named.${barcode}.tsv"
kaiju_bc_result_name_class=${KAIJU_CLASSIFICATION_DIR}/"kaiju_classification_output_named_classified.${barcode}.tsv"
kaiju_index_file=${KAIJU_DB_DIR}/"refseq/kaiju_db_refseq.fmi"
nodes_dmp=${KAIJU_DB_DIR}/"nodes.dmp"
names_dmp=${KAIJU_DB_DIR}/"names.dmp"

echo ${assembly_path}
echo ${kaiju_bc_dir}

/home/kve/bin/kaiju/bin/kaiju -v -t ${nodes_dmp} -f ${kaiju_index_file} -i ${assembly_path} -o ${kaiju_bc_result_txt} -z ${SLURM_NTASKS}

/home/kve/bin/kaiju/bin/kaiju2table -t ${nodes_dmp} -n ${names_dmp} -r genus -o ${kaiju_bc_result_table} ${kaiju_bc_result_txt}

/home/kve/bin/kaiju/bin/kaiju-addTaxonNames -t ${nodes_dmp} -n ${names_dmp} -i ${kaiju_bc_result_txt} -o ${kaiju_bc_result_names}

# removed unclassified contigs
sed '/^U/d' ${kaiju_bc_result_names} > ${kaiju_bc_result_name_class}
