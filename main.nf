#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// check parameters
WorkflowMain.initialise(workflow, params, log)

// import modules
include { combine; nanoq; porechop; porechop_abi } from './modules/nanopore-base.nf'
include { minimap2 as minimap2_init; minimap2 as minimap2_rq_filt; minimap2 as minimap2_dehost; minimap2 as minimap2_dehosted } from './modules/nanopore-align.nf'
include { dehost } from './modules/dehost.nf'
include { samtools_index } from './modules/samtools/index/main.nf'
include { medaka; medaka_gpu } from './modules/nanopore-polish.nf'
include { ivar_consensus; ivar_trim; bam2fq; ampliconclip } from './modules/ivar.nf'
include { bedgraph as bedgraph_init; bedgraph as bedgraph_rq_filt; bedgraph as bedgraph_dehost; bedgraph as bedgraph_trim } from './modules/bedtools/bedgraph/main.nf'
include { igv_report as igv_report_init; igv_report as igv_report_rq_filt; igv_report as igv_report_dehost; igv_report as igv_report_trim } from './modules/igv-report/main.nf'
include { seqkit_fx2tab } from './modules/seqkit/fx2tab/main.nf'
include { concat_fasta } from './modules/concat/main.nf'
include { blast_blastn } from './modules/blast/blastn/main.nf'
include { blast_formatter } from './modules/blast/blast_formatter/main.nf'
include { webblast_blastn } from './modules/webblast/blastn/main.nf'
include { mafft } from './modules/mafft/main.nf'
include { msa_vis } from './modules/msa-vis/main.nf'
include { concat_ref_query_fasta } from './modules/concat_ref_query/main.nf'

// define workflow
workflow {
    // read data
    if ( params.input ) {
        data = Channel.fromPath(params.input, checkIfExists: true).splitCsv(header: false)
    } else {
        log.error "No valid inputs were provided."
        System.exit(1)
    }
    
    reference = file(params.reference, checkIfExists:true)
    primers = file(params.primers, checkIfExists:true)
    
    // workflow start
    
    // quality filter
    combine(data)
    if( !params.notrim ) { 
        porechop_abi(combine.out)
        nanoq(
            porechop_abi.out,
            params.min_rl,
            params.min_rq,
            params.max_rl
        )
    } else {
        nanoq(
            combine.out,
            params.min_rl,
            params.min_rq,
            params.max_rl
        )
    }

    // index reference
    samtools_index(reference)

    // reference alignment
    // for init data
    if ( !params.notrim ) { 
        minimap2_init(porechop_abi.out, reference)
    } else {
        minimap2_init(combine.out, reference)
    }

    // align filtered reads to reference
    minimap2_rq_filt(nanoq.out, reference)
    
    // dehosting
    if ( !params.host ) {
        input_aln = minimap2_rq_filt.out
    } else {
        host = file(params.host, checkIfExists:true)
        minimap2_dehost(nanoq.out, host)
        dehost(minimap2_dehost.out)
        minimap2_dehosted(dehost.out.fastq, reference)
        input_aln = minimap2_dehosted.out
    }

    // primer trimming
    // ivar_trim(input_aln, primers)
    ampliconclip(input_aln, primers)
    bam2fq(ampliconclip.out)

    // generate bedgraph for
    // initial alignment
    bedgraph_init(minimap2_init.out, reference, "unfiltered")
    // read quality filter alignment
    bedgraph_rq_filt(minimap2_rq_filt.out, reference, "filtered")
    // dehosted alignment
    if ( params.host) { bedgraph_dehost(dehost.out.bam, reference, "dehosted") }
    // primer trimmed alignment
    bedgraph_trim(ampliconclip.out, reference, "trimmed")

    // build igv reports from bedgraph
    igv_report_init(bedgraph_init.out.map{it[1]}.collect(), samtools_index.out.reference, samtools_index.out.bed, "unfiltered")
    igv_report_rq_filt(bedgraph_rq_filt.out.map{it[1]}.collect(), samtools_index.out.reference, samtools_index.out.bed, "filtered")
    if ( params.host) { igv_report_dehost(bedgraph_dehost.out.map{it[1]}.collect(), samtools_index.out.reference, samtools_index.out.bed, "dehosted") }
    igv_report_trim(bedgraph_trim.out.map{it[1]}.collect(), samtools_index.out.reference, samtools_index.out.bed, "trimmed")

    // consensus calling
    ivar_consensus(ampliconclip.out)

    // check for N content in consensus sequences
    // filter sequence if N exceeds threshold
    seqkit_fx2tab(ivar_consensus.out)
        .join(ivar_consensus.out)
        .filter { it[1].toBigDecimal() <= params.max_N * 100 }
        .map { return tuple(it[0], it[2]) }
        .set { consensus_filt }

    // consensus polishing
    if ( params.gpu ) {
        consensus = medaka_gpu(consensus_filt.join(bam2fq.out))
    } else {
        consensus = medaka(consensus_filt.join(bam2fq.out))
    }

    // run Web BLAST
    if ( params.run_blast ) {
        
        consensus
            .map { it[1] }
            .collect()
            | concat_fasta
        
        blast_blastn(concat_fasta.out)
        blast_formatter(blast_blastn.out.result.map{ it[1] })
        
    }

    if ( params.run_msa ) {
        
        concat_ref_query_fasta(consensus.map { it[1] }.collect(), reference)
        mafft(concat_ref_query_fasta.out)
        msa_vis(mafft.out)
        
    }
    
}