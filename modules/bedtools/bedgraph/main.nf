process bedgraph {
    tag "Generating bedgraph for ${sample_id}"
    label "process_low"
    publishDir "$params.outdir"+"/coverage/${bed_outdir}", mode: "copy"

    input:
        tuple val(sample_id), path(bam)
        path reference
        val bed_outdir
    output:
        tuple val(sample_id), file("*.bedgraph")
    shell:
        """
        bedtools genomecov -bg -g ${reference} -ibam ${bam} > ${sample_id}.bedgraph
        """
}