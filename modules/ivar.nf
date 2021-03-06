#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// alignment processes for Nanopore workflows
process ivar_trim {
    tag "Primer trimming on ${bam.simpleName}"
    label "process_medium"

    input:
        tuple val(sample_id), path(bam)
        path(bed)
    output:
        tuple val(sample_id), file("${bam.simpleName}.trimmed.bam")
    shell:
        """
        ivar trim -b ${bed} -p ${bam.simpleName}.trimmed -i ${bam} -q 0
        """
}

process ivar_consensus {
    tag "Consensus calling on ${bam.simpleName}"
    label "process_medium"

    input:
        tuple val(sample_id), path(bam)
    output:
        tuple val(sample_id), file("${bam.simpleName}.fa")
    shell:
        """
        samtools sort ${bam} | samtools mpileup -d 1000 -A -Q 0 - | ivar consensus -p ${bam.simpleName} -q 10
        """
}

process bam2fq {
    tag "bam2fq on ${bam.simpleName}"
    label "process_low"

    input:
        tuple val(sample_id), path(bam)
    output:
        tuple val(sample_id), file("${bam.simpleName}.trimmed.fastq")
    shell:
        """
        samtools fastq -@ ${task.cpus} ${bam} > ${bam.simpleName}.trimmed.fastq
        """
}

process clipbam {
    tag "Bam clipping on ${bam.simpleName}"
    label "process_low"

    input:
        tuple val(sample_id), path(bam)
    output:
        tuple val(sample_id), file("${bam.simpleName}.clipped.bam")
    shell:
        """
        bamutils removeclipping ${bam} ${bam.simpleName}.clipped.bam
        """
}

process ampliconclip {
    tag "Primer trimming on ${bam.simpleName}"
    label "process_low"

    input:
        tuple val(sample_id), path(bam)
        path(bed)
    output:
        tuple val(sample_id), file("${bam.simpleName}.trimmed.bam")
    shell:
        """
        samtools ampliconclip --no-excluded -@ ${task.cpus} --hard-clip --both-ends --filter-len 0 -b ${bed} ${bam} > ${bam.simpleName}.trimmed.bam
        """
}