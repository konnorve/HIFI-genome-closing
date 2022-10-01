from pathlib import Path
import pandas as pd

def main():
    errors = []
    for assembly_method_dir in Path("/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project").glob("*flye*"):
        all_dfs = {}
        for batch_dir in sorted(assembly_method_dir.iterdir()):
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
        all_assembly_report.to_csv(assembly_method_dir / f"all_batches_assembly_report.tsv", sep='\t')
    
    for e in errors:
        raise e
            

# strain_ID_df = pd.read_csv(Path(snakemake.input.s_ids_tsv), sep="\t")

# strain_ID_df['forward barcode'] = strain_ID_df['reverse barcode'] = strain_ID_df['Barcode']

# genome_df_list = []

# for report_path_str in genome_report_paths:
#     report_path = Path(report_path_str)

#     with open(report_path) as f:
#         data = json.load(f)

#     columns_dict_list = data.get('tables')[0].get('columns')

#     barcode_df = pd.DataFrame()

#     barcode_str = report_path.parent.parent.name
#     fwd_bc, rev_bc = (barcode_str, barcode_str)

#     for c, vals in [(c.get('header'), c.get('values')) for c in columns_dict_list]:
#         barcode_df[c] = vals

#     sort_order = ['forward barcode', 'reverse barcode'] + barcode_df.columns.tolist()

#     barcode_df['forward barcode'] = fwd_bc
#     barcode_df['reverse barcode'] = rev_bc

#     barcode_df = barcode_df[sort_order]

#     genome_df_list.append(barcode_df)

# genome_df = pd.concat(genome_df_list)

# genome_df = strain_ID_df.merge(genome_df, how='right',on=['forward barcode', 'reverse barcode'])

# df_out_path = Path(snakemake.output.dataframe_path)

# df_out_path.parent.mkdir(parents=True, exist_ok=True)

# genome_df.to_csv(df_out_path, sep='\t')

if __name__ == "__main__":
    main()