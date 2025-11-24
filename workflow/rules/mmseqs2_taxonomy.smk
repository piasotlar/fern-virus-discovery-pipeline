rule mmseqs2_taxonomy:
    input:
        query_db = "results/{sample}/db/{sample}_db",
        seqTaxDB = "PATH/TO/TARGET_DB"  # še dodamo target db
    output:
        tmp = temp("tmp/{sample}_taxonomy_tmp"),  #tmp za temporary files od taxonomy (se zbriše potem), mogoče drugače za HPC?
        taxonomy_result = "results/{sample}/taxonomy/{sample}_taxonomy" #ali se mapa taxonomy sama ustvari ob pravilu mmseq
    conda:
        "../envs/mmseqs2.yaml"
    log:
        "logs/mmseqs2/taxonomy/{sample}.log"
    threads: 16
    shell:
        """
        mkdir -p results/{wildcards.sample}/taxonomy
        mmseqs taxonomy {input.query_db} {input.seqTaxDB} {output.taxonomy_result} {output.tmp} &>> {log}
        """
