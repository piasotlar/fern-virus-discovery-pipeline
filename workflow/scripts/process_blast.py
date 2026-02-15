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

            #ni treba odstranit zrcalnih poravnav 
            # (če samo po imenih odstranimo zrcalne potem odstranimo tudi večkratne poravnave med istima sekvencama pred ani calc kar  ni okej)
            #zrcalne ne vplivajo na rezultate klastriranja
            # če že bi odstranili zrcalne po ani calc!!!!!
