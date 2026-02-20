rule bwa:
    input:
        reps = "../results/{sample}/{sample}_representatives.fasta", 
        r1 = "../results/{sample}/{sample}_1P.fq.gz",
        r2 = "../results/{sample}/{sample}_2P.fq.gz" 
    output:
        bam_sorted = "../results/{sample}/{sample}_aln_sorted.bam",
        idx_marker="../results/{sample}/{sample}_representatives.fasta.pac"
    conda: "../../envs/bwa.yaml"
    
    log: "../logs/mapping/bwa/{sample}.log"

    threads: 8

    shell:
        """
        bwa-mem2 index {input.reps} >> {log} 2>&1
        bwa-mem2 mem -t {threads} {input.reps} {input.r1} {input.r2} 2>> {log} \
          | samtools view -b -F 2304 2>> {log} \
          | samtools sort -@ 2 -o {output.bam_sorted} 2>> {log}
        """


#bwa nastavitve:

#./bwa-mem2 mem -t <num_threads> <prefix> <reads.fq/fa> > out.sam
#./bwa mem ref.fa read1.fq read2.fq | gzip -3 > aln-pe.sam.gz

#	bwa mem [-aCHMpP] [-t nThreads] [-k minSeedLen] [-w bandWidth] 
#[-d zDropoff] [-r seedSplitRatio] [-c maxOcc] [-A matchScore] 
#[-B mmPenalty] [-O gapOpenPen] [-E gapExtPen] [-L clipPen] [-U unpairPen] 
#[-R RGline] [-v verboseLevel] db.prefix reads.fq [mates.fq]

#samtools
# sec in sup odstranimo z coverm ali z samtools --> | samtools view -b -F 2304 2>> {log}  -- to še popravit\ (oboje)
