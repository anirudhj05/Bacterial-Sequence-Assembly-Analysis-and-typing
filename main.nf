#!/usr/bin/env nextflow

// Defined parameters for command line arguments.
params.forwardReads = ''
params.reverseReads = ''
params.results_dir = 'results' // Defined a base directory for results
params.lineage = 'bacteria_odb10' // Using one lineage for simplicity, can be change to preferred lineage or use 
//use this command for flexibility: busco -i $assembledSeq -o busco_results -m genome --auto-lineage
// I have used both the commands and the auto lineage command will take longer to run so just used one for simplicity
workflow {
    // This workflow performs trimming, assembly, sequence typing, and quality evaluation
    trimmed_reads = TrimSequencingReads(Channel.fromPath(params.forwardReads), Channel.fromPath(params.reverseReads))
    assembled_sequence = AssembleTrimmedReads(trimmed_reads)

    // Running quality evaluation and sequence typing in parallel
    busco_report = EvaluateAssemblyQuality(assembled_sequence)
    mlst_results = SequenceTyping(assembled_sequence)
}

// Process to trim sequencing reads using Trimmomatic.
process TrimSequencingReads {
    publishDir "${params.results_dir}/trimmed_reads", mode: 'copy'
    
    input:
    path forwardIn
    path reverseIn

    output:
    tuple path('trimmed_forward.fastq.gz'), path('trimmed_reverse.fastq.gz')

    script:
    """
    trimmomatic PE -phred33 $forwardIn $reverseIn trimmed_forward.fastq.gz forward_unpaired.fastq.gz trimmed_reverse.fastq.gz reverse_unpaired.fastq.gz SLIDINGWINDOW:4:30 MINLEN:50
    """
}
// Used skesa for genome assembly
process AssembleTrimmedReads {
    publishDir "${params.results_dir}/assembled_sequences", mode: 'copy'
    
    input:
    tuple path(trimmedForward), path(trimmedReverse)

    output:
    path 'assembled_sequence.fasta'

    script:
    """
    skesa --reads $trimmedForward $trimmedReverse --contigs_out assembled_sequence.fasta
    """
}
// used busco for quality assessment; used one-lineage bacteria_odb10 for demonstration
process EvaluateAssemblyQuality {
    publishDir "${params.results_dir}/assembly_quality", mode: 'copy'
    
    input:
    path assembledSeq

    output:
    path 'busco_results'

    script:
    """
    busco -i $assembledSeq -o busco_results -l ${params.lineage} -m genome
    """
}
// Used MLST for sequence typing
process SequenceTyping {
    publishDir "${params.results_dir}/sequence_typing", mode: 'copy'
    
    input:
    path typedSeq

    output:
    path 'mlst_output.txt'

    script:
    """
    mlst $typedSeq > mlst_output.txt
    """
}
