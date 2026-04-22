import pandas as pd

table_orfs = snakemake.input.table_orfs
top_hits_files = snakemake.input.mmseqs2_proteins_2
output_table = snakemake.output.table_orfs_2

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

cols_to_fill = [
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

df_orig = pd.read_csv(table_orfs, sep="\t", dtype=str).fillna("")
all_hits = []

for file in top_hits_files:
    try:
        df = pd.read_csv(file, sep="\t", header=None, dtype=str)
    except pd.errors.EmptyDataError:
        continue

    if df.empty:
        continue

    df.columns = protein_cols

    # obdrži samo prvi hit za vsak ORF_ID
    df_first = df.drop_duplicates(subset="ORF_ID", keep="first").copy()
    all_hits.append(df_first)

if not all_hits:
    df_orig.to_csv(output_table, sep="\t", index=False)
else:
    df_second = pd.concat(all_hits, ignore_index=True).fillna("")

    # preimenuj stolpce iz druge baze
    df_second = df_second[["ORF_ID"] + cols_to_fill].rename(
        columns={col: f"{col}_2" for col in cols_to_fill}
    )
    # merge po ORF_ID
    df_merged = df_orig.merge(df_second, on="ORF_ID", how="left")

    # zapolni samo manjkajoče/prazne vrednosti iz druge baze
    for col in cols_to_fill:
        orig_col = df_merged[col].fillna("").astype(str).str.strip()
        second_col = df_merged[f"{col}_2"].fillna("").astype(str).str.strip()

        df_merged[col] = df_merged[col].where(orig_col != "", df_merged[f"{col}_2"])

    # odstrani pomožne _2 stolpce
    df_merged = df_merged[df_orig.columns]

    # shrani
    df_merged.to_csv(output_table, sep="\t", index=False)