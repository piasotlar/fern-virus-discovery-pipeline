import pandas as pd
import snakemake

tsv = snakemake.input.tsv
output_tsv = snakemake.output.filtered_tsv

df = pd.read_csv(tsv, sep="\t")


filtered_df = df[df["tax-lineage"].str.contains("Viruses", na=False)]

filtered_df.to_csv(output_tsv, 
                   sep="\t", 
                   index=False,
                   #header=False
                   )

