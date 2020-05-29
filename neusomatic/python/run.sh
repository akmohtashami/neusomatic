tumor_bam=$1
work_dir=$2

if [ $# -gt 2 ];
then
	model=$3
else
	model=../models/NeuSomatic_v0.1.4_standalone_SEQC-WGS-GT50-SpikeWGS10.pth
fi

set -e

rm -rf $work_dir

python3 preprocess.py \
	--mode call \
	--reference /media/pgdrive/sharif/cfdna/cfDNA/References/Homo_sapiens_assembly38.fasta \
	--region_bed /media/pgdrive/sharif/cfdna/cfDNA/DataSeries2/Raw_files/cfdna.bed \
	--tumor_bam $tumor_bam \
	--normal_bam /media/pgdrive/sharif/cfdna/cfDNA/DataSeries2/ALN/p1/p1_blood.addRG.bam \
	--work $work_dir \
	--min_mapq 20 \
	--num_threads 10 \
	--scan_alignments_binary ../bin/scan_alignments

python3 call.py \
	--candidates_tsv $work_dir/dataset/*/candidates*.tsv \
	--reference /media/pgdrive/sharif/cfdna/cfDNA/References/Homo_sapiens_assembly38.fasta \
	--out $work_dir \
	--checkpoint $model \
	--num_threads 10 \
	--batch_size 100

python3 postprocess.py \
	--reference /media/pgdrive/sharif/cfdna/cfDNA/References/Homo_sapiens_assembly38.fasta \
	--tumor_bam $tumor_bam \
	--pred_vcf $work_dir/pred.vcf \
	--candidates_vcf $work_dir/work_tumor/filtered_candidates.vcf \
	--output_vcf $work_dir/NeuSomatic.vcf \
	--work $work_dir

