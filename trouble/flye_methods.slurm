#!/usr/bin/env bash
# 
#SBATCH --job-name=flye1
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
#SBATCH --comment="flye assembly on batch"
#
# emails all notifications
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kve@mit.edu
#
# Request nodes:
#SBATCH --nodes=1
#
# Number of tasks/cores for job
#SBATCH -n 20
#
#SBATCH --mem 250000
#
#SBATCH -o logs/flye/%j_slurm_output.txt
#SBATCH -e logs/flye/%j_slurm_error.txt

batch_dir="/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/trouble/batch1.bc1020"

source activate flye

ccs_path=${batch_dir}/"ccs.filtered.local.fastq"
subreadset_path=${batch_dir}/"subreadset.filtered.local.fastq"
filtering_method_dir=${batch_dir}/"local_filtering"

out_dir=${filtering_method_dir}/"flye_ccs"
mkdir -p $out_dir && echo $out_dir
flye --pacbio-hifi ${ccs_path} --out-dir ${out_dir} -t ${SLURM_NTASKS}

out_dir=${filtering_method_dir}/"flye_subreadset"
mkdir -p $out_dir && echo $out_dir
flye --pacbio-raw ${subreadset_path} --out-dir ${out_dir} -t ${SLURM_NTASKS}

out_dir=${filtering_method_dir}/"metaflye_ccs"
mkdir -p $out_dir && echo $out_dir
flye --meta --pacbio-hifi ${ccs_path} --out-dir ${out_dir} -t ${SLURM_NTASKS}

out_dir=${filtering_method_dir}/"metaflye_subreadset"
mkdir -p $out_dir && echo $out_dir
flye --meta --pacbio-raw ${subreadset_path} --out-dir ${out_dir} -t ${SLURM_NTASKS}

conda deactivate

kaiju_index_file="/nobackup1b/users/chisholmlab/databases_kve/kaiju-20220425/refseq/kaiju_db_refseq.fmi"
nodes_dmp="/nobackup1b/users/chisholmlab/databases_kve/kaiju-20220425/nodes.dmp"
names_dmp="/nobackup1b/users/chisholmlab/databases_kve/kaiju-20220425/names.dmp"


for method in "metaflye_ccs" "flye_ccs" "flye_subreadset" "metaflye_subreadset"
do
    echo ${method}
    ASSEMBLY_DIR=${filtering_method_dir}/${method}
    mkdir -p ${ASSEMBLY_DIR}
    assembly_path=${ASSEMBLY_DIR}/"assembly.fasta"
    kaiju_bc_result_txt=${ASSEMBLY_DIR}/"kaiju_classification_output.txt"
    kaiju_bc_result_table=${ASSEMBLY_DIR}/"kaiju_classification_output.tsv"
    kaiju_bc_result_names=${ASSEMBLY_DIR}/"kaiju_classification_output_named.tsv"
    kaiju_bc_result_name_class=${ASSEMBLY_DIR}/"kaiju_classification_output_named_classified.tsv"

    echo ${assembly_path}
    echo ${kaiju_bc_dir}

    /home/kve/bin/kaiju/bin/kaiju -v -t ${nodes_dmp} -f ${kaiju_index_file} -i ${assembly_path} -o ${kaiju_bc_result_txt} -z ${SLURM_NTASKS}

    /home/kve/bin/kaiju/bin/kaiju2table -t ${nodes_dmp} -n ${names_dmp} -r genus -o ${kaiju_bc_result_table} ${kaiju_bc_result_txt}

    /home/kve/bin/kaiju/bin/kaiju-addTaxonNames -t ${nodes_dmp} -n ${names_dmp} -i ${kaiju_bc_result_txt} -o ${kaiju_bc_result_names}

    # removed unclassified contigs
    sed '/^U/d' ${kaiju_bc_result_names} > ${kaiju_bc_result_name_class}

    rm ${kaiju_bc_result_table} ${kaiju_bc_result_txt} ${kaiju_bc_result_names}
done

