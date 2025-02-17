# Microbial Genome Assembly and Analysis Pipeline
This Nextflow pipeline integrates several processes including trimming sequencing reads, assembling sequences, and evaluating assembly quality, as well as performing sequence typing. This pipeline is configured for bacterial genomes but can be adapted for other organisms by adjusting the lineage parameter.

## Prerequisites
- **Nextflow**: Ensure Nextflow is installed on your system. It can be installed with:
```bash
curl -s https://get.nextflow.io | bash
sudo mv nextflow /usr/local/bin/
```
- **Java**: Java 8 or higher is required for running Nextflow.
```bash
java -version
sudo apt install default-jdk
```
- **Conda**: Recommended for managing the software dependencies. Install Miniconda if it's not already installed from Miniconda's website.

## Installing Dependencies
- Trimmomatic
```bash
conda create -n trimmomatic -c bioconda trimmomatic
```
- SKESA
```bash
conda create -n skesa -c bioconda skesa
```
- BUSCO
```bash
conda create -n busco -c bioconda busco
```
- MLST
```bash
conda create -n mlst -c bioconda mlst
```

## Parameters
Define parameters in the script or via the command line to customize the pipeline execution.
1. `forwardReads`: Path to forward sequencing reads (FASTQ format).
2. `reverseReads`: Path to reverse sequencing reads (FASTQ format).
3. `results_dir`: Directory to store pipeline results.
4. `lineage`: Taxonomic lineage for BUSCO assessment, default set to bacteria_odb10, but can be changed for other organisms.

## Pipeline Process

1.  **TrimSequencingReads** - This function uses trimmomatic to trim adapters and low-quality sequences from sequencing reads. Adjust `SLIDINGWINDOW` and `MINLEN` as per sequencing quality requirements. The trimmed forward and reverse reads are saved in `${params.results_dir}/trimmed_reads`.
2.  **AssembleTrimmedReads** - This function assembles trimmed reads into contigs using SKESA. Specify additional SKESA parameters if needed for specific assembly requirements. The assembled sequences are stored in `${params.results_dir}/assembled_sequences`.
3.  **EvaluateAssemblyQuality** - This function uses BUSCO to assess the quality of the assembled sequences based on the specified lineage. Modify the -l parameter for different organisms. BUSCO results, providing insights into the completeness and quality of assemblies, are located in `${params.results_dir}/assembly_quality`.
4.  **SequenceTyping** - This function applies MLST for sequence typing to categorize bacterial isolates based on housekeeping genes. The  MLST results are saved in `${params.results_dir}/sequence_typing`.

### Pipeline Execution
Execute the pipeline using the following command, specifying all necessary parameters:
```bash
nextflow run main.nf --forwardReads /path/to/forward_reads.fastq.gz --reverseReads /path/to/reverse_reads.fastq.gz
```
For a specific example:
```bash
nextflow run main.nf --forwardReads ~/data/SRRXXXXXX_1.fastq.gz --reverseReads ~/data/SRRXXXXXX_2.fastq.gz --results_dir /path/to/results
```
