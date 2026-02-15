from pathlib import Path

def get_representatives(clusters_fasta):
    reps = list()
    with open(clusters_fasta, "r") as fin:
        for line in fin:
            line = line.strip()
            rep = line.split("\t", 1)[0]
            reps.append(rep)
    return reps

def extract_length_from_id(seq_id: str):
    # pričakuje ..._length_10994_...
    marker = "_length_"
    if marker not in seq_id:
        return None
    tail = seq_id.split(marker, 1)[1]      # "10994_cov_..."
    num = tail.split("_", 1)[0]            # "10994"
    try:
        return int(num)
    except ValueError:
        return None
    
def filter_reps(reps, min, max):
    kept = []
    for rep in reps:
        L = extract_length_from_id(rep)
        if L is None or L >= int(min) or L <= int(max):
            kept.append(rep)
    return kept

def write_representatives_tsv(reps, tsv_all, tsv_reps):
    with open(tsv_all, "r") as fin, open(tsv_reps, "w") as fout:
        for line in fin:
            line = line.strip()
            if not line:
                continue
            id = line.split('\t',1)[0]
            if id in reps:
                fout.write(line + '\n')

def write_representatives_fasta(reps, fasta_all, fasta_reps):
    reps_set = set(reps)
    with open(fasta_all, "r") as fin, open(fasta_reps, "w") as fout:
        write_flag = False
        for line in fin:
            line = line.rstrip("\n")
            if line.startswith('>'):
                id = line[1:].split()[0]
                if id in reps_set:
                    write_flag = True
                    fout.write(line + "\n")
                else:
                    write_flag = False
            else:
                if write_flag:
                    fout.write(line + "\n")

def main():
    clusters_fasta = snakemake.input.clusters
    tsv_all = snakemake.input.tsv
    fasta_all = snakemake.input.contigs
    tsv_reps = snakemake.output.reps_tsv
    fasta_reps = snakemake.output.reps_fasta

    reps = get_representatives(clusters_fasta)
    filtered_reps = filter_reps(reps, snakemake.params.min_length, snakemake.params.max_length)
    write_representatives_tsv(filtered_reps, tsv_all, tsv_reps)
    write_representatives_fasta(filtered_reps, fasta_all, fasta_reps)

main()