# Fern Virus Discovery Pipeline

A Snakemake pipeline for plant virus discovery in metatranscriptomic sequencing data, including read processing and assembly, identification and clustering of viral contigs, prediction of open reading frames (ORFs), and functional annotation of viral proteins. The pipeline also identifies viral movement proteins using a custom movement protein HMM database.

## Workflow

The pipeline performs the following steps:

1. Download FASTQ files from NCBI SRA for the sample accessions listed in a TSV file.
2. Trim reads, remove adapters and perform quality filtering using Trimmomatic.
3. Assemble reads with SPAdes.
4. Create an MMseqs2 database and identify contigs by taxonomy.
5. Filter virus-associated contigs and cluster sequences.
6. Map reads to representative contigs and calculate coverage with CoverM.
7. Predict ORFs, translate ORFs into protein sequences, and search proteins with MMseqs2 and movement protein profiles using HMMER.
8. Combine representative contigs, coverage, ORF, and HMMER results into TSV summary tables.


Clustering was based on average nucleotide identity (ANI). ANI calculation and clustering were performed using `anicalc.py` and `aniclust.py`, adapted from the publicly available
[genome-ANI-Leiden-clustering-pipeline](https://github.com/apcamargo/bioinformatics-snakemake-pipelines/tree/main/genome-ani-leiden-clustering-pipeline).

## Requirements

- [Conda](https://docs.conda.io/) or [Mamba](https://mamba.readthedocs.io/)
- [Snakemake](https://snakemake.readthedocs.io/)
- The NCBI and MMseqs2 databases

Update the database paths in the relevant rules if the database is stored elsewhere:

- `workflow/rules/mmseqs2_taxonomy.smk`
- `workflow/rules/mmseqs2_proteins.smk`
- `workflow/rules/mmseqs2_proteins_2.smk`

## Installation

Clone the repository and enter the project directory:

```bash
git clone https://github.com/piasotlar/fern-virus-discovery-pipeline.git
cd fern-virus-discovery-pipeline
```

Create the Snakemake environment if it is not already installed:

```bash
conda create -c conda-forge -c bioconda -n snakemake snakemake
conda activate snakemake
```

## Running the pipeline

Before running the pipeline modify the workflow to your needs configuration files (config/reprezentative_samples.tsv, config/config.yaml), Snakefile (workflow/Snakefile) and other parameters.

Run from the `workflow` directory:

```bash
cd workflow
snakemake --use-conda --cores <num_cores> 
```

## Repository contents

- `workflow/Snakefile`: main workflow and final targets
- `workflow/rules/`: Snakemake rules for each analysis step
- `workflow/scripts/`: Python scripts used for processing and table creation
- `workflow/envs/`: Conda environments for individual tools
- `config/`: sample lists and pipeline configuration
- `resources/adapters/`: adapter sequences
- `resources/mp_db/`: HMM profiles
