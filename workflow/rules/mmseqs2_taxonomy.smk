rule mmseqs2_taxonomy:
    input:
        seqTaxDB = "../resources/db" # še dodamo target db
    output:
        tmp = temp(directory("tmp/{sample}_taxonomy_tmp")),  #tmp za temporary files od taxonomy (se zbriše potem)
        resultsDB = "results/{sample}/{sample}_resultDB.index"
    params:
        query_db = "results/{sample}/{sample}_queryDB",
        result = "results/{sample}/{sample}_resultDB"
    conda:
        "../envs/mmseqs2.yaml"
    log:
        "../logs/mmseqs2/taxonomy/{sample}.log"

    threads: 16
    shell:
        """
        mmseqs taxonomy {params.query_db} {input.seqTaxDB} {params.result} {output.tmp} --threads {threads} --tax-lineage 1 &>> {log}
        """
