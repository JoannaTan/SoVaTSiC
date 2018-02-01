#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $bulkfile = "";
my $singlecell = "";
my %hash = ();
my $num_of_normal = 0;

GetOptions("B=s" => \$bulkfile, "SC=s" =>\$singlecell) or die "Error in Input Arguments\n";


my @bulk_array = split(/,/, $bulkfile);

foreach my $bulkfile_read (@bulk_array)
{
	print "$bulkfile_read\n";
	#Read the file
	open(my $rf, "<", $bulkfile_read) or die "Cannot open $bulkfile_read\n";

	LINE1:while(my $l = <$rf>)
	{	
		chomp($l);
		if($l =~ /#/){next LINE1;}
		else
		{
			my @b = split(/\t/, $l);
			my $c = $b[0];
			my $p = $b[1];
			my $r = $b[3];
			my $a = $b[4];
			my $fil = $b[6];
			my $k = $c."_".$p."_".$r."_".$a;

			if($fil eq "PASS")
			{
				#print "$k\t$fil\n";
				if(exists $hash{$k}){next LINE1;}
				else
				{		
					$hash{$k} = "$l";
				}
			}
		}
	}
	close($rf);
}

# Read the table
open(my $rt, "<", $singlecell) or die "Cannot open $singlecell\n";

my $out = $singlecell;
$out =~ s/.txt/_remove_germline_sites.txt/;
open(my $w, ">>", $out) or die "Cannot open $out\n";

my $go = $singlecell;
$go =~ s/.txt/_in_bulk_normal.txt/;
open(my $ww, ">>", $go) or die "Cannot open $go\n";


LINE2:while(my $line = <$rt>)
{
	chomp($line);
	if($line =~ /Pos/){
		print $w "$line\n";
		print $ww "$line\n";
	}
	else{
		my @a = split(/\t/, $line);
		my $chr = $a[0];
		my $pos = $a[1];
		my $rsid = $a[2];
		my $ref = $a[3];
		my $alt = $a[4];
		my $key = $chr."_".$pos."_".$ref."_".$alt;

		if(exists $hash{$key})
		{
			print $ww "$line\n";
		}
		else{
			print $w "$line\n";
		}
	}	
}
close($rt);
close($w);
close($ww);
