#!/bin/bash
#SBATCH --job-name=run_star_alignment_all_samples
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
module load IGVtools/2.9.1


IN="/home/FCAM/xiqiu/data/yamin_Jan30_2026/01.RawData"
OUT="/home/FCAM/xiqiu/meds5420/final_project/out_star"

mkdir -p /home/FCAM/xiqiu/meds5420/final_project/out_star
mkdir -p /home/FCAM/xiqiu/meds5420/final_project/fastqc_out
mkdir -p /home/FCAM/xiqiu/meds5420/final_project/multiqc

cd /home/FCAM/xiqiu/data/yamin_Jan30_2026/01.RawData

ls -d Con_* Lac_* XBP1_[0-9]* XBP1_L_* | sed 's#/##' > list_samples.txt

mv list_samples.txt /home/FCAM/xiqiu/meds5420/final_project/


SAMPLES="/home/FCAM/xiqiu/meds5420/final_project/list_samples.txt" # just basenames

module load fastqc
while read sample; do
    fastqc -t 4 \
    /home/FCAM/xiqiu/data/yamin_Jan30_2026/01.RawData/${sample}/${sample}_*.fq.gz \
    -o /home/FCAM/xiqiu/meds5420/final_project/fastqc_out
done < "$SAMPLES"


module load multiqc

multiqc /home/FCAM/xiqiu/meds5420/final_project/fastqc_out \
-o /home/FCAM/xiqiu/meds5420/final_project/multiqc

while IFS= read -r sample; do
        STAR --runThreadN 8 \
        --genomeDir /home/FCAM/xiqiu/work/indices/star_index_GRCh38_gencode_v47 \
        --readFilesIn $IN/${sample}/${sample}_1.fq.gz \
        $IN/${sample}/${sample}_2.fq.gz \
        --readFilesCommand zcat \
        --outFileNamePrefix $OUT/${sample} \
        --outSAMtype BAM SortedByCoordinate \
        --outBAMsortingThreadN 8 \
        --outFilterType BySJout \
        --outFilterMultimapNmax 20 \
        --alignSJoverhangMin 8 \
        --alignSJDBoverhangMin 1 \
        --outFilterMismatchNmax 999 \
        --outFilterMismatchNoverReadLmax 0.04 \
        --alignIntronMin 20 \
        --alignIntronMax 300000 \
        --alignMatesGapMax 300000
        if [ $? -eq 0 ]; then
                echo "STAR alignment for ${sample} succeeded, proceeding to rename and index."
                mv "${OUT}/${sample}Aligned.sortedByCoord.out.bam" "${OUT}/${sample}.bam"
                igvtools index ${OUT}/${sample}.bam
        else
                echo "STAR alignment for ${sample} failed, skipping rename and index steps."
        fi
done < "$SAMPLES"

date

# Record end time
end_time=$(date +%s)  # Get timestamp in seconds

# Calculate runtime duration
runtime=$((end_time - start_time))
echo "Pipeline completed successfully."
echo "Total runtime: $((runtime / 60)) minutes and $((runtime % 60)) seconds."