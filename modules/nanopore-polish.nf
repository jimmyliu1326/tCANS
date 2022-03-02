#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// post-assembly polishing for Nanopore workflows
process medaka {
    tag "Assembly polishing for ${reads.simpleName}"
    label "process_medium"
    publishDir "$params.outdir"+"/${reads.simpleName}/consensus", mode: "copy"

    input:
        path(reads)
        path(assembly)
    output:
        file("${reads.simpleName}.fasta")
    shell:
        """
        medaka_consensus -i ${reads} -d ${assembly} -o . -t ${task.cpus} -f
        mv consensus.fasta ${reads.simpleName}.fasta
        """
}