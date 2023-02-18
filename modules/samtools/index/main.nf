process samtools_index {
    tag "Generating FASTA index"
    label "process_low"
    publishDir "$params.outdir"+"/reference", mode: "copy"

    input:
        path reference
    output:
        path("*"), emit: idx
        path("*.{fa,fa.gz}"), emit: reference
        path("*.bed"), emit: bed

    shell:
        """
        if echo ${reference} | grep -q ".gz\$"; then
            reference=Reference.fa.gz
            cp ${reference} Reference.fa.gz
        else 
            reference=Reference.fa
            cp ${reference} Reference.fa
        fi
        
        samtools faidx \${reference}
        awk 'BEGIN {FS="\t"}; {print \$1 FS "0" FS \$2}' \${reference}.fai > Reference.bed
        """
}