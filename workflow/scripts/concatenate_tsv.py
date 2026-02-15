from pathlib import Path

def prefix_from_path(path_str: str) -> str: 
    name = Path(path_str).name 
    sample = name.split("_")[0] 
    return sample
with open(snakemake.output[0], "w") as fout:
    for tsv_path in snakemake.input:
        prefix = prefix_from_path(tsv_path)
        with open(tsv_path, "r") as fin:
            for raw in fin:
                raw = raw.rstrip("\n")
                if not raw:
                    continue
                cols = raw.split("\t")
                cols[0] = f"{prefix}_{cols[0]}"
                fout.write("\t".join(cols) + "\n")
