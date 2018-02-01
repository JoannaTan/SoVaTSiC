#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;


#declare variables
my $bulkfiles = "";
my $out = "";
my @bulkarray = ();
my %hash = ();

GetOptions( "B=s" => \$bulkfiles, "O=s" =>\$out) or die "Error in input argument\n";

@bulkarray = split(',',$bulkfiles);

foreach my $file (@bulkarray)
{
	print "$file\n";
	open(my $rn, "<", $file) or die "Cannot open $file\n";
	while(my $ln = <$rn>)
	{
		chomp($ln);
		if($ln !~ /#/)
		{
			#not those information line
			my @normal_line = split(/\t/,$ln);
			my $nchr = $normal_line[0];
			my $npos = $normal_line[1];
			my $nid = $normal_line[2];
			my $nref = $normal_line[3];
			my $nalt = $normal_line[4];
			my $ninfo = $normal_line[9];
			my ($ngt, $nad, $ndp, $ngq, $npl) = split(/:/,$ninfo);
			my $nkey = $nchr.":".$npos;
			if(exists $hash{$nkey})
			{
				# variant exists
			}
			else
			{
				$hash{$nkey} = "";
			
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




