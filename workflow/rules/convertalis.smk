rule mmseqs2_convertalis_with_header:
    input:
        query_db = "../results/{sample}/mmseqs2_proteins/{sample}_mmseqs2_queryDB",
        seqTaxDB = "/biodbs/mmseqs2/nr_database/nr.fnaDB", #za spremenit
        result_db = "../results/{sample}/mmseqs2_proteins/{sample}_mmseqs2_resultDB"
    output:
        tsv = "../results/{sample}/{sample}_mmseqs2_top_hits.tsv"
    log:
        "../logs/mmseqs2/{sample}_convertalis.log"
    conda:
        "../envs/mmseqs2_proteins.yaml"
    threads: 4
    shell:
        """
        mmseqs convertalis {input.query_db} {input.seqTaxDB} {input.result_db} {output.tsv} \
        --format-output "query,target,theader,evalue,pident,qlen,tlen,alnlen,bits,taxlineage" \
        >> {log} 2>&1
        """