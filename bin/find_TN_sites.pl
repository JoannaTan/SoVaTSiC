#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;


#declare variables
my $coverage_files = "";
my $pt_vt_files = "";
my $out = "";
my %varianthash = ();

GetOptions( "coverage=s" => \$coverage_files, "O=s" =>\$out, "potential_vs=s"=>\$pt_vt_files) or die "Error in input argument\n";

#read in the variant files first
open(my $vr, "<", $pt_vt_files) or die "Cannot read $pt_vt_files\n";

while(my $vline = <$vr>)
{
	chomp($vline);
	#put all the variant sites into a hash
	if(exists $varianthash{$vline}){print "repeated $vline\n";}
	else
	{
		$varianthash{$vline} = "";
	}
}

close($vr);

#read in coverage sites
open(my $cr, "<", $coverage_files) or die "Cannot read $coverage_files\n";
open(my $w, ">>", $out) or die "Cannot write to $out\n";

while(my $cline = <$cr>)
{
	chomp($cline);
	#check if site contain variant
	if(exists $varianthash{$cline})
	{
		#variant exists
	}
	else
	{
		print $w "$cline\n";
	}
}


close($cr);
close($w);
