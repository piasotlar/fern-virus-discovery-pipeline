import argparse



def get_ids_from_tsv(tsv_path):
    ids = set()
    with open(tsv_path, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            id = line.split('\t',1)[0]
            ids.add(id)
    return ids

def virus_fasta(fasta_path, out_virus_fasta, ids):
    header = None
    with open(out_virus_fasta, "w") as vf:
        with open(fasta_path, "r") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                if line.startswith('>'):
                    header = line[1:].split()[0]
                    if header in ids:
                        vf.write(f">{header}\n")
                else:
                    if header in ids:
                        vf.write(f"{line}\n")


def main():
    parser = argparse.ArgumentParser(description="Filtriranje kontigov.")
    parser.add_argument("--tsv", required=True, help="Pot do filtrirane TSV datoteke")
    parser.add_argument("--fasta", required=True, help="Pot do originalne FASTA datoteke")
    parser.add_argument("--out-fasta", required=True, help="Izhodna FASTA datoteka")

    args = parser.parse_args()

    ids = get_ids_from_tsv(args.tsv)

    virus_fasta(args.fasta, args.out_fasta, ids)


if __name__ == "__main__":
    main()