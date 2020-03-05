# Metatranscriptomic pipeline

## Summary
This workflow is designed for analyzing metatranscriptomic datasets.


## Running workflow

### In local computer/server with conda
Running workflow in a local computer or server where all the dependencies are installed and in path. cromwell should be installed in the same directory as this file. 

`cd` into the folder and:

```
	$ java -jar cromwell/cromwell-XX.jar run workflows/metaT.wdl -i  test_data/test_input.json 

```

### In a local computer/server with docker
Running workflow in a local computer or server using docker. cromwell should be installed in the same directory as this file.
```
  java -jar cromwell/cromwell-XX.jar run workflows/docker_metaT.wdl -i  test_data/test_input.json 

```

###  In cori with shifter and JTM

Running workflow in cori with shifter and JTM:

The submit script will request a node and launch the Cromwell.  The Cromwell manages the workflow by using Shifter to run applications.

```


```

## Running Workflow in Cromwell
You should run this on cori. There are two ways to run the workflow.  
1. (SlurmCromwellShifter)  
2. (CronwellSlurmShifter) The Cromwell run in head node and manages the workflow by submitting each step of workflow to compute node where applications were ran by Shifter.

## Docker image

The docker images for all profilers is at the docker hub: `migun/nmdc_metat:latest`. The `Dockerfile` can be found in `Docker/metatranscriptomics/` directory.


## Running Requirements
unknown at this time

## Input files
expects: fastq, illumina, paired-end
fasta: reference genomes or contigs
gff: reference annotation file
json: json with input

```json
{
    "metaT.projectName":"SRR2126941",
    "metaT.cpu" : 1,
    "metaT.DoQC" : true,
    "metaT.QCopts" :"",
    "metaT.PairedReads":["test_data/BTT_test15_R1.fastq.gz","test_data/BTT_test15_R1.fastq.gz"],
    "metaT.ref_genome": "test_data/test_prok.fna",
    "metaT.ref_gff": "test_data/test_prok.gff"
  }

```


## Output files




## Version 1 of the workflow

![metatranscriptomics workflow](workflow_metatranscriptomics.png)
