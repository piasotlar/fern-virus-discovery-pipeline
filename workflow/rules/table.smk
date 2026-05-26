rule table:
    input:
        reps = expand("../results/{sample}/{sample}_representatives.tsv", sample=sample_names),                                                                                                       
        coverm = expand("../results/{sample}/{sample}_coverm_safe.tsv", sample=sample_names),
        longest_orfs = expand("../results/{sample}/{sample}_longest_orfs_len_safe.txt", sample=sample_names),
        table_orfs= "../results/table_orfs_2.tsv",
        hmmer = expand("../results/{sample}/{sample}_hmmscan.tblout", sample=sample_names)
    output:
        table = "../results/table.tsv"
    conda:
        "../envs/table.yaml"
    log:
        "../logs/table.log"
    script:
        "../scripts/table.py"

