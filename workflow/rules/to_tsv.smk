rule to_tsv:
    input:
        resultDB = "results/{sample}/{sample}_resultDB.index"
        queryDB = "results/{sample}/{sample}_queryDB.index"

    params:
        result = "results/{sample}/{sample}_resultDB",
        query = "results/{sample}/{sample}_queryDB",
    output:
        tsv_result = "results/{sample}/{sample}_taxonomy.tsv"
    conda:
        "../envs/mmseqs2.yaml"
    log:
        "logs/mmseqs2/to_tsv/{sample}.log"
    shell:
        """
        mmseqs createtsv {params.query} {params.result} {output.tsv_result} &>> {log}
        
        """