### Workflow for contig binning and MAG generation pipeline

A compliant workflow for contig binning and MAG generation, based on the IMG/M and EDGE pipelines, will be developed to be compatible with viewing in NMDC partner platforms

An NMDC compliant containerized CWL/WDL workflow for MAG generation will be developed. Existing alpha and beta versions of such a pipeline exists at JGI and LANL, as well as at KBase and are based on contig binning methods followed by cursory verification and characterization of the bins. More specifically, MaxBin2 or MetaBat2 are used for contig binning, and CheckM, (and/or GTDB-Tk), and additional downstream processing and refinement scripts are used for MAG validation and quality determination. This includes initial estimates of genome completeness and contamination, and genome taxonomic classification based on marker genes. While these types of pipelines are now standard in the scientific community, they all frequently perform poorly in complex microbiomes, with most genome bins (or MAGs) requiring significant manual curation. We propose to use the JGI and LANL pipelines as a starting point to evaluate additional validation best practices and determine an algorithm and set of cutoffs to provide a series of more accurate MAGs. Results from MAG pipelines will be shared with KBase so that metabolic modeling work can be developed to expand the downstream analysis of MAG. We will perform contig-level alignments against reference genome databases as well as encoded protein alignments to capture sequenced organisms who are not well represented in genomic databases. Each aligned section of a contig may have multiple overlapping hits, thus a modified last common ancestor algorithm may best be applied to merge alignment results with assignment to various levels of taxonomy. Results of this process can be assessed independently from the unsupervised binning methods. This strategy, coupled with the binning methods, will help validate both the quality and taxonomy assignment of the bins/MAGs, as well as help recruit singleton contigs or small bins into larger MAGs, improving completeness. Phylogenetic assessment using whole genome SNP methods have been shown to best recapitulate evolutionary history and can help pinpoint specifically where genomes fit among other sequenced organisms. This can provide a more refined and higher confidence taxonomic assignment.
All methods described above may best be applied to different types of microbiomes, or to different ‘fractions’ of microbiomes. For example, binning methods work best with longer contigs and relatively deep fold coverage (higher relative abundance), which are tied to one another, as deeply covered organisms will produce more overlapping data and help assembly. Supervised methods are typically less reliant on long sequences and deep coverage. Characterization using marker genes versus genome-wide SNPs also work best in different circumstances. We propose to examine a diverse pool of metagenomes of varying complexities and taxonomic compositions in order to better ascertain the details of the NMDC workflow, its default settings, and thresholds.
 
#### Environment:
 - CentOS 7
 - Python >= v3.6 
 - Python v2.7 (required by CheckM and GTDB-Tk)
 - Perl >= v5.16
 - Cromwell v44
 
#### Third party software used/other dependencies:
 - conda v4.7.10
 - MaxBin2 v2.2.7
 - MetaBat2 v2.13
 - dRep v2.3.2
 - CheckM v1.0.18
 - GTDB-Tk v0.3.2

#### Hardware requirements:
 -  ```>``` 100 Gb of memory
 
#### Database:
 - gtdbtk_r89_data
 - checkm_data_2015_01_16 
 

#### Tests:
 - Assembly from Mock dataset: SRR7877884
 - Assembly from Simulated dataset
