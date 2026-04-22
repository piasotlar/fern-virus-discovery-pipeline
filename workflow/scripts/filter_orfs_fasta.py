import pandas as pd
import re

table = snakemake.input.table
orfs_fa = snakemake.input.orfs
output_fa = snakemake.output.filtered_orfs
sample = snakemake.wildcards.sample

MIN_LEN = snakemake.params.min_len

df = pd.read_csv(table, sep="\t", dtype=str)

# vzemi samo ta sample
df_sample = df[df["sample"] == sample].copy()


no_hit_ids = set(
    df_sample.loc[
        df_sample["target"].isna() | (df_sample["target"].str.strip() == ""),
        "ORF_ID"
    ].dropna()
)

with open(orfs_fa, "r") as fin, open(output_fa, "w") as fout:
    write_record = False
    current_id = None

    for line in fin:
        if line.startswith(">"):
            current_id = line[1:].strip().split()[0]
            m = re.search(r'length:(\d+)', line)
            if not m:
                raise ValueError(f"Header nima length polja: {line.strip()}")
            
            seq_len = int(m.group(1))
            write_record = current_id in no_hit_ids and seq_len >= MIN_LEN

        if write_record:
            fout.write(line)