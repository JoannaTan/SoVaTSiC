#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $input = "";
my $output = "";

GetOptions("i=s" => \$input, "o=s" => \$output) or die "Error in input argument\n";

open(my $r, "<", $input) or die "Cannot open $input\n";
open(my $w, ">>", $output) or die "Cannot open $output\n";

while(my $line = <$r>)
{
	chomp($line);
	if($line =~ /CHROM/){print $w "$line\n";}
	else
	{
		my @a = split(/\t/,$line);

		#remove triallelic
		my $alt = $a[4];
		#print "$alt\n";
		if($alt !~ /,/)
		{
			print $w "$line\n";
		}
	}
}

close($r);
close($w);
