rule process_blast:
    input: "../results/clustering/all_samples_blast.tsv"
    output: "../results/clustering/all_samples_blast_processed.tsv"
    conda: "../../envs/process_blast.yaml"
    script: "../../scripts/process_blast.py"