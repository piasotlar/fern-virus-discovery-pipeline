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
	mkdir -p ../resources/fastq

        prefetch --output-directory ../resources/fastq {wildcards.sample} >> {log}

        fasterq-dump ../resources/fastq/{wildcards.sample}/{wildcards.sample}.sra --outdir ../resources/fastq >> {log}

	rm -rf ../resources/fastq/{wildcards.sample}
        """