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
			my $nfilter = $normal_line[6];
			my $ninfo = $normal_line[9];
			my ($ngt, $nad, $ndp, $ngq, $npl) = split(/:/,$ninfo);
			if($nalt !~ /,/ && $nfilter eq "PASS")
			{
				# make sure no triallelic sites
				my $nkey = $nchr."_".$npos."_".$nref."_".$nalt."_".$ngt;
				if(exists $hash{$nkey})
				{
					$hash{$nkey}{$file} = $ninfo;
				}
				else
				{
					#initialise hash
					foreach my $name (@bulkarray)
					{
						$hash{$nkey}{$name} = "NA";
					}
			
					$hash{$nkey}{$file} = $ninfo;
			
				}
			}	
		}
	}
	close($rn);
}

#print hash
open(my $w, ">>", $out) or die "Cannot write to $out\n";
my $j = 0;
LINE1:foreach my $k (sort keys %hash)
{
	if($j==0)
	{
		print $w "Chr\tPos\tRef\tAlt\tGeno";
		foreach my $s (sort keys %{$hash{$k}})
		{
			print $w "\t$s";
		}
		$j++;
		print $w "\n";
	}
	else{ last LINE1;}
}

foreach my $k1 (sort keys %hash)
{
	my ($c, $p, $r, $a, $geno) = split(/_/, $k1);

	my @array_v = (); #flush contents
	my $counter = 0;
	foreach my $s1 (sort keys %{$hash{$k1}})
	{
		my $v = $hash{$k1}{$s1};
		push(@array_v, $v);	
		if($v ne "NA")
		{
			$counter++;
		}	
	}

	# check if counter == total number of ssamples
	# if yes, means all sample got variants
	my $size_of_array = scalar(@array_v);
	if($size_of_array == $counter)
	{
		print $w "$c\t$p\t$r\t$a\t$geno";
		foreach my $var (@array_v)
		{
			print $w "\t$var";
		}
		print $w "\n";	
	}
}

close($w);




