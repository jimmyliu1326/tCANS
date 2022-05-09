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
        --host                         Path to host reference genome in FASTA format for dehosting raw reads
        --notrim                       Disable adapter trimming by Porechop
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
         host                : ${params.host}
         
         """
         .stripIndent()

// import modules
include { combine; nanoq; porechop } from './modules/nanopore-base.nf'
include { minimap2; minimap2 as minimap2_dehost } from './modules/nanopore-align.nf'
include { dehost } from './modules/dehost.nf'
include { medaka } from './modules/nanopore-polish.nf'
include { ivar_consensus; ivar_trim; bam2fq; clipbam; ampliconclip } from './modules/ivar.nf'

// define workflow
workflow {
    // read data
    data = channel.fromPath(params.input, checkIfExists: true).splitCsv(header: false)
    reference = file(params.reference, checkIfExists:true)
    primers = file(params.primers, checkIfExists:true)
    // workflow start
    
    // quality filter
    combine(data)
    if( !params.notrim ) { 
        porechop(combine.out)
        nanoq(porechop.out)
    } else {
        nanoq(combine.out)
    }
    
    // dehosting
    if ( !params.host ) {
        minimap2(nanoq.out, reference)
    } else {
        host = file(params.host, checkIfExists:true)
        minimap2_dehost(nanoq.out, host)
        dehost(minimap2_dehost.out)
        minimap2(dehost.out, reference)
    }

    // primer trimming
    ivar_trim(minimap2.out, primers)
    ampliconclip(minimap2.out, primers)
    bam2fq(ampliconclip.out)

    // consensus calling
    ivar_consensus(ivar_trim.out)

    // consensus polishing
    medaka(bam2fq.out, ivar_consensus.out)
}