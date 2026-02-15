from pathlib import Path

def fasta_prefix(path_str: str) -> str:
    name = Path(path_str).name
    sample = name.split("_")[0]
    return sample
def is_binary(file_name):
    try:
        with open(file_name, 'tr') as check_file:
            check_file.read()
            return False
    except Exception:
        return True

with open(snakemake.output[0], "w") as fout:
    for fasta_path in snakemake.input:
        prefix = fasta_prefix(fasta_path)
        if not is_binary(fasta_path):
            with open(fasta_path, "r") as fin:
                for line in fin:
                    if line.startswith(">"):
                        header = line[1:].strip()
                        fout.write(f">{prefix}_{header}\n")
                    else:
                        fout.write(f"{line.strip()}\n")
