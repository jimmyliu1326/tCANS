process concat_fasta {
    tag "Combining all consensus sequences"
    label "process_low"

    input:
        path(fasta)
    output:
        file("*.fasta")
    shell:
        """
        cat *.fasta > all.fasta
        """
}