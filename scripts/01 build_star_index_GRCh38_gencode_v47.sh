#!/bin/bash
#SBATCH --job-name=build_star_index
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=END
#SBATCH --mem=32G
#SBATCH --mail-user=xqiu@uchc.edu
#SBATCH --output=/home/FCAM/xiqiu/meds5420/final_project/eofiles/%x.%j.out  # Standard output log
#SBATCH --error=/home/FCAM/xiqiu/meds5420/final_project/eofiles/%x.%j.err   # Standard error log

set -e  # Exit immediately if any command fails (important for debugging)

# Record start time
start_time=$(date +%s)  # Get timestamp in seconds


date
echo "host name : " `hostname`

module load STAR/2.7.11a

STAR --runThreadN 8 \
--runMode genomeGenerate \
--genomeDir /home/FCAM/xiqiu/work/indices/star_index_GRCh38_gencode_v47 \
--genomeFastaFiles /home/FCAM/xiqiu/Homo_sapiens.GRCh38.dna.primary_assembly.fa \
--sjdbGTFfile /home/FCAM/xiqiu/work/indices/gencode.v47.nochr.gtf \
--sjdbOverhang 100

date

# Record end time
end_time=$(date +%s)  # Get timestamp in seconds

# Calculate runtime duration
runtime=$((end_time - start_time))
echo "STAR index generation completed."
echo "Total runtime: $((runtime / 60)) minutes and $((runtime % 60)) seconds."