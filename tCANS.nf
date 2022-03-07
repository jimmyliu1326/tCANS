#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// define global var
pipeline_name = "tCANS"

// print help message
def helpMessage() {
    log.info """
        Usage: nextflow run jimmyliu1326/tCANS --input samples.csv --outdir /path/to/output
        Required arguments:
         --input                       Path to .csv containing two columns describing Sample ID and path to raw reads directory
         --primers                     Path to .bed encoding the position of each primer
         --reference                   Path to .fasta reference sequence that corresponds to the coordinates in the primers .bed file
         --outdir                      Output directory path
        Optional arguments:
        --help                         Print pipeline usage statement
        """.stripIndent()
}

// check params
if (params.help) {
    helpMessage()
    exit 0
}

if( !params.outdir ) { error pipeline_name+": Missing --outdir parameter" }
if( !params.input ) { error pipeline_name+": Missing --input parameter" }
if( !params.reference ) { error pipeline_name+": Missing --reference parameter" }
if( !params.primers ) { error pipeline_name+": Missing --primers parameter" }

// print log info
log.info """\
         ==================================
             t C A N S   P I P E L I N E    
         ==================================
         input               : ${params.input}
         outdir              : ${params.outdir}
         primers             : ${params.primers}
         reference           : ${params.reference}
         
         """
         .stripIndent()

// import modules
include { combine; nanoq; nanofilt } from './modules/nanopore-base.nf'
include { minimap2 } from './modules/nanopore-align.nf'
include { medaka } from './modules/nanopore-polish.nf'
include { ivar_consensus; ivar_trim; bam2fq; clipbam } from './modules/ivar.nf'

// define workflow
workflow {
    // read data
    data = channel.fromPath(params.input, checkIfExists: true).splitCsv(header: false)
    reference = file(params.reference, checkIfExists:true)
    primers = file(params.primers, checkIfExists:true)
    // workflow start
    combine(data)
    nanoq(combine.out)
    minimap2(nanoq.out, reference)
    ivar_trim(minimap2.out, primers)
    clipbam(ivar_trim.out)
    bam2fq(clipbam.out)
    ivar_consensus(ivar_trim.out)
    medaka(bam2fq.out, ivar_consensus.out)

}