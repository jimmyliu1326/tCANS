#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// basic processes for Nanopore workflows
process combine {
    tag "Combining Fastq files for ${sample_id}"
    label "process_low"
    cache false

    input:
        tuple val(sample_id), path(reads)
    output:
        file("${sample_id}.{fastq,fastq.gz}")
    shell:
        """
        sample=\$(ls ${reads} | head -n 1)
        if [[ \${sample##*.} == "gz" ]]; then
            cat ${reads}/*.fastq.gz > ${sample_id}.fastq.gz
        else
            cat ${reads}/*.fastq > ${sample_id}.fastq
        fi
        """
}

process porechop {
    tag "Adaptor trimming on ${reads.simpleName}"
    label "process_high"
    cache false

    input:
        path(reads)
    output:
        file("${reads.simpleName}.trimmed.fastq")
    shell:
        """
        porechop -t ${task.cpus} -i ${reads} -o ${reads.simpleName}.trimmed.fastq
        """
}

process nanoq {
    tag "Read filtering on ${reads.simpleName}"
    label "process_low"
    cache false

    input:
        path(reads)
    output:
        file("${reads.simpleName}.filt.fastq.gz")
    shell:
        """
        nanoq -i ${reads} -l 200 -q 5 -O g > ${reads.simpleName}.filt.fastq.gz
        """
}

process nanofilt {
    tag "Read filtering on ${reads.simpleName}"
    label "process_low"
    cache false

    input:
        path(reads)
    output:
        file("${reads.simpleName}.filt.fastq.gz")
    shell:
        """
        sample=\$(ls ${reads} | head -n 1)
        if [[ \${sample##*.} == "gz" ]]; then
            zcat ${reads} | NanoFilt -q 10 | gzip > ${reads.simpleName}.filt.fastq.gz
        else
            cat ${reads} | NanoFilt -q 10 | gzip > ${reads.simpleName}.filt.fastq.gz
        fi
        """
}