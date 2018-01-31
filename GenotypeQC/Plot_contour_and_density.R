#!/usr/bin/env Rscript-3.2.3

library(MASS)    

#read user input
args <- commandArgs(TRUE)
TP_sites <- args[1]
FP_sites <- args[2]
prefix <- args[3]

# read in True positive variants 
TP <- read.table(TP_sites, header = TRUE, sep = "\t")

# read in False positive variants 
FP <- read.table(FP_sites, header = TRUE, sep = "\t")

# Get the density for TP
# we limit the read depth between 0 to 200 because the DP can span up to 1000 + 
#so we may not be able to see if the range is too large
# n is the number of grid points in each direction(for plotting) 
TPdensity <- kde2d(TP$DP, TP$GQ, n = c(20, 5), lims = c(0, 200, 0, 99))

# Get the density for FP 
FPdensity <- kde2d(FP$DP, FP$GQ, n = c(20, 5), lims = c(0, 200, 0, 99))

# find the difference between TP and FP 
res <- list(x = TPdensity$x, y = TPdensity$y, z = TPdensity$z - FPdensity$z)

# plot the contour 
postscript(paste(prefix,"_contour_plot_of_differences_TP_and_FP.ps",sep="")) 
filled.contour(res, main = "Contour plot for differences in density\nbetween TP and FP", xlab = "DP", ylab = "GQ", col = rainbow(25)) 
dev.off()  

#plot the density plot

postscript(paste(prefix,"_density_plot_of_differences_TP_and_FP.ps",sep=""))
plot(density(TP$VAF), main = "Distribution of variant allele frequency", xlab = "Variant Allele Frequency (VAF)", lwd = 2)  

# plot the density distribution of VAF for FP
lines(density(FP$VAF), col = "red", lwd = 2)  

#plot legend
legend("topleft", fill = c("black", "red"), col = c("black", "red"), c("TP", "FP"), cex = 2)  
dev.off()  





