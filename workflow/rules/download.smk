rule download_fastq:
    output:
        r1="resources/fastq/{sample}_R1.fastq.gz",
        r2="resources/fastq/{sample}_R2.fastq.gz"
    params:
        url_r1 = lambda w: r1_urls[w.sample],
        url_r2 = lambda w: r2_urls[w.sample]
    log:
        "logs/download/{sample}.log"
    shell:
        """
        
        wget -nc ftp://{params.url_r1} -O {output.r1} $>> {log}

        wget -nc ftp://{params.url_r2} -O {output.r2} $>> {log}
        """

        # &>>{log} :  out in err v isti log zapiše