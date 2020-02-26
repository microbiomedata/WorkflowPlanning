# Metatranscriptomic pipeline

## Summary
This workflow is designed for analyzing metatranscriptomic datasets.


## Testing workflow

```
	java -jar cromwell/cromwell-48.jar run workflows/metaT.wdl -i  test_data/test_input.json 

```


## Running Workflow in Cromwell
You should run this on cori. There are two ways to run the workflow.  
1. (SlurmCromwellShifter) The submit script will request a node and launch the Cromwell.  The Cromwell manages the workflow by using Shifter to run applications. 
2. (CronwellSlurmShifter) The Cromwell run in head node and manages the workflow by submitting each step of workflow to compute node where applications were ran by Shifter.

## The Docker image and Dockerfile can be found here

```

```

You can find more documentation at 

## Running Requirements
unknown at this time

## Input files
expects: fastq, illumina, paired-end
fasta: reference genomes or contigs
gff: reference annotation file

## Output files


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

## Dependency graph
![metagenome assembly workflow](workflow_assembly.png)
