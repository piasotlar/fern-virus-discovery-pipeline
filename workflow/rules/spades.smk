rule spades_assembly:
    input:
        r1_paired = "results/{sample}/{sample}_1P.fq.gz",
        r2_paired = "results/{sample}/{sample}_2P.fq.gz" #je tukaj prav da so samo paired?
    output:
        contigs_dir = directory("results/{sample}/spades"),
        contigs = "results/{sample}/spades/contigs.fasta"
    conda:
        "envs/spades.yaml" #env za spades
    log:
        "logs/spades/{sample}.log" #logi od spades, vsak vzorec svoj log
    threads: 12

    shell:
        """
        spades.py --rnaviral --pe1-1 {input.r1_paired} --pe1-2 {input.r2_paired} --threads {threads} -o {output.contigs_dir}  &>> {log} 
        """