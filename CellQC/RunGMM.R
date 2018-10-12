#!/usr/bin/env Rscript-3.2.3

# use the mixtools package from R (We use R-3.2.3, mixtools version 1.0.4)
library(mixtools)  

#read user input
args <- commandArgs(TRUE)
combine = args[1]
prefix = args[2]

#better to set seed updated here on 20181012
# previously, i did not set seed because i follow the example in 
# https://www.r-bloggers.com/fitting-mixture-distributions-with-the-r-package-mixtools/
# checked lung dataset, with and without seed, the results are the same
# checked eso 1 dataset, with and without seed, the results are the same (3 component)
# checked bladder dataset, with and without seed, the results are the same
set.seed(1000)

# Change the input file name to your own file name
Table <-read.table(combine, header=TRUE, sep="\t", row.names=1)

# perform GMM on the percentage of genome covered with 5x  
mixmdl_5x = normalmixEM(Table$X5)

# plot the density curve and save the image in postscript format
postscript(paste(prefix,"_density_plot.ps",sep=""))  
plot(mixmdl_5x,  which  =  2)  
lines(density(Table$X5),  lty  =  2,  lwd  =  2)  
dev.off()

#  get  the  posterior  probability so that you can know which curve your cells fall into
X5_PP <- mixmdl_5x$posterior  
X5_likelihood <- mixmdl_5x$loglik  
	
# Get the cell names so that you can use it to populate the table
cellnames  <- rownames(Table)  
number_of_cells <- dim(Table)[1]
	
#  generate  a  big  table to store the data
Big <-data.frame(CELL = rep(NA, number_of_cells), X5 = rep(NA, number_of_cells), ADO = rep(NA, number_of_cells), FN = rep(NA, number_of_cells), X5_curve1 = rep(NA, number_of_cells), X5_curve2 = rep(NA, number_of_cells), stringsAsFactors = FALSE)
	
#  populate  the  table  with  the  information    
for  (i in  1: number_of_cells)  { 
	x5_c1  =  x5_c2   =  0  
	name <- cellnames[i]  
	pp_x5_c1 <- X5_PP[i,1]  
	pp_x5_c2 <- X5_PP[i,2]  
	x5_v <- Table$X5[i]  
	ado_v <- Table$ADO[i]  
	fn_v <- Table$FN[i]       

	#	check which prob is larger and assign cell to that curve
	if (pp_x5_c1 > pp_x5_c2) {x5_c1 = 1}else if(pp_x5_c2 > pp_x5_c1){x5_c2 = 1}        
	Big[i,]<- c(toString(name), x5_v, ado_v, fn_v, x5_c1, x5_c2)    
} # End of for loop

#output  the  data  
write.table(Big, paste(prefix,"_table_combine_information.txt",sep=""), sep = "\t", row.names =FALSE, quote=FALSE)    
