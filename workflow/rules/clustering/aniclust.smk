rule aniclust:
    input:
        FASTA= "../results/{sample}/{sample}_virus_contigs.fasta",
        ANI= "../results/{sample}/{sample}_ani.tsv"
    output: "../results/{sample}/{sample}_clusters.tsv"
    params:
        avg_ani = 0.95,
        min_cov = 0.85,
        seed = 1953,
        leiden_resolution="auto",
        min_ani=0.0

    conda: "../../envs/aniclust.yaml" 
    script: "../../scripts/aniclust.py"