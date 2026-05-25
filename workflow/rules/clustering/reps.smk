rule get_cluster_representatives:
    input:
        clusters = "../results/{sample}/{sample}_clusters.tsv",
        contigs = "../results/{sample}/{sample}_virus_contigs.fasta",
        tsv = "../results/{sample}/{sample}_taxonomy_filtered.tsv"
    output:
        reps_tsv = "../results/{sample}/{sample}_representatives.tsv",
        reps_fasta = "../results/{sample}/{sample}_representatives.fasta"
    params:
        min_length = 500,
        max_length = 25000
    conda:
        "../../envs/reps.yaml"
    log: "../logs/clustering/reps/{sample}.log"
    script: "../../scripts/get_cluster_representatives.py"
