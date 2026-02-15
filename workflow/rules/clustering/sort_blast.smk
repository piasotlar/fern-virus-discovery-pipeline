rule sort_blast:
    input: "../results/clustering/all_samples_blast_processed.tsv"
    output: "../results/clustering/all_samples_blast_sorted.tsv"
    conda: "../../envs/sort_blast.yaml"
    shell:
        """
        csvtk sort -t -k 1 -k 2 -o {output} {input}
        """