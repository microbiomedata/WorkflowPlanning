### Workflow for metatranscriptome Data

A compliant workflow for gene expression analysis, based on the EDGE pipeline, will be developed to be compatible with viewing in NMDC partner platforms

LANL: 1 FTE, 15 months (January 1, 2020 - March 31, 2021)

An NMDC compliant CWL/WDL workflow for gene expression analysis will be developed. A beta- version, LANL metatranscriptome workflow that performs read-mapping to a series of reference genomes or assemblies (with options for splice aware aligners like STAR or HISAT2), followed by counting of reads mapped to transcripts and then detecting significantly differentially expressed genes using DeSeq2 or EdgeR, will be utilized as a starting point. The reference(s) used can be annotated genomes or metagenome assemblies; and the input comprises a number of transcriptomes of the same (or similar) community over time or under different experimental conditions. This will be the primary deliverable for this workflow.
The addition of metatranscriptomes to metagenomic data (if available) for assembly will be explored to augment the reference, or if metagenomes are not available, a de novo metatranscriptome assembly may be invoked. Because detection of differentially expressed genes requires an annotation, the JGI annotation workflow will need to be employed after any assembly of metatranscriptome data. Additional features included in some existing, yet incomplete, workflows such as IMP and HUMAnN2 will be evaluated for inclusion into the pipeline.

#### Environment:
 - CentOS 7
 - Python >= v3.7.6
 - Perl >= v5.26.2
 - Cromwell v48 (BSD 3-Clause)'
 - R v(GPL-2 | GPL-3)
 
#### Third party software used/other dependencies:
 - conda v4.7.12 (BSD 3-Clause)
 - hisat2 v2.1.0 (GPL v3)
 - FaQCs v2.08 (GPL v3)
 - featureCounts v2.0.0 (GPL v3)
 - edgeR (GPL v2.0)
 - tidyverse (GPL v3.0)

#### Hardware requirements:
 -  ```>``` 100 Gb of memory
 
 #### Tests:

