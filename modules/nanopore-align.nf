#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// alignment processes for Nanopore workflows
process minimap2 {
    tag "Minimap2 alignment on ${reads.simpleName}"
    label "process_medium"

    input:
        path(reads)
        path(reference)
    output:
        file("${reads.simpleName}.bam")
    shell:
        """
        minimap2 -ax map-ont -t ${task.cpus} ${reference} ${reads} | samtools view -bS -@ ${task.cpus} - | samtools sort - > ${reads.simpleName}.bam
        """
}