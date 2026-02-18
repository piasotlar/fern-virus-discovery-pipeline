rule coverm:
    input: 
        bam_file = "../results/{sample}/{sample}_aln_sorted.bam"
    output:
        tsv_file = "../results/{sample}/{sample}_coverm.tsv"

    conda: "../../envs/coverm.yaml"

    log: "../logs/mapping/coverm/{sample}.log"

    params:
        min_identity = 95,
        min_aln = 95
        methods="mean covered_fraction count"

    threads: 8

    shell:
        """
        coverm contig \
          --threads {threads} \
          --bam-files {input.bam_file} \
          --methods {params.methods} \
          --min-read-percent-identity {params.min_identity} \
          --min-read-aligned-percent {params.min_aln} \
          --exclude-supplementary \
          --output-file {output.tsv_file} >> {log} 2>&1
        """

"""
-exclude-supplementary
Exclude supplementary alignments. [default: not set]

--include-secondary
Include secondary alignments. [default: not set]


coverm filter mogoče ttreba posebaj??
"""
