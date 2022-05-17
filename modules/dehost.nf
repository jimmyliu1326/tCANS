// dehosting for Nanopore reads
process dehost {
    tag "Dehosting for ${bam.simpleName}"
    label "process_med"
    publishDir "$params.outdir"+"/${bam.simpleName}/dehost", mode: "copy"
    cache false

    input:
        tuple val(sample_id), path(bam)
    output:
        tuple val(sample_id), file("${bam.simpleName}.dehosted.fastq")
    shell:
        """
        samtools view -bS -f4 -@ {task.cpus} ${bam} | samtools fastq -@ {task.cpus} > ${bam.simpleName}.dehosted.fastq
        """
}