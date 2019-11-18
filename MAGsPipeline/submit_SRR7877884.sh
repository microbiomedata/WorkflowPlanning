#!/bin/bash
#SBATCH --qos=regular
#SBATCH --time=1800:00
#SBATCH --output=/global/project/projectdirs/m3408/aim2/metagenome/MAGs/SRR7877884.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 24
#SBATCH --constraint=knl
#SBATCH --account=m3408
#SBATCH --job-name=MAGs_SRR7877884

cd /global/project/projectdirs/m3408/aim2/metagenome/MAGs

java -Dconfig.file=shifter.conf -jar /global/common/software/m3408/cromwell-45.jar run -i input_SRR7877884.json  MAGgeneration_docker.wdl

