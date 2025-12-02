rule spades_assembly:
    input:
        r1_paired = "results/{sample}/{sample}_1P.fq.gz",
        r2_paired = "results/{sample}/{sample}_2P.fq.gz" 
    output:
        contigs_dir = temp(directory("results/{sample}/spades")),
        contigs = "results/{sample}/{sample}_spades_contigs.fasta"
    conda:
        "../envs/spades.yaml" 
    log:
        "../logs/spades/{sample}.log" 
    threads: 12

    shell:
        """
        spades.py --rnaviral -1 {input.r1_paired} -2 {input.r2_paired} --threads {threads} -o {output.contigs_dir}  &>> {log} 

        cp {output.contigs_dir}/contigs.fasta {output.contigs}
        """