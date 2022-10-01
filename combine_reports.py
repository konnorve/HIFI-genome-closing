import pandas as pd
from pathlib import Path

report_dir = Path("/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/reports")

flye_reports = [
    Path("/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/flye_ccs/all_batches_assembly_report.tsv"),
    Path("/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/flye_subreadset/all_batches_assembly_report.tsv"),
    Path("/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/metaflye_ccs/all_batches_assembly_report.tsv"),
    Path("/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/metaflye_subreadset/all_batches_assembly_report.tsv")
]

canu_reports = [
    Path("/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/canu_ccs/all_batches_assembly_report.tsv"),
    Path("/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/canu_subreadset/all_batches_assembly_report.tsv")
]

spades_report = Path("/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/reports/SPAdes_results.tsv")

flye_dfs = []
for r in flye_reports:
    df = pd.read_table(r)
    df['method'] = r.parent.name
    flye_dfs.append(df)

flye_df = pd.concat(flye_dfs, ignore_index=True)

canu_dfs = []
for r in canu_reports:
    df = pd.read_table(r)
    df['method'] = r.parent.name
    canu_dfs.append(df)

canu_df = pd.concat(canu_dfs, ignore_index=True)

flye_df = flye_df.rename(columns={'cov.':'coverage', 'circ.':'circular', 'Named Classification':'classification'})
canu_df = canu_df.rename(columns={'tigLen':'length', 'sugCirc':'circular', 'sugRept':'repeat', 'Named Classification':'classification'})

canu_df = canu_df.replace({
    'circular':{
        'yes':'Y',
        'no':'N'
    },
    'repeat':{
        'yes':'Y',
        'no':'N'
    },
})

cols2keep = ['method','batch', 'barcode', 'contig_name', 'length', 'coverage', 'circular', 'repeat', 'classification']
all_reports = pd.concat([flye_df[cols2keep], canu_df[cols2keep]], ignore_index=True)

all_reports.to_csv(report_dir / 'all_results.tsv', sep='\t', index=False)

circular_report_less_SPAdes = all_reports[(all_reports['circular']=='Y') & (all_reports['length'] > 1000000)]

circular_report_less_SPAdes = circular_report_less_SPAdes.drop(columns=['repeat'])

circular_report_less_SPAdes.to_csv(report_dir / 'circular_report_less_SPAdes.tsv', sep='\t', index=False)

spades_report = pd.read_table(spades_report)

all_circular_report = pd.concat([circular_report_less_SPAdes, spades_report], ignore_index=True)

all_circular_report.to_csv(report_dir / 'all_circular_report.tsv', sep='\t', index=False)

# less_batch6 = all_circular_report[all_circular_report['batch'] != 'batch6']

# less_batch6.to_csv(report_dir / 'less_batch6.tsv', sep='\t', index=False)