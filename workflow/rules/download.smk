rule download_fastq:
    output:
        r1="../resources/fastq/{sample}_1.fastq",
        r2="../resources/fastq/{sample}_2.fastq"
    log:
        "../logs/download/{sample}.log"

    conda:
        "../envs/download.yaml"

    threads: 4
    shell:
        """
        prefetch {wildcards.sample} >> {log}

        fasterq-dump {wildcards.sample} --split-files --outdir ../resources/fastq >> {log}
        """

