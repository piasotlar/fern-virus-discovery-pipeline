rule mmseqs2_taxonomy:
    input:
        seqTaxDB = "../resources/", # še dodamo target db
        queryDB_index = "../results/{sample}/{sample}_db/{sample}_queryDB.index"
        #seqTaxDB = "/biodbs/mmseqs2/nr_database/nr.fnaDB" #TARGET DB na NIB serverjih
    output:
        tmp = temp(directory("tmp/{sample}_taxonomy_tmp")), 
        resultsDB = "../results/{sample}/{sample}_resultDB.index"
    params:
        query_db = "../results/{sample}/{sample}_db/{sample}_queryDB",
        result = "../results/{sample}/{sample}_resultDB"
    conda:
        "../envs/mmseqs2.yaml"
    log:
        "../logs/mmseqs2/taxonomy/{sample}.log"

    threads: 16
    shell:
        """
        mmseqs taxonomy {params.query_db} {input.seqTaxDB} {params.result} {output.tmp} --threads {threads} --tax-lineage 1 > {log} 2>&1
        """
