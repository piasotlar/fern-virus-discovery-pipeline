rule concatenate_tsv:
    input:
        expand("../results/test_results/{sample}_taxonomy_filtered.tsv", sample=sample_names)
    output:
        "../results/clustering/all_viruses.tsv"
    conda:
        "../../envs/concatenate.yaml"
    log:
        "../logs/clustering/concatenate_tsv.log"
    script:
        "../../scripts/concatenate_tsv.py"
