rule sort_blast:
    input: "../results/{sample}/{sample}_blast_processed.tsv"
    output: "../results/{sample}/{sample}_blast_sorted.tsv"
    conda: "../../envs/sort_blast.yaml"
    log: "../logs/clustering/sort_blast/{sample}.log"
    shell:
        """
        csvtk sort -t -k 1 -k 2 -o {output} {input} \
            > {log} 2>&1
        """