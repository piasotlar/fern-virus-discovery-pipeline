rule translate_orfs:
    input:
        orfs="../results/{sample}/orfipy/orfs_hmmer.fa"
    output:
        proteins="../results/{sample}/orfipy/proteins_hmmer.fa"
    conda:
        "../../envs/orfs_translate.yaml"
    log:
        "../logs/translate/{sample}.log"
    shell:
        """
        transeq \
            -sequence {input.orfs} \
            -outseq {output.proteins} \
            > {log} 2>&1
        """