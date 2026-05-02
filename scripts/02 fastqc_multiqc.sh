#!/bin/bash
#SBATCH --job-name=Quality_control
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

module load fastqc
module load MultiQC/1.15


mkdir -p /home/FCAM/xiqiu/meds5420/final_project/fastqc_out
mkdir -p /home/FCAM/xiqiu/meds5420/final_project/multiqc

# cd /home/FCAM/xiqiu/data/yamin_Jan30_2026/01.RawData

#ls -d Con_* Lac_* XBP1_[0-9]* XBP1_L_* | sed 's#/##' > list_samples.txt

#mv list_samples.txt /home/FCAM/xiqiu/meds5420/final_project/


SAMPLES="/home/FCAM/xiqiu/meds5420/final_project/list_samples.txt" # just basenames


while IFS= read -r sample; do
    echo "Running FastQC for $sample"
    fastqc -t 4 \
    /home/FCAM/xiqiu/data/yamin_Jan30_2026/01.RawData/${sample}/${sample}_*.fq.gz \
    -o /home/FCAM/xiqiu/meds5420/final_project/fastqc_out
done < "$SAMPLES"


multiqc /home/FCAM/xiqiu/meds5420/final_project/fastqc_out \
-o /home/FCAM/xiqiu/meds5420/final_project/multiqc


date

# Record end time
end_time=$(date +%s)  # Get timestamp in seconds

# Calculate runtime duration
runtime=$((end_time - start_time))
echo "Quality control (FastQC and MultiQC) completed successfully."
echo "Total runtime: $((runtime / 60)) minutes and $((runtime % 60)) seconds."