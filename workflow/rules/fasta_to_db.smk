rule mmseqs2_fasta_to_db:
    input:
        contigs = "results/{sample}/spades/contigs.fasta"
    output:  
        db = "results/{sample}/db/{sample}_db"
    conda: 
        "../envs/mmseqs2.yaml"
    log:
        "logs/mmseqs2/fasta_to_db/{sample}.log"
    shell:
        """
        mkdir -p results/{wildcards.sample}/db 
        mmseqs createdb {input.contigs} {output.db} &>> {log}
        """

#createdb za target db
#še tole za target db: mmseqs createindex targetDB tmp
#ali se mapa /db sama ustvari