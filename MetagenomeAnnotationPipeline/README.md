# The Metagenome Annotaiton Pipeline

## Summary
This workflow is based on the JGI/IMG annotation pipeline ([details](https://github.com/kellyrowland/img-omics-wdl)). This is still in progress.  It takes assembled metagenomes and generates structrual and functional annotations.  A summary can be seen in [Task 2.1.1](https://github.com/microbiomedata/WorkflowPlanning/blob/master/Task-2.1.1.md).

## Running Workflow in Cromwell

This pipeline is being tested.  Instructions will be posted in the future.  Currently this [repo](https://github.com/kellyrowland/img-omics-wdl/tree/cloud) is the best resource.

## The Docker image can be found here

[microbiomedata/mg-annotation](https://hub.docker.com/repository/docker/microbiomedata/mg-annotation)


## Input files
expects: fasta

## Output files
```
Multiple GFF files.  More details to come.
```

## Dependency graph
![metagenome assembly workflow](workflow_assembly.png)
