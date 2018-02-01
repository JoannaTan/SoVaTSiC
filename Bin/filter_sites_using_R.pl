#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use POSIX qw(strftime);

my $singlecellfile = "";
my $namesfiles = "";
my $dp = 0;
my $gq = 0;
my $min_var_count = 0;
my $vtype = 0;
my $date = strftime "%Y-%m-%d", localtime;
my $dir = "";

GetOptions( "N=s" => \$namesfiles, "S=s" => \$singlecellfile, "dp=i" => \$dp, "gq=i"=>\$gq, "mv=i"=>\$min_var_count, "vt=s"=>\$vtype, "d=s"=>\$dir) or die "Error in input argument\n";

open(my $readfile, "<", $namesfiles) or die "Cannot open $namesfiles\n";

while(my $sline = <$readfile>)
{
	chomp($sline);
	if($sline !~ /#/)
	{
		my @info_a = split(/\t/, $sline);
		my $samplename = $info_a[0];
		my $type = $info_a[1];
		my $cell = $info_a[2];
		if($cell == 1)
		{
			# single cell and run R to get sites in each cell
			my $command_line = "Rscript $dir/filter_genotypes.R $singlecellfile $gq $dp $samplename $min_var_count $date $vtype";
			system($command_line);
		}
	}
}
close($readfile);
