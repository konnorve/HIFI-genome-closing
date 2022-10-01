import pandas as pd
from Bio import SeqIO
from pathlib import Path

working_dir = Path("/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project")
all_assemblies_dir = working_dir / "all_methods_all_assemblies"
circ_report_path = working_dir / "reports" / "all_circular_report.tsv"
circ_genome_output_dir = working_dir / "all_circ_genomes"

allcontigs2pull = pd.read_table(circ_report_path)

for assembly in all_assemblies_dir.iterdir():
    elements = assembly.name.split(".")
    batch = elements[0]
    barcode = elements[1]
    method = elements[2]

    assemblycontigs2pull = allcontigs2pull[(allcontigs2pull.batch==batch) & (allcontigs2pull.barcode==barcode) & (allcontigs2pull.method==method)]
    numcontigs2pull = len(assemblycontigs2pull)

    print(batch, barcode, method, numcontigs2pull, sep='\t')
    if numcontigs2pull > 0:
        contigs = assemblycontigs2pull.contig_name.to_list()

        contigs_pulled = 0
        for record in SeqIO.parse(assembly, "fasta"):
            if record.id in contigs:
                contigs_pulled+=1
                genome_outfile = f"{batch}.{barcode}.{contigs_pulled}.{method}.assembly.fasta"
                SeqIO.write([record], circ_genome_output_dir / genome_outfile, "fasta")

        assert contigs_pulled == numcontigs2pull

    


