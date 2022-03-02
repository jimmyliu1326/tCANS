[![CANS](https://circleci.com/gh/jimmyliu1326/tCANS.svg?style=svg)](https://app.circleci.com/pipelines/github/jimmyliu1326/tCANS)
# tCANS: Consensus calling for (Tiling) Amplicon Nanopore Sequencing

## Description
`tCANS` is a Nextflow pipeline designed to generate a single contiguous consensus sequence from tiling amplicon Nanopore sequencing data. Primer trimming and consensus calling are performed using iVar followed by consensus polishing using medaka.

## Installation
```bash
# Install Pre-requisites
 - Nextflow >= v21.0.0
 - Conda or Docker

# Clone repository
git clone https://github.com/jimmyliu1326/tCANS.git
```

## Pipeline usage
```
Required arguments:
    --input                       Path to .csv containing two columns encoding Sample ID and path to raw reads DIRECTORY
    --primers                     Path to .bed encoding the position of each primer
    --reference                   Path to .fasta reference sequence that corresponds to the coordinates in the primers .bed file
    --outdir                      Output directory path
Optional arguments:
    --help                        Print pipeline usage statement
```

## Example pipeline call using Conda environments
```
nextflow run /path/to/tCANS.nf --input samples.csv --outdir /path/to/output -profile conda
```

## Example pipeline call using Docker images
```
nextflow run /path/to/tCANS.nf --input samples.csv --outdir /path/to/output -profile docker
```

## Input file formats
To understand the required file formats for the arguments `--input` and `--primers`, take a look at the example files located under `example/` in the repo.