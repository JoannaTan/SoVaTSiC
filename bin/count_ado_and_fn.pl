#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use POSIX qw(strftime);

my $suffix = "";
my $namesfiles = "";
my $dp = 0;
my $gq = 0;
my $min_var_count = 0;
my $vtype = 0;
my $totalfile = "";
my $total = 0;
my $out = "";
my $date = strftime "%Y-%m-%d", localtime;

GetOptions( "N=s" => \$namesfiles, "S=s" => \$suffix, "total=s" => \$totalfile, "o=s" => \$out) or die "Error in input argument\n";

#count the number of variants in the bulk first
open(my $r, "<", $totalfile) or die "Cannot read $totalfile\n";
while(my $l = <$r>)
{
	chomp($l);
	if($l !~ /Chr/){$total++;}
	
}
close($r);
print "$total\n";

#count the ADO and FN
open(my $readfile, "<", $namesfiles) or die "Cannot open $namesfiles\n";
open(my $w, ">>",$out) or die "Cannot open $out\n";

print $w "Samplename\tTotal\tNumber_of_homozygous\tNumber_of_het\tNumber_of_variants_sites\tFN\tADO\n";

while(my $sline = <$readfile>)
{
	chomp($sline);
	if($sline !~ /#/)
	{
		print "$sline\n";
		my @info_a = split(/\t/, $sline);
		my $samplename = $info_a[0];
		my $type = $info_a[1];
		my $cell = $info_a[2];
		if($cell == 1)
		{
			# single cell
			my $number_of_variants = 0;
			my $number_of_homozygous = 0;
			my $number_of_het = 0;
			my $scfile = $samplename.$suffix;
			open(my $rscf, "<", $scfile) or die "Cannot open $scfile\n";
			while(my $line = <$rscf>)
			{
				chomp($line);
				$line =~ s/"//g;
				if($line !~ /CHROM/)
				{
					$number_of_variants++;
					my @a = split(/\t/,$line);
					my $chr = $a[0];
					my $pos = $a[1];
					my $ref = $a[3];
					my $alt = $a[4];
					my $gt = $a[5];
					my ($rf, $al) = split(/\//,$gt);
					if($rf eq $al)
					{
						#homozygous
						$number_of_homozygous++;
					}
					else
					{
						$number_of_het++;
					}
				}	
			}
                	close($rscf);
			my $fn = ($total-$number_of_variants)/$total;
			my $ado = ($number_of_homozygous)/$total;
			print $w "$samplename\t$total\t$number_of_homozygous\t$number_of_het\t$number_of_variants\t$fn\t$ado\n";
		}
	}
}
close($readfile);
close($w);
