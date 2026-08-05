rule gzip_fastq:
    input:
        r1 = "../resources/fastq/{sample}_1.fastq",
        r2 = "../resources/fastq/{sample}_2.fastq"

    output:
        r1_gz = "../resources/fastq/{sample}_1.fastq.gz",
        r2_gz = "../resources/fastq/{sample}_2.fastq.gz"

    log: 
        "../logs/gzip/{sample}.log"

    conda:
        "../envs/gzip.yaml"
    
    threads: 2
    shell: 
        """
        gzip -c {input.r1} > {output.r1_gz} 2>> {log}
        gzip -c {input.r2} > {output.r2_gz} 2>> {log}
        rm {input.r1} {input.r2}
        """