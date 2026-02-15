rule make_blast_db:
    input: 
        all_virus_contigs = "../results/clustering/all_virus_contigs.fasta"
    output: 
        db = temp(directory("../results/clustering/virus_contigs_blastdb"))
    conda:
        "../../envs/blast_db.yaml"
    log:
        "../logs/clustering/makeblastdb.log"
    shell: 
        """
        makeblastdb -dbtype nucl -in {input.all_virus_contigs} -out {output.db}/blastdb \
        > {log} 2>&1

        """
