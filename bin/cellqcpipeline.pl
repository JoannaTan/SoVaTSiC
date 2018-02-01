#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Cwd;
use POSIX qw(strftime);

#declare variables
my $config = "";
my $bulkfiles = "";
my $singlecell = "";
my $prefix = "";
my $samplenames = "";
my $flagstat = "";
my $date = strftime "%Y-%m-%d", localtime;
my $directory = "";
my $dp = 0;
my $gq = 0;
my $vaf = 0;
my $type = "";

GetOptions("C=s"=>\$config, "D=s"=>\$directory) or die "Error in input argument\n";

# process config file
open(my $readconfig, "<", $config) or die "Cannot open $config\n";

while(my $line = <$readconfig>)
{
	chomp($line);
	my ($var, $info) = split(/\t/,$line);
	if($var eq "BULK"){$bulkfiles = $info;}
	elsif($var eq "Singlecell"){$singlecell = $info;}
	elsif($var eq "samplenames"){$samplenames = $info;}
	elsif($var eq "flagstat"){$flagstat = $info;}
	elsif($var eq "prefix"){$prefix = $info;}
	elsif($var eq "DP"){$dp = $info;}
	elsif($var eq "GQ"){$gq = $info;}
	elsif($var eq "VAF"){$vaf = $info;}
	elsif($var eq "TYPE"){$type = $info;}
	else{
		print "No such $var\n";
		exit 0;
	}
}

close($readconfig);

my $binfiles = $directory."/bin";

#find heterozygous sites for ADO calculations
my $common_bulk_files = $prefix."_het_sites_for_ado_".$date.".txt";
my $commandline1 = "perl $binfiles/find_common_variants_in_bulk_20171020.pl --B $bulkfiles --O $common_bulk_files";
my $e1=system($commandline1);
if($e1 != 0)
{
	print "Cannot complete identifying heterozygous sites\n";
	exit($e1 >> 8);
}

#find sites in single cells that are present in bulk;
my $single_bulk_common = $prefix."_singlecell_het_sites_in_bulk_".$date.".txt";
my $commandline2 = "perl $binfiles/find_het_sites_in_sc_20171020.pl --B $common_bulk_files --S $singlecell --O $single_bulk_common";
#print "$commandline2\n";
my $e2=system($commandline2);
if($e2 != 0){
	print "Cannot complete identifying het sites in single cells\n";
	exit($e2 >> 8);
}

#find variants per cell
my $commandline3 = "perl $binfiles/filter_sites_using_R.pl --N $samplenames --S $single_bulk_common --dp $dp --gq $gq --mv $vaf --vt $type --d $binfiles";
my $e3=system($commandline3);
if($e3 != 0)
{
	print "Cannot complete filtering of variants\n";
	exit($e3 >> 8);
}

#calculate ADO
my $suffix_from_r = "_all_positions_pass_DP_".$dp."_GQ_".$gq."_filter_".$date."_table.txt";
my $ado_calculations = $prefix."_singlecells_ADO_FN_".$date.".txt";
my $commandline4 = "perl $binfiles/count_ado_and_fn.pl --N $samplenames --S $suffix_from_r --total $common_bulk_files --o $ado_calculations";
my $e4=system($commandline4);
if($e4 != 0)
{
	print "Cannot complete identifying ADO\n";
	exit($e4 >> 8);
}

#concatenate flagstat with ado information
my $final_output = $prefix."_final_ADO_FN_FLAGSTAT_".$date.".txt";
my $commandline5 = "perl $binfiles/concatenate_flagstat.pl --F $flagstat --A $ado_calculations --O $final_output";
my $e5=system($commandline5);
if($e5 != 0)
{
	print "Cannot complete concatenating the info\n";
	exit($e5 >> 8);
}
