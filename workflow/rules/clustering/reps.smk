rule get_cluster_representatives:
    input:
        clusters = "../results/clustering/clusters.tsv",
        contigs = "../results/clustering/all_virus_contigs.fasta",
        tsv = "../results/clustering/all_viruses.tsv" #spremeni potem v {sample}
    output:
        reps_tsv = "../results/clustering/representatives.tsv",
        reps_fasta = "../results/clustering/representatives.fasta"
    params:
        min_length = 500
    conda:
        "../../envs/reps.yaml"
    script: "../../scripts/get_cluster_representatives.py"
