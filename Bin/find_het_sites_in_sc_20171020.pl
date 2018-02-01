#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $singlecellfile = "";
my $bulkfiles = "";
my %hash = ();
my $out = "";

GetOptions( "B=s" => \$bulkfiles, "S=s" => \$singlecellfile, "O=s" =>\$out) or die "Error in input argument\n";

#read in bulk het sites and store in hash
open(my $rb, "<",$bulkfiles) or die "Cannot open $bulkfiles\n";

while(my $bl = <$rb>)
{
	chomp($bl);
	if($bl !~ /Chr/)
	{
		my @a = split(/\t/, $bl);
		my $key = $a[0]."_".$a[1]."_".$a[2]."_".$a[3];
		if(exists $hash{$key}){print "$key exists";}
		else
		{
			$hash{$key} = "";
		}
	}
}
close($rb);

#find sites that are in single cells
open(my $r, "<", $singlecellfile) or die "Cannot open $singlecellfile\n";
open(my $w, ">>", $out) or die "Cannot open $out\n";

while(my $line = <$r>)
{
	chomp($line);
	if($line =~ /CHROM/){print $w "$line\n";}
	else
	{
		my @sca = split(/\t/,$line);
		my $key2 = $sca[0]."_".$sca[1]."_".$sca[3]."_".$sca[4];
		if(exists $hash{$key2})
		{
			print $w "$line\n";
		}			
	}
}


close($r);
close($w);




