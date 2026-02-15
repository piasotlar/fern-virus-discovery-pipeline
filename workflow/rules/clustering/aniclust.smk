rule aniclust:
    input:
        FASTA= "../results/clustering/all_virus_contigs.fasta",
        ANI= "../results/clustering/all_samples_ani.tsv"
    output: "../results/clustering/clusters.tsv"
    params:
        avg_ani = 0.95,
        min_cov = 0.85,
        seed = 1953,
        leiden_resolution="auto",
        min_ani=0.0

    conda: "../../envs/aniclust.yaml" 
    script: "../../scripts/aniclust.py"