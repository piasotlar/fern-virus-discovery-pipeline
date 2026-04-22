rule table:
    input:
        reps = expand("../results/{sample}/{sample}_representatives.tsv", sample=sample_names),                                                                                                       
        coverm = expand("../results/{sample}/{sample}_coverm.tsv", sample=sample_names),
        longest_orfs = expand("../results/{sample}/{sample}_longest_orfs_len.txt", sample=sample_names),
        table_orfs= "../results/table_orfs_2.tsv"
    output:
        table = "../results/table.tsv"
    conda:
        "../envs/table.yaml"
    log:
        "../logs/table.log"
    script:
        "../scripts/table.py"

