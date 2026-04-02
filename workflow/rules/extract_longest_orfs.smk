rule extract_longest_orfs:
    input:
        bed = "../results/{sample}/orfipy/bed_file_longest.bed",
        dna = "../results/{sample}/orfipy/orfs.fa"
    output:
        fa = "../results/{sample}/{sample}_longest_orfs.fa",
        txt = "../results/{sample}/{sample}_longest_orfs_len.txt"
    conda:
        "../envs/longest_orfs.yaml"
    log:
        "../logs/extract_longest_orfs/{sample}.log"
    script:
        "../scripts/extract_longest_orfs.py"