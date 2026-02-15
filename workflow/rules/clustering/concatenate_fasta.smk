rule concatenate_fasta:
    input:
        expand("../results/{sample}/{sample}_virus_contigs.fasta", sample=sample_names)
    output:
        "../results/clustering/all_virus_contigs.fasta"
    conda:
        "../../envs/concatenate.yaml"
    log:
        "../logs/clustering/concatenate_fasta.log"
    script:
        "../../scripts/concatenate_fasta.py"
