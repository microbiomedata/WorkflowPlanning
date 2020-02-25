# The Metagenome contig binning and MAG generation pipeline

## Summary
This workflow take paired-end reads and assembled contigs runs contig binning, bin refine step, abundance report and bins annootation using [metawrap](https://github.com/bxlab/metaWRAP).

## Running Workflow in Cromwell
You should run this on cori. There are three ways to run the workflow.
1. `CromwellJtmShifter/`: run in head node send tasks to jtm-task-managers which will manages the tasks running on a computer node and using Shifter to run applications.
2. `SlurmCromwellShifter/`: The submit script will request a node and launch the Cromwell.  The Cromwell manages the workflow by using Shifter to run applications. 
3. `CromwellSlurmShifter/`: The Cromwell run in head node and manages the workflow by submitting each step of workflow to compute node where applications were ran by Shifter.

Description of the files in each sud-directory:
 - `.wdl` file: the WDL file for workflow definition
 - `.json` file: the example input for the workflow
 - `.conf` file: the conf file for running Cromwell.
 - `.sh` file: the shell script for running the example workflow

## The Docker image and Dockerfile can be found here

```
bioedge/nmdc_mags:withchkmdb
```

You can find more documentation on https://hub.docker.com/r/bioedge/nmdc_mags

## Running Requirements
unknown at this time

## Input files
  1. fastq (illumina, paired-end)
  2. fasta contig file

## Output files
```
```

## Dependency graph
![metagenome assembly workflow](pipeline.png)
