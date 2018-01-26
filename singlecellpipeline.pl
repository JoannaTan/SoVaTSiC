#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Cwd;
use POSIX qw(strftime);
use File::Basename;

my $configfile = "";
my $analysistype = "";
my $help;
my $date = strftime "%Y-%m-%d", localtime;

my $header = "
This script is used to perform quality control of single cell data.

Usage:
	perl singlecellpipeline.pl [OPTIONS]
Options:
	--Config = config file specifying the parameters *
	--Analysistype = the type of analysis users will want to use *. Users can choose between CellQC, GenotypeQC, filtergenotypes, and filtersomatic. 
	--help : prints this mesage.

Author: Joanna Tan\n";

if ( @ARGV == 0 ) {
        print "$header";
        exit 0;
}

GetOptions("Config=s" => \$configfile, "Analysistype=s" => \$analysistype, "help" => \$help) or die "ERROR in input argument. Please type --help for more information\n";

if ($help) {
	print $header;
	exit 0;
}

my $dir = getcwd();
print "$dir\n";

my $script_dir = dirname(__FILE__);
print "$script_dir\n";

print "$analysistype\n"; 

if($analysistype eq "CellQC")
{
	print "Cell Quality Control pipeline chosen\n";
	my $cellcommand = "perl $script_dir/bin/cellqcpipeline.pl --C $configfile --D $script_dir";
	my $exit_1=system($cellcommand);
	if($exit_1 != 0)
	{
		print "Error! Cannot complete running pipeline\n";
		exit($exit_1 >>8);
	}
	else
	{
		print "Pipeline Completed\n";
	}	
}
elsif($analysistype eq "GenotypeQC")
{
	print "GenotypeQC pipeline chosen\n";
	my $genocommand = "perl $script_dir/bin/genotypeQC.pl --C $configfile --D $script_dir";
	my $exit_2 = system($genocommand);
	if($exit_2 != 0)
	{
		print "Error! Cannot complete running $analysistype pipeline\n";
		exit($exit_2 >> 8);
	}
	else
	{
		print "$analysistype pipeline completed\n";
	}	
}
elsif($analysistype eq "filtergenotypes")
{
	print "Filtering genotypes and somatic mutations\n";
	my $filtercommand = "perl $script_dir/bin/filtergenotype_and_somatic.pl --C $configfile --D $script_dir";
	my $exit_3 = system($filtercommand);
	if($exit_3 != 0)
	{
		print "Error! cannot complete running $analysistype pipeline\n";
		exit($exit_3 >> 8);
	}
	else
	{
		print "$analysistype completed\n";
	}
			
}
else
{
	print "No such analysis - $analysistype. Type --help for more information\n";
}
