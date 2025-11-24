rule to_tsv:
    input:
        taxonomy_result = "results/{sample}/taxonomy/{sample}_taxonomy",
        query_db = "results/{sample}/db/{sample}_db"
    output:
        tmp = temp("tmp/{sample}_to_tsv_tmp"),
        tsv_result = "results/{sample}/{sample}_taxonomy.tsv"
    conda:
        "../envs/mmseqs2.yaml"
    log:
        "logs/mmseqs2/to_tsv/{sample}.log"
    shell:
        """
        mmseqs createtsv {input.query_db} {input.taxonomy_result} {output.tsv_result} {output.tmp} --tax-lineage 1 &>> {log}
        
        """