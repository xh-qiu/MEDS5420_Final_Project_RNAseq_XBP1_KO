#!/bin/bash
#SBATCH --job-name=test_star_Con_1
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 4
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


sample="Con_1"

echo "Testing sample: $sample"

STAR --runThreadN 4 \
--genomeDir /home/FCAM/xiqiu/work/indices/star_index_GRCh38_gencode_v47 \
--readFilesIn \
"$IN/${sample}/${sample}_1.fq.gz" \
"$IN/${sample}/${sample}_2.fq.gz" \
--readFilesCommand zcat \
--outFileNamePrefix $OUT/${sample}_ \
--outSAMtype BAM SortedByCoordinate \
--outBAMsortingThreadN 4 \
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
    mv "${OUT}/${sample}_Aligned.sortedByCoord.out.bam" "${OUT}/${sample}.bam"
    samtools index "${OUT}/${sample}.bam"
    igvtools index ${OUT}/${sample}.bam
fi

date

# Record end time
end_time=$(date +%s)  # Get timestamp in seconds

# Calculate runtime duration
runtime=$((end_time - start_time))
echo "Pipeline completed successfully."
echo "Total runtime: $((runtime / 60)) minutes and $((runtime % 60)) seconds."