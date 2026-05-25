import pandas as pd
import re

all_dfs = []

protein_cols = [
    "ORF_ID",
    "target",
    "theader",
    "evalue",
    "pident",
    "qlen",
    "tlen",
    "alnlen",
    "bits",
    "protein_taxonomy"
]

orf_cols = [
    "sample",
    "contig",
    "orf",
    "ORF_ID",
    "length"
]

for orfs, top_hits in zip(snakemake.input.orfs, snakemake.input.mmseqs2_proteins):

    sample_name = top_hits.split("/")[-2]

    orf_rows = []
    with open(orfs, "r") as f:
        for line in f:
            if line.startswith(">"):
                header = line[1:].strip()
                orf_full = header.split()[0]
                orf_short = orf_full.split("_")[-1]

                m = re.search(r'length:(\d+)', line)
                seq_len = int(m.group(1)) if m else 0

                match = re.match(r"(NODE_\d+)", orf_full)
                contig = match.group(1) if match else "NA"

                orf_rows.append({
                    "sample": sample_name,
                    "contig": contig,
                    "orf": orf_short,
                    "ORF_ID": orf_full,
                    "length": seq_len
                })

    df_orfs = pd.DataFrame(orf_rows, columns=orf_cols).drop_duplicates()

    try:
        df_proteins = pd.read_csv(
            top_hits,
            sep="\t",
            header=None,
            dtype=str
        )

        if df_proteins.empty:
            df_proteins = pd.DataFrame(columns=protein_cols)
        else:
            df_proteins.columns = protein_cols
    except pd.errors.EmptyDataError:
        df_proteins = pd.DataFrame(columns=protein_cols)

    df_proteins_first = (
        df_proteins
        .drop_duplicates(subset="ORF_ID", keep="first")
        [[
            "ORF_ID",
            "target",
            "theader",
            "evalue",
            "pident",
            "qlen",
            "tlen",
            "alnlen",
            "bits",
            "protein_taxonomy"
        ]]
    )

    df_merged = (
        df_orfs
        .merge(df_proteins_first, on="ORF_ID", how="left")
        .sort_values(["sample", "contig", "orf"])
        .reset_index(drop=True)
    )

    all_dfs.append(df_merged)

if all_dfs:
    final_df = pd.concat(all_dfs, ignore_index=True)
else:
    final_df = pd.DataFrame(columns=orf_cols + protein_cols[1:])

final_df.to_csv(snakemake.output.table, sep="\t", index=False)