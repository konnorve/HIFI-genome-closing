import pandas as pd
from pathlib import Path

wd=Path("/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/trouble/")

for sample in wd.iterdir():
    contig_assignment = pd.read_table(sample / "contig_assignment.tsv", names=["bin","contig"])
    contig_coverages = pd.read_table(sample / "contig_coverages.tsv")
    bin_classification = pd.read_table(sample / "gtdbtk_classify_wf" / "classify" / "gtdbtk.bac120.summary.tsv")

    contig_assignment = contig_assignment.set_index("contig")

    contig_coverages = contig_coverages.rename(columns={"#rname":"contig"})
    contig_coverages = contig_coverages.set_index("contig")

    bin_classification["bin"] = bin_classification["user_genome"] + ".fa"
    bin_classification = bin_classification.set_index("bin")

    df = contig_coverages.join(contig_assignment)
    df = df.fillna({'bin':'unbinned'})

    df['depthXlength'] = df['endpos'] * df['meandepth']

    df2 = df[['bin', 'depthXlength', 'endpos', 'numreads']].groupby('bin').sum()

    df2['meandepth'] = df2['depthXlength'] / df2['endpos']
    
    df2 = df2.join(bin_classification)

    df2[['meandepth', 'classification', 'endpos', 'numreads']].to_csv(sample / f"{sample.name}_bin_coverage.tsv", sep="\t")