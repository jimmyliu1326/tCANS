process blast_blastn {
    tag "Querying NCBI nt database remotely"
    label "process_low"
    publishDir "$params.out_dir"+"/reports/", mode: "copy", pattern: "*.html"
    errorStrategy 'retry'
    maxRetries 1

    input:
        path(fasta)
    output:
        tuple path("*.out"), stdout, emit: result
        tuple path("*.html"), stdout, emit: report
    shell:
        """
        blastn \
            -db nt \
            -max_target_seqs 50  \
            -evalue ${params.blast_evalue} \
            -query ${fasta} \
            -out blast_res.out \
            -remote
        
        # parse RID from log
        RID=\$(head -n20 blast_res.out | grep RID | cut -f2 -d' ')
        echo \$RID

        # generate html report
        echo -e '<html>\n<head>\n<meta http-equiv="refresh" content="0; url=https://blast.ncbi.nlm.nih.gov/Blast.cgi?RID=JOB_RID&CMD=Get" />\n</head>\n<body>\n</body>\n</html>' > blast_report.html
        sed -i "s/JOB_RID/\$RID/g" blast_report.html

        """
}