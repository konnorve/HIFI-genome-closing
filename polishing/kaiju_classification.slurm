#!/usr/bin/env bash
# 
#SBATCH --job-name=kaiju
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
#SBATCH -n 1
#
#SBATCH --comment="Kaiju on all assemblies"
#
# emails all notifications
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kve@mit.edu
#
#SBATCH --mem 150G
#
#
#SBATCH -o logs/kaiju/%j_slurm_output.txt
#SBATCH -e logs/kaiju/%j_slurm_error.txt


BATCH_DIR="/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project"
ASSEMBLY_DIR=${BATCH_DIR}/"all_circ_genomes"
KAIJU_CLASSIFICATION_DIR=${BATCH_DIR}/"all_circ_genomes_kaiju"

kaiju_index_file="/nobackup1b/users/chisholmlab/databases_kve/kaiju-20220425/refseq/kaiju_db_refseq.fmi"
nodes_dmp="/nobackup1b/users/chisholmlab/databases_kve/kaiju-20220425/nodes.dmp"
names_dmp="/nobackup1b/users/chisholmlab/databases_kve/kaiju-20220425/names.dmp"

mkdir -p ${KAIJU_CLASSIFICATION_DIR}

for assembly_path in ${ASSEMBLY_DIR}/*
do
    assembly_file_name=$(basename "$assembly_path")
    assembly_name="${assembly_file_name%.*}"

    echo $assembly_name

    kaiju_bc_result_txt=${KAIJU_CLASSIFICATION_DIR}/"kaiju_classification_output.${assembly_name}.txt"
    kaiju_bc_result_table=${KAIJU_CLASSIFICATION_DIR}/"kaiju_classification_output.${assembly_name}.tsv"
    kaiju_bc_result_names=${KAIJU_CLASSIFICATION_DIR}/"kaiju_classification_output_named.${assembly_name}.tsv"
    kaiju_bc_result_name_class=${KAIJU_CLASSIFICATION_DIR}/"kaiju_classification_output_named_classified.${assembly_name}.tsv"

    /home/kve/bin/kaiju/bin/kaiju -v -t ${nodes_dmp} -f ${kaiju_index_file} -i ${assembly_path} -o ${kaiju_bc_result_txt} -z ${SLURM_NTASKS}

    /home/kve/bin/kaiju/bin/kaiju2table -t ${nodes_dmp} -n ${names_dmp} -r genus -o ${kaiju_bc_result_table} ${kaiju_bc_result_txt}

    /home/kve/bin/kaiju/bin/kaiju-addTaxonNames -t ${nodes_dmp} -n ${names_dmp} -i ${kaiju_bc_result_txt} -o ${kaiju_bc_result_names}

    # removed unclassified contigs
    sed '/^U/d' ${kaiju_bc_result_names} > ${kaiju_bc_result_name_class}

    rm $kaiju_bc_result_txt $kaiju_bc_result_table $kaiju_bc_result_names

done