
import sys
import pandas as pd
 
tsv = sys.argv[1]
output_tsv = sys.argv[2]
 
df = pd.read_csv(tsv, sep="\t", header=None, engine="python", on_bad_lines="skip")
lineage_col = df.columns[-1]
filtered_df = df[df[lineage_col].astype(str).str.contains("Viruses", na=False)]
filtered_df.to_csv(output_tsv, sep="\t", index=False, header=False)
