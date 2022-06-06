import pandas as pd
from pathlib import Path

report_dir = Path("/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/reports")

reports = ["canu_subreadset.tsv",
"flye_subreadset.tsv",
"metaflye_subreadset.tsv",
"canu_ccs.tsv",
"flye_ccs.tsv",
"metaflye_ccs.tsv"]

flye_reports = [x for x in reports if 'flye' in x]
canu_reports = [x for x in reports if 'canu' in x]

print(flye_reports)
print(canu_reports)

flye_dfs = []
for r in flye_reports:
    df = pd.read_table(report_dir / r)
    df['method'] = r.split('.')[0]
    flye_dfs.append(df)

flye_df = pd.concat(flye_dfs, ignore_index=True)

canu_dfs = []
for r in canu_reports:
    df = pd.read_table(report_dir / r)
    df['method'] = r.split('.')[0]
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