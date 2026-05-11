rule hmmscan:
    input:
        hmm="../resources/mp_db/MP_profiles.hmm",
        proteins="../results/{sample}/orfipy/proteins_hmmer.fa",
    output:
        txt="../results/{sample}/{sample}_hmmscan.txt",
        tbl="../results/{sample}/{sample}_hmmscan.tblout",
        domtbl="../results/{sample}/{sample}_hmmscan.domtblout"
    conda:
        "../../envs/hmmer.yaml"
    log:
        "../logs/hmmer/hmmscan/{sample}.log"
    threads: 4
    shell:
        """
        hmmscan \
            --cpu {threads} \
            -o {output.txt} \
            --tblout {output.tbl} \
            --domtblout {output.domtbl} \
            {input.hmm} \
            {input.proteins} \
            2> {log}

        """
