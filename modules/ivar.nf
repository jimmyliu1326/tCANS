#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// alignment processes for Nanopore workflows
process ivar_trim {
    tag "Primer trimming on ${bam.simpleName}"
    label "process_medium"

    input:
        path(bam)
        path(bed)
    output:
        file("${bam.simpleName}.trimmed.bam")
    shell:
        """
        ivar trim -b ${bed} -p ${bam.simpleName}.trimmed -i ${bam} -q 0
        """
}

process ivar_consensus {
    tag "Consensus calling on ${bam.simpleName}"
    label "process_medium"

    input:
        path(bam)
    output:
        file("${bam.simpleName}.fa")
    shell:
        """
        samtools sort ${bam} | samtools mpileup -d 1000 -A -Q 0 - | ivar consensus -p ${bam.simpleName} -q 5
        """
}

process bam2fq {
    tag "bam2fq on ${bam.simpleName}"
    label "process_low"

    input:
        path(bam)
    output:
        file("${bam.simpleName}.trimmed.fastq")
    shell:
        """
        samtools fastq -@ ${task.cpus} ${bam} > ${bam.simpleName}.trimmed.fastq
        """
}