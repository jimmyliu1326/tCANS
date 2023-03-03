process mafft {
    tag "Building multiple sequence alignment of consensus seqs"
    label "process_medium"
    publishDir "$params.outdir"+"/msa/", mode: "copy", pattern: "*.fa"

    input:
        path(fasta)
    output:
        path("*.fa")
    shell:
        """
        mafft \
            --maxiterate 1000 \
            --adjustdirection \
            --thread ${task.cpus} \
            ${fasta} | sed 's/_R_//g' > consensus.msa.fa
        """
}