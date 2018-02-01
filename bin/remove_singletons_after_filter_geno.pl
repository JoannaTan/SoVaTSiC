#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $input = "";
my $output = "";
my $het_counts_col = 0;
my $hom_alt_counts_col = 0;

GetOptions("i=s" => \$input, "o=s" => \$output) or die "Error in input argument\n";

open(my $r, "<", $input) or die "Cannot open $input\n";
open(my $w, ">>", $output) or die "Cannot open $output\n";

while(my $line = <$r>)
{
	chomp($line);
	if($line =~ /Pos/)
	{
		# print headerline
		print $w "$line\n";
		
		#process headerline
		my @header_array = split(/\t/,$line);
		for(my $i = 0; $i <= $#header_array; $i++)
		{
			my $header_v = $header_array[$i];
			if($header_v eq "HOMALT_PASS"){$hom_alt_counts_col = $i;}
			elsif($header_v eq "HET_PASS"){$het_counts_col = $i;}
		}	

	}
	else
	{
		my $het_count = 0;
		my $hom_alt_count = 0;
		my $total = 0;
		my @nor_line_array = split(/\t/, $line);
		$het_count = $nor_line_array[$het_counts_col];
		$hom_alt_count = $nor_line_array[$hom_alt_counts_col];
		$total = $het_count+$hom_alt_count;

		if($total >=3)
		{
			print $w "$line\n";
		}
 
	}
}

close($r);
close($w);
