import pandas as pd
import plotly.express as px


df = pd.read_table("/nfs/chisholmlab001/kve/2021_HIFI_Genome_Closing_Project/reports/all_results.tsv")
df['seq_amt'] = df['length'] * df['coverage']
df = df.groupby(['method',	'batch'])['seq_amt'].sum().reset_index()

fig = px.scatter(df[df['method'].str.contains('subreadset')], x="batch", y="seq_amt", color='method')
fig.write_html('seq_depth_subreadset.html')

fig = px.scatter(df[df['method'].str.contains('ccs')], x="batch", y="seq_amt", color='method')
fig.write_html('seq_depth_ccs.html')