process blast_formatter {
    tag "Retrieving Blast results by RID"
    label "process_low"
    publishDir "$params.outdir"+"/blast_res/", mode: "copy", pattern: "*.tsv"

    input:
        val(RID)
    output:
        path("*.tsv")
    shell:
        """
        blast_formatter \
            -outfmt 6 \
            -max_target_seqs 50 \
            -out blast_res.tsv \
            -rid ${RID}
            
        """
}