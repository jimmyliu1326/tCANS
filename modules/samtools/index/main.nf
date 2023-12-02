process samtools_index {
    tag "Generating FASTA index"
    label "process_low"
    publishDir "$params.out_dir"+"/reference", mode: "copy"

    input:
        path reference
    output:
        path("*"), emit: idx
        path("*.{fa,fa.gz}"), emit: reference
        path("*.bed"), emit: bed
    script:
        def out_file = reference.getExtension() == 'gz' ? "Reference.fa.gz" : "Reference.fa"
        """
        ln -s ${reference} ${out_file}        
        samtools faidx ${reference}
        awk 'BEGIN {FS="\t"}; {print \$1 FS "0" FS \$2}' ${reference}.fai > Reference.bed
        """
}