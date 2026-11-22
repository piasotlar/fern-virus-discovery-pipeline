rule table_orfs_2:
    input:
        table_orfs = "../results/table_orfs.tsv",
        mmseqs2_proteins_2 = expand("../results/{sample}/{sample}_mmseqs2_top_hits_2.tsv", sample=sample_names)
    output:
        table_orfs_2 = "../results/table_orfs_2.tsv"
    log:
        "../logs/table_orfs_2.log"
    conda:
        "../envs/table.yaml"
    script:
        "../scripts/table_orfs_2.py"