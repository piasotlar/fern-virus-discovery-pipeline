rule make_blast_db:
    input: 
        virus_contigs = "../results/{sample}/{sample}_virus_contigs.fasta",
    output: 
        db = temp(directory("../results/{sample}/{sample}_virus_contigs_blastdb"))
    conda:
        "../../envs/blast_db.yaml"
    log:
        "../logs/clustering/makeblastdb/{sample}.log"
    shell: 
        """
        makeblastdb -dbtype nucl -in {input.virus_contigs} -out {output.db}/blastdb \
        > {log} 2>&1

        """
