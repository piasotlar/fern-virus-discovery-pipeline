rule ensure_optional_files:

    output:
        orfs="../results/{sample}/orfipy/orfs_for_translate.fa",
        coverm="../results/{sample}/{sample}_coverm_safe.tsv",
        longest_orfs="../results/{sample}/{sample}_longest_orfs_len_safe.txt"

    params:
        orfs="../results/{sample}/orfipy/orfs.fa",
        coverm="../results/{sample}/{sample}_coverm.tsv",
        longest_orfs="../results/{sample}/{sample}_longest_orfs_len.txt"

    shell:
        """
        # ORFs
        if [ -s {params.orfs} ]; then
            cp {params.orfs} {output.orfs}
        else
            touch {output.orfs}
        fi

        # COVERM
        if [ -s {params.coverm} ]; then
            cp {params.coverm} {output.coverm}
        else
            echo -e "Contig\t{wildcards.sample}_aln_sorted RPKM\t{wildcards.sample}_aln_sorted Read Count" > {output.coverm}
        fi

        # LONGEST ORFS
        if [ -s {params.longest_orfs} ]; then
            cp {params.longest_orfs} {output.longest_orfs}
        else
            echo -e "ORF_ID\torf_len\torf_perc" > {output.longest_orfs}
        fi
        """