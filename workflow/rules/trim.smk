rule trimming:
    input:
        r1 = "resources/fastq/{sample}_R1.fastq.gz",
        r2 = "resources/fastq/{sample}_R2.fastq.gz",
        adapters = "resources/adapters/truseq_UDI.fa" #ali so okej adapterji - v trimmomatic data je na vsakem še en dodatn nt? + ali je potrebno dat v imena adapterjev /1 in /2?

    output:
        r1_paired = "results/{sample}/{sample}_1P.fq.gz",
        r2_paired = "results/{sample}/{sample}_2P.fq.gz",
        r1_unpaired = "results/{sample}/{sample}_1U.fq.gz",
        r2_unpaired = "results/{sample}/{sample}_2U.fq.gz"
    conda:
        "../envs/trimmomatic.yaml"
    log:
        "logs/trimming/{sample}.log"
    threads: 10
    shell:
        """
        mkdir -p results/{wildcards.sample}

        trimmomatic PE -threads {threads} {input.r1} {input.r2} {output.r1_paired} {output.r1_unpaired} {output.r2_paired} {output.r2_unpaired} ILLUMINACLIP:{input.adapters}:2:30:10 SLIDINGWINDOW:4:15 LEADING:3 TRAILING:3 MINLEN:36 &>> {log}
        """
        #parametri so default iz githuba