FROM conda/miniconda3:latest

# $ docker build . -t poeli/nmrc_taxa_pipeline:latest --build-arg http_proxy=http://proxyout.lanl.gov:8080 --build-arg https_proxy=http://proxyout.lanl.gov:8080
# $ docker run --rm -it -v `pwd`:/data -v databases:/databases poeli/nmrc_taxa_pipeline:latest /bin/bash
# $ docker push poeli/nmrc_taxa_pipeline:latest

MAINTAINER po-e@lanl.gov
LABEL version="0.0.1"
LABEL software="NMDC_taxa_pipeline"
LABEL tags="bioinformatics"

ENV container docker

# prepare directories for inputs and databases
RUN apt-get update -y \
    && apt-get install -y build-essential unzip wget curl gawk

RUN conda update -n base -c defaults conda \
    && conda config --add channels conda-forge \
    && conda config --add channels bioconda \
    && conda install -c bioconda kraken2 centrifuge \
    && conda install minimap2 pandas  \
    && wget https://github.com/poeli/GOTTCHA2/archive/master.zip \
    && unzip master.zip \
    && cp GOTTCHA2-master/*.py /usr/local/bin \
    && rm -rf GOTTCHA2-master/ master.zip \
    && conda install -c bioconda krona \
    && ktUpdateTaxonomy.sh

ENV PERL5LIB="/usr/local/opt/krona/lib:${PERL5LIB}"

CMD ["/bin/bash"]
