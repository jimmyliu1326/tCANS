process webblast_blastn {
    tag "Querying NCBI nt database using Web BLAST"
    label "process_low"
    publishDir "$params.outdir"+"/blast_res/", mode: "copy", pattern: "*.{tsv,html,log}"
    errorStrategy 'retry'
    maxRetries 5

    input:
        path(fasta)
    output:
        path("*.tsv"), emit: blast_tsv
        path("*.html"), emit: blast_html
        path("*.log"), emit: blast_log
    shell:
        """
        web_blast.py blastn \
            -db ${params.blast_db} \
            -n 50  \
            -evalue ${params.blast_evalue} \
            --no-cache \
            ${fasta} |& tee webblast.log 
        # echo ZSFS7X3Y01N > webblast.log 
        
        # parse RID from log
        RID=\$(head -n1 webblast.log)

        # retrieve results
        web_blast.py get -outfmt 6 -out blast_res.tsv \$RID

        # generate html report
        echo -e '<html>\n<head>\n<meta http-equiv="refresh" content="0; url=https://blast.ncbi.nlm.nih.gov/Blast.cgi?RID=JOB_RID&CMD=Get" />\n</head>\n<body>\n</body>\n</html>' > blast_res.html
        sed -i "s/JOB_RID/\$RID/g" blast_res.html

        """
}