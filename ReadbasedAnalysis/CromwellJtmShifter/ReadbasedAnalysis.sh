#!/bin/bash

/global/cfs/projectdirs/m3408/aim2/activate_jtm_manager_and_workers.sh

cd /global/cfs/projectdirs/m3408/aim2/metagenome/ReadbasedAnalysis

java -XX:ParallelGCThreads=4 \
     -Dconfig.file=ReadbasedAnalysis_cromwell_jtm.conf \
     -jar /global/common/software/m3408/cromwell-45.jar \
     run -i ReadbasedAnalysis_inputs.json ReadbasedAnalysis.wdl
