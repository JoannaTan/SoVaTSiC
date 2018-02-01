#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use POSIX qw(strftime);
use File::Which;
use File::Basename;

my $configfile = "";
my $directory = "";
my $gq_thres = 0;
my $dp_thres = 0;
my $vaf_thres = 0;
my $var_type = "";
my $scfile = "";
my $normal_bam = "";
my $normal_vcf = "";
my $tut_pattern = "";
my $nor_pattern = "";
my $outfileprefix = "";
my $date = strftime "%Y-%m-%d", localtime;
my $originalvcf = "";
my $refg = "";

GetOptions("C=s" => \$configfile, "D=s" => \$directory) or die "Error in input argument\n";

#process config file

open(my $readconfig, "<", $configfile) or die "cannot read $configfile\n";

while(my $configline = <$readconfig>)
{
	chomp($configline);
	my ($var, $info) = split(/\t/, $configline);
	if($var eq "GQ"){$gq_thres = $info;}
	elsif($var eq "DP"){$dp_thres = $info;}
	elsif($var eq "VAF"){$vaf_thres = $info;}
	elsif($var eq "Type"){$var_type = $info;}
	elsif($var eq "SingleCellFile"){$scfile = $info;}
	elsif($var eq "BulkNormalBAM"){$normal_bam = $info;}
	elsif($var eq "BulkNormalVar"){$normal_vcf = $info;}
	elsif($var eq "TUT_pattern"){$tut_pattern = $info;}
	elsif($var eq "NOR_pattern"){$nor_pattern = $info;}
	elsif($var eq "outprefix"){$outfileprefix = $info;}
	elsif($var eq "tableoriginal"){$originalvcf = $info;}
	elsif($var eq "refgenome"){$refg = $info;}
	else
	{
		print "Not available $var\n";
	}
}

close($readconfig);

my $bindir = $directory."/bin";

#filter genotypes
my $out = $outfileprefix."_".$date."_DP_".$dp_thres."_GQ_".$gq_thres."_VAF_".$vaf_thres;
my $command1 = "perl $bindir/count_number_of_cells_that_pass.pl --DP $dp_thres --GQ $gq_thres --VAF $vaf_thres --f $scfile --o $out";
my $exit_1 = system($command1);
if($exit_1 != 0)
{
	print "Cannot filter genotypes\n";
	exit($exit_1 >> 8);
}
my $final_out_step_1 = $out."_FINAL_ALL_sites_after_cleanup_variants.txt";

#filter sites with 2 or less variant
my $out_step_2 = $out."_remove_singletons.txt";
my $command2 = "perl $bindir/remove_singletons_after_filter_geno.pl --i $final_out_step_1 --o $out_step_2";
my $exit_2 = system($command2);
if($exit_2 != 0)
{
	print "Cannot remove singletons\n";
	exit($exit_2 >> 8);
}

# Step 3: Filter germline bulk data
my $command3 = "perl $bindir/filter_germline.pl --B $normal_vcf --SC $out_step_2";
my $exit_3 = system($command3);
if($exit_3 != 0)
{
	print "Cannot filter germline data\n";
	exit($exit_3 >> 8);
}
my $step3_out = $out."_remove_singletons_remove_germline_sites.txt";

#Step 4: remove germline using single cells
my $command4 = "perl $bindir/filter_genotypes_using_single_cell.pl --file $step3_out --Tpattern $tut_pattern --Npattern $nor_pattern";
my $exit_4 = system($command4);
if($exit_4 != 0)
{
	print "Cannot filter using single cells\n";
	exit($exit_4 >> 8);
}

my $step4_out = $out."_remove_singletons_remove_germline_sites_rm_germline_sc_3normal.txt";

#step 5: filter against file containing all normal single cells (pass QC + fail QC)
my $command5 = "perl $bindir/filter_genotypes_using_single_cell_original_vcf.pl --file $originalvcf --Tpattern $tut_pattern --Npattern $nor_pattern";
my $exit_5 = system($command5);
if($exit_5 != 0)
{
	print "Cannot clean up against original vcf\n";
	exit($exit_5 >> 8);
}
my $step5_out = $originalvcf;
$step5_out =~ s/.table/.preprocess/;

my $command6 = "perl $bindir/final_cleanup_against_original_vcf.pl --file $step4_out --ori $step5_out";
my $exit_6 = system($command6);
if($exit_6 != 0)
{
	print "Cannot remove variants\n";
	exit($exit_6 >> 8);
}

my $file_for_samtools = $step4_out;
$file_for_samtools =~ s/.txt/_for_samtools.txt/;
my $step6out = $step4_out;
$step6out =~ s/.txt/.againstoriginal_notinNormal.txt/;

# filter using pileup data
my $samtools_path = which('samtools');
my $samout = $out."_samtools_output.txt";
if(-e $samtools_path && -x _)
{
	print "Samtools is available\n";
	#to handle multiple normal files,put all the pileup to 1 file
	my @bam_array = split(/,/,$normal_bam);
	for my $bm (@bam_array)
	{
		my $command7 ="$samtools_path mpileup -f $refg -l $file_for_samtools $bm >> $samout";
		my $exit_7 = system($command7);
		if($exit_7 != 0)
		{	
			print "Cannot run Samtools\n";
			exit($exit_7 >> 8);
		}
	}

	my $command8 = "perl $bindir/test.pl --file $samout";
	my $step8out = $samout;
	$step8out = $step8out.".withcounts";		
	
	my $exit_8 = system($command8);
	if($exit_8 != 0)
	{
		print "Cannot clean up pileup\n";
		exit($exit_8 >> 8);
	}
	else
	{
		my $final_outfile = $step6out;
		$final_outfile =~ s/.txt/_notinpileup.txt/;
		my $command9 = "perl $bindir/final_cleanup_against_mpileup.pl --P $step8out --V $step6out --O $final_outfile";
		my $exit_9 = system($command9);
		if($exit_9 != 0)
		{
			print "Cannot filter against pileup\n";
			exit($exit_9 >> 8);
		}
		else
		{
			print "Pipeline completed\n";
		}
	}
}
else
{
	print "Samtools not available\nvariants not filtered against pileup\n";
	
}






