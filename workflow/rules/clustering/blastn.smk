rule blastn:
    input:
        all_virus_contigs = "../results/clustering/all_virus_contigs.fasta",
        blast_db = "../results/clustering/virus_contigs_blastdb"
    output: 
        blast_tsv = "../results/clustering/all_samples_blast.tsv"
    params:
        min_blast_ident = 0 # koliko min identity
    threads: 8
    conda:
        "../../envs/blastn.yaml" 
    log: 
        "../logs/clustering/all_samples_blastn.log"
    shell:
        """
        blastn -task megablast -max_target_seqs 25000 -perc_identity {params.min_blast_ident} \
        -outfmt "6 qseqid sseqid pident length qstart qend sstart send evalue qlen slen" \
        -num_threads {threads} -query {input.all_virus_contigs} -db {input.blast_db}/blastdb -out {output.blast_tsv} \
        > {log} 2>&1
        """