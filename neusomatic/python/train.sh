tumor_bam=$1
work_dir=$2
truth_vcf=$3
if [ $# -gt 3 ];
then
	model="--checkpoint $4"
else
	model=""
fi

set -e

rm -rf $work_dir

python3 preprocess.py \
	--mode train \
	--reference /media/pgdrive/sharif/cfdna/cfDNA/References/Homo_sapiens_assembly38.fasta \
	--region_bed /media/pgdrive/sharif/cfdna/cfDNA/DataSeries2/Raw_files/cfdna.bed \
	--tumor_bam $tumor_bam \
	--normal_bam /media/pgdrive/sharif/cfdna/cfDNA/DataSeries2/ALN/p1/p1_blood.addRG.bam \
	--truth_vcf $truth_vcf \
	--work $work_dir \
	--min_mapq 20 \
	--num_threads 10 \
	--scan_alignments_binary ../bin/scan_alignments

python3 train.py \
	--candidates_tsv $work_dir/dataset/*/candidates*.tsv \
	--out $work_dir \
	$model \
	--num_threads 10 \
	--batch_size 100

