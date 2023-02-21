process seqkit_fx2tab {
    tag "Calculating N content for ${sample_id}"
    label "process_low"

    input:
        tuple val(sample_id), path(consensus)
    output:
        tuple val(sample_id), stdout

    shell:
        """
        seqkit fx2tab -ni -B N ${consensus} | cut -f2
        """
}