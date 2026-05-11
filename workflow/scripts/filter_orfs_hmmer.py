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


# ORFi brez zadetka
no_hit = df_sample["target"].str.strip() == ""

# hypothetical annotation
hypothetical = df_sample["theader"].str.contains(
    "hypothetical",
    case=False,
    na=False
)

# ORF_ID-ji, ki jih želimo obdržati
keep_ids = set(
    df_sample.loc[
        no_hit | hypothetical,
        "ORF_ID"
    ]
)


with open(orfs_fa, "r") as fin, open(output_fa, "w") as fout:
    write_record = False

    for line in fin:
        if line.startswith(">"):
            current_id = line[1:].strip().split()[0]

            m = re.search(r"length:(\d+)", line)

            if not m:
                raise ValueError(
                    f"Header nima length polja: {line.strip()}"
                )

            seq_len = int(m.group(1))

            write_record = (
                current_id in keep_ids
                and seq_len >= MIN_LEN
            )

        if write_record:
            fout.write(line)
