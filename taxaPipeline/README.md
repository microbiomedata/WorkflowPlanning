# The Metagenome Taxonomy Profiling Pipeline

This workflow is developed for Task-2.1.2. The pipeline takes sequencing files (single- or paired-end) and profiles them using multiple taxonomic classification tools with the Cromwell as the workflow manager.

## Run jobs under cromwell

Use `taxaPipeline_sbatch.sh` to launch a Cromwell job. The Cromwell manages the workflow and uses Shifter to run enabled tools.

Description of the files:
 - `taxaPipeline.wdl`: the WDL file for taxanomy profiling pipeline.
 - `taxaProfilerTasks.wdl`: the WDL file for tasks of each tool.
 - `taxaPipeline_inputs.json`: the example inputs.json file for the pipeline.
 - `taxaPipeline_sbatch.sh`: the shell script for the Slurm's sbatch.
 - `taxaPipeline_cromwell.conf`: the conf file for running cromwell.

## Docker image

The docker images for all profilers is at the docker hub: `poeli/nmdc_taxa_profilers:latest`. The `Dockerfile` can be found in `Docker/nmdc_taxa_profilers/` directory.

## Inputs

To enable profiling tool(s), set the value to `true` with the tool name as the key in `taxaProfiler.enabled_tools`.

```json
{
  "taxaProfiler.enabled_tools": {
    "gottcha2": true,
    "kraken2": true,
    "centrifuge": true
  },
  "taxaProfiler.db": {
    "gottcha2": "/path/to/gottcha2/db",
    "kraken2": "/path/to/kraken2/db",
    "centrifuge": "/path/to/centrifuge/db"
  },
  "taxaProfiler.reads": [
    "/path/to/read1.fastq.gz",
    "/path/to/read2.fastq.gz"
  ],
  "taxaProfiler.paired": true,
  "taxaProfiler.prefix": "test",
  "taxaProfiler.outdir": "/path/to/sample_test",
  "taxaProfiler.cpu": 4
}
```

## Workflow
![workflow](../Docker/nmdc_taxa_profilers/workflow.png)
