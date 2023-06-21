
nextflow.enable.dsl = 2

include { CHECK_STRANDNESS } from './modules/check_strandness.nf'
include { FASTP } from './modules/fastp'
include { STAR_INDEX_REFERENCE ; STAR_ALIGN } from './modules/star.nf'
include { SAMTOOLS } from './modules/samtools'
include { CUFFLINKS } from './modules/cufflinks'

log.info """\
         RNAseq differential analysis using NextFlow 
         =============================
         outdir: ${params.outdir}
         """
         .stripIndent()
 
params.outdir = 'results'

workflow {
    
    read_pairs_ch = channel.fromFilePairs( params.reads, checkIfExists: true ) 
    CHECK_STRANDNESS( read_pairs_ch, params.reference_cdna, params.reference_annotation_ensembl )
    FASTP( read_pairs_ch )
    STAR_INDEX_REFERENCE( params.reference_genome, params.reference_annotation )
    STAR_ALIGN( CHECK_STRANDNESS.out, FASTP.out.sample_trimmed, STAR_INDEX_REFERENCE.out, params.reference_annotation )
    SAMTOOLS( STAR_ALIGN.out.sample_sam )
    CUFFLINKS( CHECK_STRANDNESS.out, SAMTOOLS.out.sample_bam, params.reference_annotation )
}

