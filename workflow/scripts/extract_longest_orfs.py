
import pandas as pd
from Bio import SeqIO

bed_path = snakemake.input.bed
orf_fasta_path = snakemake.input.dna
output_fa = snakemake.output.fa
output_txt = snakemake.output.txt

df = pd.read_csv(bed_path, sep="\t", header=None)

orf_records = {record.id: record for record in SeqIO.parse(orf_fasta_path, "fasta")}

with open(output_fa, "w") as f, open(output_txt, "w") as f2:
    f2.write("ORF_ID\tcontig_len\torf_len\torf_perc\n")

    for line in df[3]:
        orf_id = line.split(";")[0].replace("ID=", "")
        length = int(line.split("_length_")[1].split("_")[0])

        if orf_id in orf_records:
            record = orf_records[orf_id]
            orf_len = len(record.seq)
            orf_perc = round((orf_len / length) * 100, 2)

            f.write(f">{record.id}\n{record.seq}\n")
            f2.write(f"{record.id}\t{length}\t{orf_len}\t{orf_perc}\n")

