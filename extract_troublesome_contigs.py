import pandas as pd
from Bio import SeqIO
from pathlib import Path

working_dir = Path("/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project")

for batch_barcode_dir in (working_dir / 'trouble').iterdir():
    contigs2pull = pd.read_table(batch_barcode_dir / 'filtered_contigs.tsv')

    print(contigs2pull)

    batch, barcode = batch_barcode_dir.name.split(".")
    unique_methods = contigs2pull['method'].unique()

    records = []

    for method in unique_methods:
        assemblycontigs2pull = contigs2pull[contigs2pull['method'] == method]
        numcontigs2pull = len(assemblycontigs2pull)

        print(batch, barcode, method, numcontigs2pull, sep='\t')
        if numcontigs2pull > 0:
            contigs = assemblycontigs2pull.contig_name.to_list()
            contigs_pulled = 0
            for record in SeqIO.parse(working_dir / "all_methods_all_assemblies" / f"{batch}.{barcode}.{method}.assembly.fasta", "fasta"):
                if record.id in contigs:
                    contigs_pulled+=1
                    record.description = f"{batch} {barcode} {method} {record.id}"
                    record.id = f"{batch}.{barcode}.{method}.{record.id}"
                    records.append(record)
            assert contigs_pulled == numcontigs2pull
    
    SeqIO.write(records, batch_barcode_dir / 'filtered_contigs.fasta', "fasta")


        