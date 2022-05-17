[![CANS](https://circleci.com/gh/jimmyliu1326/tCANS.svg?style=svg)](https://app.circleci.com/pipelines/github/jimmyliu1326/tCANS)
# tCANS: Consensus calling for (Tiling) Amplicon Nanopore Sequencing

## Description
`tCANS` is a Nextflow pipeline designed to generate a single contiguous consensus sequence from tiling amplicon Nanopore sequencing data. The pipeline uses `samtools ampliconclip`, `iVar` and `medaka` to perform primer trimming, consensus calling and consensus polishing, respectively.

## Installation
```bash
# Install Pre-requisites
 - Nextflow >= v21.0.0
 - Conda or Docker

# Download workflow locally
nextflow pull -hub github jimmyliu1326/tCANS
```

## Pipeline usage
```
Required arguments:
    --input                       Path to .csv containing two columns encoding Sample ID and path to raw reads DIRECTORY
    --primers                     Path to .bed encoding the position of each primer
    --reference                   Path to .fasta reference sequence that corresponds to the coordinates in the primers .bed file
    --outdir                      Output directory path
Optional arguments:
    --host                        Path to host reference genome in FASTA format for dehosting raw reads
    --notrim                      Disable adapter trimming by Porechop
    --gpu                         Accelerate specific processes that utilize GPU computing. Must have NVIDIA Container
                                  Toolkit installed to enable GPU computing, otherwise use CPU. (Only works with -profile docker)
    --help                        Print pipeline usage statement
```

## Example pipeline call using Conda environments
```
nextflow run jimmyliu1326/tCANS --input samples.csv --outdir /path/to/output -profile conda
```

## Example pipeline call using Docker images
```
nextflow run jimmyliu1326/tCANS --input samples.csv --outdir /path/to/output -profile docker
```

## Input file formats
To understand the required file formats for the arguments `--input` and `--primers`, take a look at the example files located under `example/` in the repo.