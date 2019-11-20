#!/bin/bash
#SBATCH --qos=regular
#SBATCH --time=48:00:00
#SBATCH --output=/global/project/projectdirs/m3408/aim2/metagenome/MAGs/SRR7877884.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 32
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=lo.chienchi@gmail.com
#SBATCH --constraint=knl
#SBATCH --account=m3408
#SBATCH --job-name=MAGs_SRR7877884

#OpenMP settings:
export OMP_NUM_THREADS=8
export OMP_PLACES=threads
export OMP_PROC_BIND=spread

cd /global/project/projectdirs/m3408/aim2/metagenome/MAGs

java -Dconfig.file=shifter.conf -jar /global/common/software/m3408/cromwell-45.jar run -i input_SRR7877884.json  MAGgeneration_docker.wdl

