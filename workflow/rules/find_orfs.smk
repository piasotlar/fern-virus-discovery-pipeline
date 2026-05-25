rule find_orfs:
    input:
        reps = "../results/{sample}/{sample}_representatives.fasta"
    output:
        orfs = "../results/{sample}/orfipy/orfs.fa",
        bed = "../results/{sample}/orfipy/bed_file_longest"
    params:
        outdir = "../results/{sample}/orfipy",
        bed_prefix = "bed_file",
        dna_prefix = "orfs.fa"
    log:
        "../logs/orfs_orfipy/{sample}.log"
    conda: 
        "../envs/find_orfs.yaml"
    shell:
        """
        if grep -q "^>" {input.reps}; then
            orfipy {input.reps} \
                --single-mode \
                --outdir {params.outdir} \
                --bed {params.bed_prefix} \
                --min 50 \
                --partial-3 \
                --partial-5 \
                --longest \
                --dna {params.dna_prefix}
        else
            touch {output.orfs}
            touch {output.bed}
            echo "No representatives; skipping orfipy"
        fi > {log} 2>&1
        """
            