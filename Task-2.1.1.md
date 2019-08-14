### Workflow for shotgun metagenome assembly and annotation

A compliant workflow for metagenome assembly and annotation, based on the IMG/M pipeline, will be developed such that the data products will be compatible with viewing in NMDC partner platforms (IMG/M, KBase, EDGE).

The shotgun metagenome assembly and annotation workflow will be evaluated for current and future scalability, as well as implementation on metagenomes of diverse complexities and data quantities: evaluation of the trade-offs between quality of the metagenome assembly and annotation with how they scale with metagenomic data size and metagenome complexity (i.e. memory usage, time to completion, and computational resources required). LANL will partner with colleagues at JGI and will leverage existing tests for MEGAHIT, MetaSPades and IDBA-UD on large (>100M read) data sets of various complexities.
 
#### Environment:
 - CentOS 7
 - Python >= v3.6 
 - Perl >= v5.16
 - Cromwell v43
 
#### Third party software used/other dependencies:
 - conda v4.7.10
 - MEGAHIT v1.2.8
 - MetaSPades v3.13.1
 - IDBA-UD v1.1.3
 - metaQuast v2.2
 - Prokka v1.14.0
 
#### Database:
 - database come with Prokka annotation software
 
#### Tests:
 - Mock dataset: SRR7877884
 - simulated dataset
