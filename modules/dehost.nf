// dehosting for Nanopore reads
process dehost {
    tag "Dehosting for ${bam.simpleName}"
    label "process_med"
    // publishDir "$params.outdir"+"/${bam.simpleName}/dehost", mode: "copy"

    input:
        tuple val(sample_id), path(bam)
    output:
        tuple val(sample_id), file("${sample_id}.dehosted.bam"), emit: bam
        tuple val(sample_id), file("${sample_id}.dehosted.fastq"), emit: fastq
    shell:
        """
        samtools view -bS -f4 -@ {task.cpus} ${bam} > ${sample_id}.dehosted.bam 
        samtools fastq -@ {task.cpus} ${sample_id}.dehosted.bam > ${sample_id}.dehosted.fastq
        """
}