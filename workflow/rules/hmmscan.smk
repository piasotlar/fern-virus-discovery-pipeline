rule hmmscan:
    input:
        hmm="../resources/mp_db/MP_profiles.hmm",
        proteins="../results/{sample}/orfipy/proteins_hmmer.fa",
    output:
        txt="../results/{sample}/{sample}_hmmscan.txt",
        tbl="../results/{sample}/{sample}_hmmscan.tblout",
        domtbl="../results/{sample}/{sample}_hmmscan.domtblout"
    conda:
        "../envs/hmmer.yaml"
    log:
        "../logs/hmmer/hmmscan/{sample}.log"
    threads: 4
    shell:
        """
        if grep -q "^>" {input.proteins}; then
            hmmscan \
                -o {output.txt} \
                --tblout {output.tbl} \
                --domtblout {output.domtbl} \
                --cpu {threads} \
                {input.hmm} \
                {input.proteins} \
                > {log} 2>&1
        else
            touch {output.txt}
            touch {output.tbl}
            touch {output.domtbl}
            echo "No proteins for hmmscan" > {log}
        fi
        """