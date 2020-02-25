FROM conda/miniconda3:latest

# $ docker build . -t poeli/nmdc_taxa_profilers:latest --build-arg http_proxy=http://proxyout.lanl.gov:8080 --build-arg https_proxy=http://proxyout.lanl.gov:8080
# $ docker run --rm -it -v `pwd`:/data -v databases:/databases poeli/nmdc_taxa_profilers:latest /bin/bash
# $ docker push poeli/nmdc_taxa_profilers:latest

MAINTAINER Po-E Li <po-e@lanl.gov>
LABEL version="0.0.1"
LABEL software="NMDC_taxa_pipeline"
LABEL tags="bioinformatics"

ENV container docker

RUN apt-get update -y \
    && apt-get install -y build-essential unzip wget curl gawk \
    && apt-get clean

RUN conda update -n base -c defaults conda \
    && conda config --add channels conda-forge \
    && conda config --add channels bioconda \
    && conda install kraken2 centrifuge minimap2 krona pandas \
    && ktUpdateTaxonomy.sh \
    && conda clean -a \
    && wget https://github.com/poeli/GOTTCHA2/archive/master.zip \
    && unzip master.zip \
    && cp GOTTCHA2-master/*.py /usr/local/bin \
    && rm -rf GOTTCHA2-master/ master.zip

ENV PERL5LIB="/usr/local/opt/krona/lib:${PERL5LIB}"

CMD ["/bin/bash"]