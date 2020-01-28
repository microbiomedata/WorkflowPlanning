# The Metagenome Assembly Pipeline

## Summary
$This workflow is developed by Brian Foster at JGI and original from his [repo](https://gitlab.com/bfoster1/wf_templates/tree/master/templates). It take paired-end reads runs reads quailty trimming, artifact removal, linker-trimming, adapter trimming, and spike-in/host removal by rqcfilter (BBTools:38.44), then error corrected by bbcms (BBTools). The clean reads are assembled by MetaSpades. After assembly, the reads are mapped back to contigs by bbmap (BBTools) for coverage information.

## Running Workflow in Cromwell
You should run this on cori. There are three ways to run the workflow.  
1. `SlurmCromwellJtmShifter/`: The submit script will start a jtm-task-manager. The Cromwell send tasks to jtm-task-managers which will manages the tasks running on a computer node and using Shifter to run applications. 
2. `SlurmCromwellShifter/`: The submit script will request a node and launch the Cromwell.  The Cromwell manages the workflow by using Shifter to run applications. 
3. `CronwellSlurmShifter/`: The Cromwell run in head node and manages the workflow by submitting each step of workflow to compute node where applications were ran by Shifter.

Description of the files in each sud-directory:
 - `.wdl` file: the WDL file for workflow definition
 - `.json` file: the example input for the workflow
 - `.conf` file: the conf file for running Cromwell.
 - `.sh` file: the shell script for running the example workflow

## The Docker image and Dockerfile can be found here

[bryce911/bbtools:38.44](https://hub.docker.com/r/bryce911/bbtools)
[bryce911/spades:3.13.0](https://hub.docker.com/r/bryce911/spades)


## Input files
expects: fastq, illumina, paired-end

## Output files
```
```

## Dependency graph
![metagenome assembly workflow](workflow_assembly.png)
