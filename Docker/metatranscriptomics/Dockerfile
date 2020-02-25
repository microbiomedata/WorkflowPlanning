FROM conda/miniconda3:latest

# $ docker build . -t migun/nmdc_metat:latest --build-arg http_proxy=http://proxyout.lanl.gov:8080 --build-arg https_proxy=http://proxyout.lanl.gov:8080
# $ docker login
# $ docker push migun/nmdc_metat:latest

LABEL version="0.0.1"
LABEL software="NMDC_metattranscriptomics workflow"
LABEL tags="bioinformatics"

ENV container docker

RUN apt-get update -y \
    && apt-get install -y build-essential unzip wget curl gawk \
    && apt-get clean

RUN conda update -n base -c defaults conda \
    && conda config --add channels conda-forge \
    && conda config --add channels bioconda \
    && conda install faqcs hisat2 subread \
    && conda clean -a

CMD ["/bin/bash"]