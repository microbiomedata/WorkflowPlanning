### Workflow for shotgun metagenome read-based analysis
A compliant workflow for shotgun metagenome read-based analysis will be based on the EDGE pipelines and will be developed to conform to standard BIOM format for viewing in NMDC partner platforms.

LANL: 1 FTE, 15 months (October 1, 2019 - December 31, 2020)

An NMDC compliant containerized CWL/WDL workflow for read-based shotgun metagenome will be developed. LANL will leverage the development of GOTTCHA2, a taxonomy identification/classification tool based on the detection of unique genomic signatures and will also develop an algorithm that estimates a confidence score for organism presence. The GOTTCHA2 algorithm is flexible in accommodating searches for unique signatures across the tree of life, and the inclusion of specialized databases compatible with the GOTTCHA2 algorithm will be provided. We will evaluate inclusion of additional read-based tools and their databases, depending on their accuracy and scalability. Scalability will require evaluation of the tool-specific databases, how robust the algorithm is to the ever-changing public repositories of reference genomes, and the ability to create updated searchable databases.

#### Environment:
 - CentOS 7
 - Python v3.6 
 - Pandas v2.2
 - Biom 2.1.7
 - Cromwell v44
 
#### Third party software used/other dependencies:
 - minimap2 v2.17 (MIT License)
 - GOTTCHA2 (GPL3)

#### Source:
 - https://github.com/poeli/GOTTCHA2

#### Database:
 - NCBI Refseq release 90
 - NCBI Taxonomy database
 - Pre-built database is available (https://edge-dl.lanl.gov/GOTTCHA2/RefSeq-Release90/)
 - The available database includes bacterial, archaeal and viral genomes. Eukaryotic database can be built separately (e.g. Fungi database). 

#### Tests:
 - Current tests are integrated with Travis/Circle CI.
