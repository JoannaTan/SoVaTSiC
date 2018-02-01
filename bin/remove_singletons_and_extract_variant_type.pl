#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $input = "";
my $output = "";
my $hom_ref_col = 0;
my $het_col = 0;
my $hom_alt_col = 0;
my $type_col = 0;
my $type_input = "";

GetOptions("i=s" => \$input, "o=s" => \$output, "t=s" => \$type_input) or die "Error in input argument\n";

open(my $r, "<", $input) or die "Cannot open $input\n";
open(my $w, ">>", $output) or die "Cannot open $output\n";

while(my $line = <$r>)
{
	chomp($line);
	if($line =~ /CHROM/)
	{
		print $w "$line\n";
		#process headerline
		my @headerarray = split(/\t/, $line);
		for(my $i = 0; $i<=$#headerarray; $i++)
		{
			my $header_value = $headerarray[$i];
			if($header_value eq "HET"){$het_col = $i;}
			elsif($header_value eq "HOM-REF"){$hom_ref_col = $i;}
			elsif($header_value eq "HOM-VAR"){$hom_alt_col = $i;}
			elsif($header_value eq "TYPE"){$type_col = $i;}	
		}
		#print "$het_col\t$hom_ref_col\t$hom_alt_col\t$type_col\n";
	}
	else
	{
		my @normal_line = split(/\t/, $line);
		my $het_counts = $normal_line[$het_col];
		my $hom_ref_counts = $normal_line[$hom_ref_col];
		my $hom_alt_counts = $normal_line[$hom_alt_col];
		my $type_info = $normal_line[$type_col];
		my $total_variant_counts = ($het_counts+$hom_alt_counts);
		if($total_variant_counts > 1 && $type_info eq $type_input)
		{
			print $w "$line\n";
		}
	}
}

close($r);
close($w);
