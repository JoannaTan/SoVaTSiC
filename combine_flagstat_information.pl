#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;

my $saminfofile="";
my $output="";
my $help;

my $header = "
This script is used to combine the flagstat, depthofcoverage information.

Usage:
        perl combine_flagstat_information.pl [OPTIONS]
Options:
        --input = tab-delimited file containing samplename,path to flagstat file, path to cumulative proportion file (output of GATK depthofcoverage), and path to sample summary file (output of GATK depthofcoverage) *
        --o = output file name
        --help : prints this mesage.

* denotes compulsory option

Author: Joanna Tan\n";

if ( @ARGV == 0 ) {
        print "$header";
        exit 0;
}

GetOptions( "input=s"  => \$saminfofile, "o=s" => \$output)  or die("Error in command line arguments\n");

if ($help) {
        print $header;
        exit 0;
}

open(my $rf, "<", $saminfofile) or die "Cannot open $saminfofile\n";

open( my $w, ">>", $output) or die "Cannot write to $output\n";
print $w "Sample\tTotal_number_processed_by_BWA\tNumber_of_duplicates\tPercentage_of_duplicates\tNumber_of_Mapped_reads\tPercentage_of_mapped_reads\t1x\t5x\t8x\t10x\tDepth\n";

while(my $sam=<$rf>)
{
	chomp($sam);
	my @sample_array = split(/\t/, $sam);
	my $samplename = $sample_array[0];
	my $flagstat_file = $sample_array[1];
	my $proportional_file = $sample_array[2];
	my $sample_summary_file = $sample_array[3];
	my $value=readfile($flagstat_file,$samplename);
	my $value2=read_proportion_file($proportional_file, $samplename);
	my $value3=read_depth($sample_summary_file, $samplename);	

	print $w "$value\t$value2\t$value3\n";	
}
close($rf);
close($w);

### FUNCTIONS ###
sub read_depth
{
	my ($dfile, $sam) = @_;
	
	open(my $rdf, "<", $dfile) or die "Cannot open $dfile\n";
	my $dp = 0;

	while(my $line = <$rdf>)
	{
		chomp($line);
		if($line !~ /sample_id/ || $line !~ /Total/)
		{
			my @b = split(/\t/, $line);
			$dp = $b[2];
		}
	}
	close($rdf);
	return($dp);	
}

sub readfile
{
	my ($sfile, $sname) = @_;
	#print "$sfile\t$sname\n";
	
	open(my $statsf,"<",$sfile) or die "Cannot open $sfile";
	
	my $total = 0;
	my $duplicates = 0; 
	my $mapped = 0;
	my @lines = <$statsf>;

	for(my $i=0; $i <3; $i++)
	{
		my $line = $lines[$i];
		chomp($line);
		if($line =~ /total/)
		{
			my @t = split(" ", $line);
			$total = $t[0];

		}
		elsif($line =~ /duplicates/)
		{

			my @d = split(" ", $line);
			$duplicates = $d[0];
		}
		elsif($line =~ /mapped/)
		{
			my @m = split(" ", $line);
			$mapped = $m[0];
		}
		else
		{	
			next LINE1;
		}	
	}
	close($sfile);

	my $percent_mapped = ($mapped/$total)*100;
	my $percent_dup = ($duplicates/$mapped)*100;
	return ("$sname\t$total\t$duplicates\t$percent_dup\t$mapped\t$percent_mapped");
}

sub read_proportion_file
{
	my ($pfile, $samn) = @_;
	open(my $r, "<", $pfile) or die "Cannot open $pfile\n";

	my $x1 = 0;
	my $x5 = 0;
	my $x8 = 0;
	my $x10 = 0;

	while(my $l = <$r>)
	{
		chomp($l);
		if($l !~ /gte/)
		{
			my @a = split(/\t/, $l);
			$x1 = $a[2];
			$x5 = $a[6];
			$x8 = $a[9];
			$x10 = $a[11];
		}
	}
	return("$x1\t$x5\t$x8\t$x10");	
	close($r);
}


