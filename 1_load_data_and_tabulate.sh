#!/bin/bash  
#MSUB -A p30171
#MSUB -q short
#MSUB -l walltime=04:00:00
#MSUB -M dtb@u.northwestern.edu
#MSUB -j oe
#MSUB -N 1_load_tab
#MSUB -l mem=20gb
#MSUB -l nodes=1:ppn=1

# Set working directory 
cd ~/homeownership

# Load R
module load R/3.3.1

# Run script
Rscript 1_load_data_and_tabulate.R