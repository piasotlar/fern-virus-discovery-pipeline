rule filter_orfs_hmmer:
    input:
        table = "../results/table_orfs_2.tsv",
        orfs = "../results/{sample}/orfipy/orfs.fa"
    output:
        filtered_orfs = "../results/{sample}/orfipy/orfs_hmmer.fa"
    params:
        min_len = 150
    conda:
        "../envs/table.yaml"
    log:
        "../logs/filter_orfs_hmmer/{sample}.log"
    script:
        "../scripts/filter_orfs_hmmer.py"