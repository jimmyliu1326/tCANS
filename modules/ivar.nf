process ivar_trim {
    tag "Primer trimming on ${sample_id}"
    label "process_medium"

    input:
        tuple val(sample_id), path(bam)
        path(bed)
    output:
        tuple val(sample_id), file("${sample_id}.trimmed.bam")
    shell:
        """
        ivar trim -b ${bed} -p ${sample_id}.trimmed -i ${bam} -q 0
        """
}

process ivar_consensus {
    tag "Consensus calling on ${sample_id}"
    label "process_medium"

    input:
        tuple val(sample_id), path(bam)
    output:
        tuple val(sample_id), file("*.unpolish.fa")
    shell:
        """
        samtools mpileup -d ${params.max_depth} -A -Q ${params.min_rq} ${bam} | ivar consensus -p ${sample_id}.unpolish -q ${params.min_rq} -m ${params.min_depth}
        """
}

process bam2fq {
    tag "bam2fq on ${sample_id}"
    label "process_low"

    input:
        tuple val(sample_id), path(bam)
    output:
        tuple val(sample_id), file("*.fastq")
    shell:
        """
        samtools fastq -@ ${task.cpus} ${bam} > ${sample_id}.trimmed.fastq
        """
}

process ampliconclip {
    tag "Primer trimming on ${sample_id}"
    label "process_low"
    // publishDir "$params.outdir"+"/amplicon_clip_aln/", mode: "copy"

    input:
        tuple val(sample_id), path(bam)
        path(bed)
    output:
        tuple val(sample_id), file("${sample_id}.trimmed.bam")
    shell:
        """
        samtools ampliconclip --no-excluded -@ ${task.cpus} --hard-clip --both-ends --filter-len 0 -b ${bed} ${bam} > ${sample_id}.trimmed.bam
        """
}