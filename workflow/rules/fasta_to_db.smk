rule mmseqs2_fasta_to_db:
    input:
        contigs = "../results/{sample}/{sample}_spades_contigs.fasta"
    output: 
        queryDB = "../results/{sample}/{sample}_db/{sample}_queryDB.index"

    params:
        query = "../results/{sample}/{sample}_db/{sample}_queryDB"

    conda: 
        "../envs/mmseqs2.yaml"
    log:
        "../logs/mmseqs2/fasta_to_db/{sample}.log"
    shell:
        """
        mmseqs createdb {input.contigs} {params.query} &>> {log}
        """
