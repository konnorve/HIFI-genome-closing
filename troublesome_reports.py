import pandas as pd
from pathlib import Path

working_dir = Path("/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project")

all_reports = pd.read_table(working_dir / 'reports' / 'all_results.tsv')

to_subset = {
    'batch1.bc1020':{
        'batch':'batch1',
        'barcode':'bc1020',
        'classification':[
            'Synechococcus'
        ]
    },
    'batch4.bc1015':{
        'batch':'batch4',
        'barcode':'bc1015',
        'classification':[
            'Prochlorococcus'
        ]
    }
}

def contains(x, l):
    for i in l:
        if isinstance(x, str) and i in x:
            return True
    return False

for k, v in to_subset.items():
    subset_df = all_reports[(all_reports['barcode']==v['barcode']) & (all_reports['batch']==v['batch'])]

    subset_df = subset_df[all_reports.classification.apply(lambda x: contains(x, v['classification']))]

    subset_df.to_csv(working_dir / 'trouble' / k / f"filtered_contigs.tsv", sep='\t', index=False)

