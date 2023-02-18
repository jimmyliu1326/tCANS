process igv_report {
    tag "Creating IGV Report for ${outdir} reads"
    label "process_low"
    publishDir "$params.outdir"+"/coverage/${outdir}", mode: "copy"

    input:
        path(bam)
        path(reference)
        path(bed)
        val(outdir)
    output:
        path("*.html"), emit: report
    shell:
        """
        create_report ${bed} ${reference} \
            --tracks *.bedgraph \
            --output coverage_report.html
        """
}