rule anicalc:
    input:
        virus_contigs="../results/clustering/all_virus_contigs.fasta",
        sorted_blast="../results/clustering/all_samples_blast_sorted.tsv"
    output: "../results/clustering/all_samples_ani.tsv"
    params:
        blast_max_evalue = 1e-3
    conda: "../../envs/anicalc.yaml"
    script: "../../scripts/anicalc.py"