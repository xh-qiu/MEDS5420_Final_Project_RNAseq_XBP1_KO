#!/bin/bash
#SBATCH --job-name=featureCounts_star
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

module load subread

BAM_DIR="/home/FCAM/xiqiu/meds5420/final_project/out_star"
OUT_DIR="/home/FCAM/xiqiu/meds5420/final_project/counts"

mkdir -p $OUT_DIR

featureCounts -T 8 \
-p \
-t exon \
-g gene_id \
--primary \
-a /home/FCAM/xiqiu/work/indices/gencode.v47.nochr.gtf \
-o $OUT_DIR/counts_star.txt \
$BAM_DIR/*.bam

date

# Record end time
end_time=$(date +%s)  # Get timestamp in seconds

# Calculate runtime duration
runtime=$((end_time - start_time))
echo "FeatureCounts completed successfully."
echo "Total runtime: $((runtime / 60)) minutes and $((runtime % 60)) seconds."