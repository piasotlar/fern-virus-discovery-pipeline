rule table:
    input:
        orfs = expand("../results/{sample}/orfipy/orfs.fa", sample=sample_names),
        mmseqs2_proteins = expand("../results/{sample}/{sample}_mmseqs2_top_hits.tsv", sample=sample_names)
    output:
        table = "../results/table_orfs.tsv"
    conda:
        "../envs/table.yaml"
    log:
        "../logs/table_orfs.log"
    script:
        "../scripts/table_orfs.py"

