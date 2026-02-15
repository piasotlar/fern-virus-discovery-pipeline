rule filter_fasta:
    input:
        tsv_filtered = "../results/{sample}/{sample}_taxonomy_filtered.tsv",
        contigs = "../results/{sample}/{sample}_spades_contigs.fasta"
    output:
        virus_contigs = "../results/{sample}/{sample}_virus_contigs.fasta",
    conda: 
        "../../envs/filter_fasta.yaml"
    log:
        "../logs/clustering/filter/{sample}.log"
    shell:
        """
        python scripts/filter_contigs_fasta.py \
            --tsv {input.tsv_filtered} \
            --fasta {input.contigs} \
            --out-fasta {output.virus_contigs} \
            > {log} 2>&1

        """