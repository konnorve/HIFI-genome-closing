from pathlib import Path
import pandas as pd

def main():
    errors = []
    workflow_dir = Path("/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/flye_ccs_assemblies")
    all_dfs = {}
    for batch_dir in sorted(workflow_dir.iterdir()):
        if batch_dir.is_dir():
            barcodes = [x.name for x in sorted((batch_dir / "flye").iterdir())]
            dfs = {}
            for barcode in barcodes:
                assem_info_path = batch_dir / "flye" / barcode / "assembly_info.txt"
                class_info_path = batch_dir / "kaiju" / f"kaiju_classification_output_named_classified.{barcode}.tsv"
                if not class_info_path.exists():
                    class_info_path = batch_dir / "kaiju" / f"kaiju_classification_output_named.{barcode}.tsv"
                
                if assem_info_path.exists() and class_info_path.exists():
                    assem_info_df = pd.read_csv(assem_info_path, sep="\t")
                    assem_info_df = assem_info_df.rename(columns={"#seq_name":"contig_name"})
                    
                    classification_table_columns = ['Classified?', 'contig_name', 'NCBI taxon identifier', 'length/score of best match', 'multiple taxon identifiers', 'accession number of best match squences', 'matching fragement sequences', 'Named Classification']
                    try:
                        class_info_df = pd.read_csv(class_info_path, sep="\t", header=None)
                        classification_columns_dict = {k:v for k, v in zip(range(len(classification_table_columns)), classification_table_columns)}
                        class_info_df = class_info_df.rename(columns=classification_columns_dict)

                        class_info_df = class_info_df.set_index("contig_name")
                        assem_info_df = assem_info_df.set_index("contig_name")

                        assem_info_df = assem_info_df.join(class_info_df['Named Classification'])

                        dfs[barcode] = assem_info_df
                    except pd.errors.ParserError as error:
                        print(class_info_path)
                        errors.append(error)
                
            batch_assembly_report = pd.concat(dfs, names=['barcode'])
            batch_assembly_report.to_csv(batch_dir / f"{batch_dir.name}_assembly_report.tsv", sep='\t')

            all_dfs[batch_dir.name] = batch_assembly_report

    all_assembly_report = pd.concat(all_dfs, names=['batch'])
    all_assembly_report.to_csv(workflow_dir / f"all_batches_assembly_report.tsv", sep='\t')
    
    for e in errors:
        raise e
            

if __name__ == "__main__":
    main()