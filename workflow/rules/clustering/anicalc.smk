rule anicalc:
    input:
        virus_contigs = "../results/{sample}/{sample}_virus_contigs.fasta",
        sorted_blast="../results/{sample}/{sample}_blast_sorted.tsv"
    output: "../results/{sample}/{sample}_ani.tsv"
    params:
        blast_max_evalue = 1e-3
    conda: "../../envs/anicalc.yaml"
    log: "../logs/clustering/anicalc/{sample}.log"
    script: "../../scripts/anicalc.py"