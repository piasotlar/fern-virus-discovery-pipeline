rule mmseqs2_proteins:
    input:
        orfs = "../results/{sample}/orfipy/orfs.fa",
        seqTaxDB = "/biodbs/mmseqs2/nr_database/nr.fnaDB" #spremeni bazo
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
        mmseqs convertalis {params.query_db} {input.seqTaxDB} {params.result_db} {output.tsv} --format-output "query,target,theader,evalue,pident,qlen,tlen,alnlen,bits,taxlineage" >> {log} 2>&1
        """

rule mmseqs2_proteins_2:
    input:
        orfs = "../results/{sample}/orfipy/orfs_no_hits.fa",
        seqTaxDB = "/biodbs/mmseqs2/nr_database/nr.fnaDB"
    output:
        tsv = "../results/{sample}/{sample}_mmseqs2_top_hits_2.tsv"
    params:
        query_db = "../results/{sample}/mmseqs2_proteins_2/{sample}_mmseqs2_queryDB",
        result_db = "../results/{sample}/mmseqs2_proteins_2/{sample}_mmseqs2_resultDB",
        tmp_dir = "../results/{sample}/mmseqs2_proteins_2/tmp"
    conda:
        "../envs/mmseqs2_proteins.yaml"
    log:
        "../logs/mmseqs2_2/{sample}.log"
    threads: 32
    shell:
        """
        mkdir -p ../results/{wildcards.sample}/mmseqs2_proteins_2

        mmseqs createdb {input.orfs} {params.query_db} >> {log} 2>&1
        mmseqs search {params.query_db} {input.seqTaxDB} {params.result_db} {params.tmp_dir} --threads {threads} >> {log} 2>&1
        mmseqs convertalis {params.query_db} {input.seqTaxDB} {params.result_db} {output.tsv} --format-output "query,target,theader,evalue,pident,qlen,tlen,alnlen,bits,taxlineage" >> {log} 2>&1
        """