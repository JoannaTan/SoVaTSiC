#!/mnt/software/bin/R


#This script takes in the gatk jointgenotyping data and identify nucleotide positions that pass quality control for each cell/sample.
#The script will output a set of file:
# 1. positions that are heterozygous in the cell/sample
# 2. positions that are homozygous for the variant allele
# 3. positions that are homozygous for the reference allele

args <- commandArgs(TRUE)
input_file = args[1]
gq_score_filter = as.integer(args[2])
dp_score_filter = as.integer(args[3])
i = args[4]  #samplename
minread = args[5]
varianttype = args[7]
date<-Sys.Date()

print(varianttype)

forprint<-paste("Identifying nucleotide positions from",i,sep=" ")
print(forprint)

Data <-read.table(input_file, sep="\t", header=TRUE, check.names=FALSE)
snplines <- which(Data$TYPE == varianttype)
Data_SNP <- Data[snplines,]

sample_genotype_col <- paste(i,".GT",sep="")
sample_genoquality_col <- paste(i,".GQ", sep="")
sample_depth_col <- paste(i,".DP",sep="")
sample_pl <- paste(i,".PL",sep="")
sample_ad <- paste(i,".AD",sep="")
colnames_data <- colnames(Data)
#print(sample_genoquality_col)
#print(sample_depth_col)
#print(sample_genotype_col)
gt_col <- grep(sample_genotype_col,colnames_data)
gq_col <- grep(sample_genoquality_col,colnames_data)
dp_col <- grep(sample_depth_col,colnames_data)
pl_col <- grep(sample_pl,colnames_data)
ad_col <- grep(sample_ad,colnames_data)
col_to_keep=c(1,2,3,4,5,gt_col,ad_col,dp_col,gq_col,pl_col)
#print(col_to_keep)


rows_to_keep <- which(Data_SNP[,sample_genoquality_col] >= gq_score_filter & Data_SNP[,sample_depth_col]>= dp_score_filter)
final_positions_table <- Data_SNP[rows_to_keep,col_to_keep]
number_of_pos <- length(rows_to_keep)
filename_all_positions <- paste(i,"all_positions_pass_DP",dp_score_filter,"GQ",gq_score_filter,"filter",date,"table.txt",sep="_")
write.table(final_positions_table,filename_all_positions,sep="\t",row.names=FALSE, col.names=TRUE)
