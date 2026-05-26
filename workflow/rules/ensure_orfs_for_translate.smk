rule ensure_orfs_for_translate:
    output:
        orfs="../results/{sample}/orfipy/orfs_for_translate.fa"
    params:
        original="../results/{sample}/orfipy/orfs.fa"
    shell:
        """
        if [ -s {params.original} ]; then
            cp {params.original} {output.orfs}
        else
            touch {output.orfs}
        fi
        """