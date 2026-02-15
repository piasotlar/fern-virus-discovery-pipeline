rule filter_tsv:
    input:
        tsv = "../results/{sample}/{sample}_taxonomy.tsv"
    output: 
        filtered_tsv = "../results/{sample}/{sample}_taxonomy_filtered.tsv"
    conda:
        "../envs/filter.yaml"
    log:
        "../logs/filter/{sample}.log"
    shell:
        """python scripts/filter.py {input.tsv} {output.filtered_tsv} > {log} 2>&1"""