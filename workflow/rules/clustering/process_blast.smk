rule process_blast:
    input: "../results/{sample}/{sample}_blast.tsv"
    output: "../results/{sample}/{sample}_blast_processed.tsv"
    conda: "../../envs/process_blast.yaml"
    script: "../../scripts/process_blast.py"