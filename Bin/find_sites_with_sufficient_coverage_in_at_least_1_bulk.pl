#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;


#declare variables
my $bulkfiles = "";
my $out = "";
my @bulkarray = ();
my %hash = ();
my $threshold = 0;

GetOptions( "B=s" => \$bulkfiles, "O=s" =>\$out, "T=i" => \$threshold) or die "Error in input argument\n";

@bulkarray = split(',',$bulkfiles);

foreach my $file (@bulkarray)
{
	print "$file\n";
	open(my $rn, "<", $file) or die "Cannot open $file\n";
	while(my $ln = <$rn>)
	{
		chomp($ln);
		if($ln !~ /Locus/)
		{
			#not those information line
			my @nonheaderline = split(/\t/,$ln);
			my $loci = $nonheaderline[0];
			my $depth = $nonheaderline[1];
			if($depth >= $threshold)
			{ 	
				if(exists $hash{$loci})
				{
					# already got 1 sample with sufficient coverage
				}
				else
				{
					$hash{$loci} = "";
				}
			}	
		}
	}
	close($rn);
}

#print hash
open(my $w, ">>", $out) or die "Cannot write to $out\n";

foreach my $k1 (sort keys %hash)
{
	print $w "$k1\n";
}

close($w);




