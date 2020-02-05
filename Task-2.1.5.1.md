 
## Workflow for Metaproteomic Data  

### Background    
The NMDC initiative will enable users in the environmental microbiology community to easily search and access the microbiome (FICUS) data collected within three national laboratories (PNNL, LANL, and LBNL) using a new framework. Currently, the instrument data (e.g. LC-MS/MS analyses), and data analysis results are being managed via independent systems across labs. This framework will make the different datasets and workflows from each sub-area within environmental microbiology available under one canopy.

### Positioning

  The Integrative Omics group at PNNL currently has their own internal data repository (DMS) that contains metadata, results/data files, etc. related to each sample (single organism or group of meta-organisms) analyzed via mass spectrometry for protein identification and quantification. For long term storage and future external accessibility, DMS data is pushed into the MyEMSL data repository. MyEMSL supports different initiatives across multiple divisions at PNNL to achieve and maintain their respective data and metadata sources.

  Under AIM2, we are developing Meta-proteomics workflow (task 2.1.5: A2170, A2180 &, A2200). Code base is being developed in Python and will be wrapped in a container with all the necessary dependencies needed to run the workflow. Currently, The source data is be obtained from analysis tools such as

- MS-GF+ (1) which performs peptide identification by scoring MS/MS spectra against peptides derived from a protein sequence database (FASTA files). 
- MASIC (2) which extracts intensity information for the identified peptides. 

Currently, this workflow assumes that the output analysis files from MS-GF+(TSV file) and MASIC(SICstats file) tools are available to start the workflow, but moving forward, running MS-GF+ and MASIC as a separate containers would also be provided to the user along with the workflow. The current workflow merges the outputs from MSGF+ and MASIC, and applies filtering to control the false discovery rate. The output is a crosstab format table with rows containing protein sequence information, and columns with relative abundance measurements for proteins identified in each sample analyzed.

In detail progress about the Meta-proteomics workflow could be find here:

[01-20-2020 Presentation](https://drive.google.com/file/d/1qe_PRP2LgwaGuXCBQI2OrOgDIaXt3ZjP/view?usp=sharing) 

### Environment
    
    # Name                    Version 
    python                    3.7.3
    cython                    0.29.14                   
    matplotlib                3.1.2                      
    modin                     0.7.0                    
    numpy                     1.18.1                   
    pandas                    0.25.3                   
    pymssql                   2.1.4                    
    requests                  2.22.0           
    scipy                     1.3.1             
    seaborn                   0.10.0                    
    setuptools                41.6.0                    

### Third party software used/other dependencies:

     (1)    [MS-GF+: Universal Database Search Tool for Mass Spectrometry.](https://github.com/MSGFPlus/msgfplus)
                   Sangtae Kim, Pavel A. Pevzner, Nat Commun. 2014 Oct 31;5:5277. doi: 10.1038/ncomms6277.   
                   
                   This software is Copyright © 2012, 2013 The Regents of the University of California. All Rights Reserved.
                   Permission to copy, modify, and distribute this software and its documentation for educational, research and non-profit purposes, without fee, and without a written agreement is hereby granted, provided that the above copyright notice, this paragraph and the following three paragraphs appear in all copies.
 
    (2)    [MASIC+: (MS/MS Automated Selected Ion Chromatogram generator) a software program for fast quantitation and flexible visualization of chromatographic profiles from detected LC-MS(/MS) features. ](https://github.com/PNNL-Comp-Mass-Spec/MASIC)            
                   Matthew E. Monroe and Shaw, Jason L and Daly, Don S and Adkins, Joshua N and Smith, Richard D   ### Database: DMS- Data management system(temporary purpose.!)
 
                   Licensed under the 2-Clause BSD License; you may not use this file except in compliance with the License. You may obtain a copy of the License at https://opensource.org/licenses/BSD-2-Clause
### Tests
- Integration Tests to ensure individual piece of the pipeline is working as expected.
    - Testing for the following meta-proteomics dataset:
        - MinT soil analysis: "Mint Data" where we have 4 FASTA (one of which is huge and a few smaller ones that only contain replicating microbes). 
        - Hess Proposal
        - in Future: Will coordinate with @Patrick chain to test this workflow on NERSC and their datasets. 
- Unit Tests for internal purpose only.
