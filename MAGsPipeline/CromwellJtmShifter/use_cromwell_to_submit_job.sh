#!/bin/bash

/global/cfs/projectdirs/m3408/aim2/activate_jtm_manager_and_workers.sh

cd /global/cfs/projectdirs/m3408/aim2/metagenome/MAGs

java -XX:ParallelGCThreads=32 \
     -Dconfig.file=jtm.conf \
     -jar /global/common/software/m3408/cromwell-45.jar \
     run -i mag_input_w_pname.json MAGgeneration_jtmShifter.wdl

## if Cromwell service is up and localhost:8000, we can use api to submit job instaed of run Cromwell instance locally.
#curl -X POST --header "Accept: application/json" -v "localhost:8000/api/workflows/v1" -F workflowSource=@MAGgeneration_jtmShifter.wdl -F workflowInputs=@mag_input_w_pname.json
