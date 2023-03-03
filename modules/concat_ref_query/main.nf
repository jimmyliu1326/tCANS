process concat_ref_query_fasta {
    tag "Combining consensus sequences with reference"
    label "process_low"

    input:
        path(query)
        path(reference)
    output:
        file("*.fasta")
    shell:
        """
        cat <(cat ${reference} | sed 's/>.*/>Reference/g') \$(ls | grep -v ${reference}) > all.fasta
        """
}