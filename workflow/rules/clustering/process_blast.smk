rule process_blast:
    input: "../results/{sample}/{sample}_blast.tsv"
    output: "../results/{sample}/{sample}_blast_processed.tsv"
    conda: "../../envs/process_blast.yaml"
    log: "../logs/clustering/process_blast/{sample}.log"
    script: "../../scripts/process_blast.py"