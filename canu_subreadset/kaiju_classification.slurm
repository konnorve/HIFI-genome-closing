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
#SBATCH -n 20
#SBATCH --mem 250G
#
#SBATCH --comment="Kaiju on Flye Assembly"
#
# emails all notifications
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kve@mit.edu
#
#SBATCH --array=1001,1002,1003,1008,1009,1010,1011,1012
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
# batch 6: "bc1010" "bc1011" "bc1012" "bc1015" "bc1016" "bc1017" "bc1018" "bc1019"
#           1010,1011,1012,1015,1016,1017,1018,1019
# batch 7: "bc1015" "bc1016" "bc1017" "bc1018" "bc1019" "bc1020" "bc1021" "bc1022"
#           1015,1016,1017,1018,1019,1020,1021,1022
# batch 8: "bc1001" "bc1002" "bc1003" "bc1008" "bc1009" "bc1010" "bc1011" "bc1012"
#           1001,1002,1003,1008,1009,1010,1011,1012

barcode="bc${SLURM_ARRAY_TASK_ID}"

BATCH_DIR="/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/canu_subreadset/batch8"
ASSEMBLY_DIR=${BATCH_DIR}/"canu"
KAIJU_CLASSIFICATION_DIR=${BATCH_DIR}/"kaiju"
KAIJU_DB_DIR="/nobackup1/chisholmlab/databases_kve/kaiju-20220425"

mkdir -p ${KAIJU_CLASSIFICATION_DIR}

echo ${barcode}

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

source activate kaiju

kaiju -v -t ${nodes_dmp} -f ${kaiju_index_file} -i ${assembly_path} -o ${kaiju_bc_result_txt} -z ${SLURM_NTASKS}

kaiju2table -t ${nodes_dmp} -n ${names_dmp} -r genus -o ${kaiju_bc_result_table} ${kaiju_bc_result_txt}

kaiju-addTaxonNames -t ${nodes_dmp} -n ${names_dmp} -i ${kaiju_bc_result_txt} -o ${kaiju_bc_result_names}

# removed unclassified contigs
sed '/^U/d' ${kaiju_bc_result_names} > ${kaiju_bc_result_name_class}

