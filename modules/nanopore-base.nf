// basic processes for Nanopore workflows
process combine {
    tag "Combining Fastq files for ${sample_id}"
    label "process_low"

    input:
        tuple val(sample_id), path(dir)
    output:
        tuple val(sample_id), path("*.{fastq,fastq.gz}")
    script:
        // def ext = reads[0].getExtension() == 'gz' ? "fastq.gz" : "fastq"
        """
        sample=\$(find ${dir}/ -type f -name '*.fastq*' -printf '%f\\n' | head -n1)
        if [[ \${sample##*.} == "gz" ]]; then ext="fastq.gz"; else ext="fastq"; fi
        cat ${dir}/*.\${ext} > ${sample_id}.\${ext}
        """
}

process porechop {
    tag "Adapter trimming on ${reads.simpleName}"
    label "process_med"

    input:
        tuple val(sample_id), path(reads)
    output:
        tuple val(sample_id), file("${sample_id}.trimmed.fastq")
    shell:
        """
        porechop -t ${task.cpus} -i ${reads} -o ${sample_id}.trimmed.fastq
        """
}

process porechop_abi {
    tag "Adapter trimming on ${sample_id}"
    label "process_med"

    input:
        tuple val(sample_id), path(reads)
    output:
        tuple val(sample_id), file("${sample_id}.trimmed.fastq.gz")
    shell:
        """
        porechop_abi -t ${task.cpus} -abi -i ${reads} -o ${sample_id}.trimmed.fastq.gz
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
        tuple val(sample_id), file("${sample_id}.filt.fastq.gz")
    shell:
        """
        nanoq -i ${reads} -l ${min_rl} -q ${min_rq} -m ${max_rl} -O g > ${sample_id}.filt.fastq.gz
        """
}