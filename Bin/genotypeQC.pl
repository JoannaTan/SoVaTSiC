#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Cwd;
use POSIX qw(strftime);

#declare variables
my $config = "";
my $directory = "";
my $varianttype = "";
my $bulk_variant_files = "";
my $bulk_depth = "";
my $singlefile = "";
my $potsites = "";
my $samplefile = "";
my $date = strftime "%Y-%m-%d", localtime;
my $thres = 0;
my $prefix = "";

GetOptions("C=s"=>\$config, "D=s"=>\$directory) or die "Error in input argument\n";

# process config file
open(my $readconfig, "<", $config) or die "Cannot open $config\n";

my $binfiles = $directory."/bin";

while(my $configline = <$readconfig>)
{
	chomp($configline);
	my ($var, $info) = split(/\t/, $configline);
	if($var eq "Type"){$varianttype= $info;}
	elsif($var eq "variantfiles"){$bulk_variant_files = $info;}
	elsif($var eq "depthfiles"){$bulk_depth = $info;}
	elsif($var eq "SingleCell"){$singlefile = $info;}
	elsif($var eq "Potentialsites"){$potsites = $info;}
	elsif($var eq "Samplenames"){$samplefile = $info;}	
	elsif($var eq "threshold"){$thres = $info;}
	elsif($var eq "Prefix"){$prefix = $info;}
	else
	{
		print "$var unknown";
		exit 0;
	}
}

close($readconfig);

#find common variants sites between all bulk for TP sites
my $outfile = "Common_variants_shared_by_bulk_".$date.".txt";
my $command1 = "perl $binfiles/find_common_variants_in_bulk_for_genoQC.pl --B $bulk_variant_files --O $outfile";
print "Identifying common variants\n";
my $exit_1=system($command1);
if($exit_1 != 0)
{
        print "Error! Cannot identify common variants\n";
        exit($exit_1 >> 8);
}

#find potential variant sites
my $potential_file = "potential_variant_sites_in_bulk_".$date.".txt";
my $command2 = "perl $binfiles/find_potential_variant_sites.pl --B $potsites --O $potential_file";
my $exit_2=system($command2); 
if($exit_2 != 0)
{
	print "Error! Cannot find potential variant sites\n";
	exit($exit_2 >> 8);
}

#find sites with sufficient coverage
my $coverage_sites_file = "sites_with_sufficient_coverage_in_at_least_1_bulk_".$date.".txt";
my $command3 = "perl $binfiles/find_sites_with_sufficient_coverage_in_at_least_1_bulk.pl --B $bulk_depth --O $coverage_sites_file --T $thres";
my $exit_3=system($command3);
if($exit_3 != 0)
{
	print "Error! Cannot find coverage sites\n";
        exit($exit_3 >> 8);
}

#find TN sites based on bulk
my $tn_out = "sites_with_sufficient_coverage_in_at_least_1_bulk_and_no_variant_".$date.".txt";
my $command4 = "perl $binfiles/find_TN_sites.pl --coverage $coverage_sites_file --O $tn_out --potential_vs $potential_file";
my $exit_4=system($command4);
if($exit_4 != 0)
{
	print "Error! Cannot find TN sites\n";
	exit($exit_4 >> 8);
}


#Process the single cell file 
#Remove the SNVs in clusters first
my $sc_no_clusters = $prefix.$date."_remove_clusters.txt";
my $command5 = "perl $binfiles/check_cluster.pl --i $singlefile --o $sc_no_clusters";
my $exit_5 = system($command5);
if($exit_5 != 0)
{
	print "Cannot remove clusters\n";
	exit($exit_5 >> 8);
}

#Remove triallelic variants
my $sc_no_cluster_no_triallelic = $prefix.$date."_remove_clusters_triallelic.txt";
my $command6 = "perl $binfiles/remove_triallelic.pl --i $sc_no_clusters --o $sc_no_cluster_no_triallelic";
my $exit_6 = system($command6);
if($exit_6 != 0)
{
	print "Cannot remove triallelic sites\n";
	exit($exit_6 >> 8);
}

#Remove singletons and extract variant type of interest
my $sc_no_clus_no_tri_no_single_varianttype = $prefix.$date."_remove_clusters_triallelic_singletons_".$varianttype.".txt";
my $command7 = "perl $binfiles/remove_singletons_and_extract_variant_type.pl --i $sc_no_cluster_no_triallelic --o $sc_no_clus_no_tri_no_single_varianttype --t $varianttype";
my $exit_7 = system($command7);
if($exit_7 != 0)
{
	print "Cannot remove singletons and extract variant type of interest\n";
	exit($exit_7 >> 8);
}

#find TP sites
my $sc_tp_prefix = $prefix.$date;
my $command8 = "perl $binfiles/find_TP_sites.pl --SC $sc_no_clus_no_tri_no_single_varianttype --B $outfile --o $sc_tp_prefix";
my $exit_8 = system($command8);
if($exit_8 != 0)
{
	print "Cannot find TP sites\n";
	exit($exit_8 >> 8);
}

#find FP sites
my $sc_fp_prefix = $prefix.$date;
my $sc_in_for_command9 = $sc_tp_prefix."_NOT_TP_sites.txt";
my $command9 = "perl $binfiles/find_FP_sites.pl --SC $sc_in_for_command9 --B $tn_out --o $sc_fp_prefix";
my $exit_9 = system($command9);
if($exit_9 != 0)
{
	print "Cannot find FP sites\n";
	exit($exit_9 >> 8);
}





