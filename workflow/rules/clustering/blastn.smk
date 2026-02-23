rule blastn:
    input:
        virus_contigs = "../results/{sample}/{sample}_virus_contigs.fasta",
        blast_db = "../results/{sample}/{sample}_virus_contigs_blastdb"
    output: 
        blast_tsv = "../results/{sample}/{sample}_blast.tsv"
    params:
        min_blast_ident = 0 
    threads: 4
    conda:
        "../../envs/blastn.yaml" 
    log: 
        "../logs/clustering/blastn/{sample}.log"
    shell:
        """
        blastn -task megablast -max_target_seqs 25000 -perc_identity {params.min_blast_ident} \
        -outfmt "6 qseqid sseqid pident length qstart qend sstart send evalue qlen slen" \
        -num_threads {threads} -query {input.virus_contigs} -db {input.blast_db}/blastdb -out {output.blast_tsv} \
        > {log} 2>&1
        """