#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use POSIX qw(strftime);

my $flagstat = "";
my $adofile = "";
my $out = "";
my %hash = ();

GetOptions( "F=s" => \$flagstat, "A=s" => \$adofile, "O=s" => \$out) or die "Error in input argument\n";

open(my $readfile, "<", $flagstat) or die "Cannot open $flagstat\n";

while(my $l = <$readfile>)
{
	chomp($l);
	if($l !~ /Sample/)
	{
		my @a = split(/\t/,$l);
		my $sam = $a[0];
		if(exists $hash{$sam}){print "REPEATED SAMPLE\n";}
		else
		{
			$hash{$sam} = $l;
		}
	}
}

close($readfile);

open(my $ra, "<", $adofile) or die "Cannot open $adofile\n";

open(my $w, ">>", $out) or die "Cannot write to $out\n";

print $w "Sample\tTotal_number_processed_by_BWA\tNumber_of_duplicates\tPercentage_of_duplicates\tNumber_of_Mapped_reads\tPercentage_of_mapped_reads\tX1\tX5\tX8\tX10\tDepth\tSamplename\tTotal\tNumber_of_homozygous\tNumber_of_het\tNumber_of_variants_site\tFN\tADO\n";

while(my $line = <$ra>)
{
	chomp($line);
	if($line !~ /Samplename/)
	{
		my @b = split(/\t/,$line);
		my $sn = $b[0];
		if(exists $hash{$sn})
		{
			my $val = $hash{$sn};
			print $w "$val\t$line\n";
		}
	}
		
}

close($ra);
close($w);
