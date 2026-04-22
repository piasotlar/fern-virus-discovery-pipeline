rule filter_orfs_fasta:
    input:
        table = "../results/table_orfs.tsv",
        orfs = "../results/{sample}/orfipy/orfs.fa"
    output:
        filtered_orfs = "../results/{sample}/orfipy/orfs_no_hits.fa"
    params:
        min_len = 150
    conda:
        "../envs/table.yaml"
    log:
        "../logs/filter_orfs_fasta/{sample}.log"
    script:
        "../scripts/filter_orfs_fasta.py"