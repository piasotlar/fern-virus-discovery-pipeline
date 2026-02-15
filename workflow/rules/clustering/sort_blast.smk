rule sort_blast:
    input: "../results/{sample}/{sample}_blast_processed.tsv"
    output: "../results/{sample}/{sample}_blast_sorted.tsv"
    conda: "../../envs/sort_blast.yaml"
    shell:
        """
        csvtk sort -t -k 1 -k 2 -o {output} {input}
        """