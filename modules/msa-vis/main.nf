process msa_vis {
    tag "Building MSA report"
    label "process_low"
    publishDir "$params.out_dir"+"/reports/", mode: "copy", pattern: "*.pdf"

    input:
        path(fasta)
    output:
        path("*.pdf")
    shell:
        """
        msa-vis.R \
            --type dna \
            -i ${fasta} \
            -t ${task.cpus}
        """
}