FROM conda/miniconda3:latest

# $ docker build . -t migun/nmdc_metat:latest --build-arg http_proxy=http://proxyout.lanl.gov:8080 --build-arg https_proxy=http://proxyout.lanl.gov:8080
# $ docker login
# $ docker push migun/nmdc_metat:latest

LABEL version="0.0.1"
LABEL software="NMDC_metatranscriptomics workflow"
LABEL tags="bioinformatics"

ENV container docker

RUN apt-get update -y \
    && apt-get install -y build-essential unzip wget curl gawk \
    && apt-get clean

RUN conda update -n base -c defaults conda \
    && conda config --add channels conda-forge \
    && conda config --add channels bioconda \
    && conda install faqcs hisat2 subread \
    && conda install samtools \
    && conda clean -a

RUN R -e "install.packages('BiocManager', repos = 'http://cran.us.r-project.org')" \
    && R -e "BiocManager::install('edgeR')"

RUN R -e "install.packages('tidyverse', repos = 'http://cran.us.r-project.org')" \
    R -e "install.packages('optparse', repos = 'http://cran.us.r-project.org')"

RUN wget https://github.com/mshakya/WorkflowPlanning/archive/master.zip \
    && unzip master.zip \
    && cp WorkflowPlanning-master/metatranscriptomics/scripts/edgeR.R /usr/local/bin \
    && rm -rf WorkflowPlanning-master/ master.zip

CMD ["/bin/bash"]