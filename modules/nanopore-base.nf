// basic processes for Nanopore workflows
process combine {
    tag "Combining Fastq files for ${sample_id}"
    label "process_low"

    input:
        tuple val(sample_id), path(reads)
    output:
        tuple val(sample_id), path("${sample_id}.{fastq,fastq.gz}")
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
    tag "Adapter trimming on ${reads.simpleName}"
    label "process_high"

    input:
        tuple val(sample_id), path(reads)
    output:
        tuple val(sample_id), file("${reads.simpleName}.trimmed.fastq")
    shell:
        """
        porechop -t ${task.cpus} -i ${reads} -o ${reads.simpleName}.trimmed.fastq
        """
}

process nanoq {
    tag "Read filtering on ${reads.simpleName}"
    label "process_low"

    input:
        tuple val(sample_id), path(reads)
        val min_rl
        val min_rq
        val max_rl
    output:
        tuple val(sample_id), file("${reads.simpleName}.filt.fastq.gz")
    shell:
        """
        nanoq -i ${reads} -l ${min_rl} -q ${min_rq} -m ${max_rl} -O g > ${reads.simpleName}.filt.fastq.gz
        """
}