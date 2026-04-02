rule mmseqs2_proteins:
    input:
        orfs = "../results/{sample}/orfipy/orfs.fa",
        seqTaxDB = "/biodbs/mmseqs2/nr_database/nr.fnaDB"
    output:
        tsv = "../results/{sample}/{sample}_mmseqs2_top_hits.tsv"
    params:
        query_db = "../results/{sample}/mmseqs2_proteins/{sample}_mmseqs2_queryDB",
        result_db = "../results/{sample}/mmseqs2_proteins/{sample}_mmseqs2_resultDB",
        tmp_dir = "../results/{sample}/mmseqs2_proteins/tmp"
    conda:
        "../envs/mmseqs2_proteins.yaml"
    log:
        "../logs/mmseqs2/{sample}.log"
    threads: 32
    shell:
        """
        mkdir -p ../results/{wildcards.sample}/mmseqs2_proteins

        mmseqs createdb {input.orfs} {params.query_db} >> {log} 2>&1
        mmseqs search {params.query_db} {input.seqTaxDB} {params.result_db} {params.tmp_dir} --threads {threads} >> {log} 2>&1
        mmseqs convertalis {params.query_db} {input.seqTaxDB} {params.result_db} {output.tsv} --format-output "query,target,evalue,pident,qlen,tlen,alnlen,bits,taxlineage" >> {log} 2>&1
        """