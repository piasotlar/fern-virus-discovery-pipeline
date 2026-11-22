seen = set()

with open(snakemake.output[0], "w") as fout:
    with open(snakemake.input[0]) as fin:
        for line in fin:
            line = line.strip()
            if not line:
                continue

            cols = line.split()
            q, s = cols[0], cols[1]

            if q == s:
                continue

            fout.write("\t".join(cols) + "\n")

