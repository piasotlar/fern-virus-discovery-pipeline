rule mmseqs2_taxonomy:
    input:
        query_db = "results/{sample}/db/{sample}_db",
        target_db = "PATH/TO/TARGET_DB"  # še dodamo target db
    output:
        tmp = temp("results/{sample}/{sample}_taxonomy_tmp"),  #tmp za temporary files od searcha (se zbriše potem), mogoče drugače za HPC?
        result = "results/{sample}/{sample}_taxonomy_result"
    conda:
        "envs/mmseqs2.yaml"
    log:
        "logs/mmseqs2/taxonomy/{sample}.log"
    threads: 8
    shell:
        """
        mmseqs search {input.query_db} {input.target_db} {output.result} {output.tmp} --threads {threads} &>> {log}
        """
