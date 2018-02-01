#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $pileupFile = "";
my $variantFile = "";
my $out = "";
my %ref_in_normal_hash = ();
my %var_in_normal_hash = ();

GetOptions("P=s" => \$pileupFile, "V=s" => \$variantFile, "O=s" => \$out) or die "Error in input arguments\n";

open(my $readp, "<", $pileupFile) or die "Cannot open $pileupFile\n";

while(my $line = <$readp>)
{
	chomp($line);
	if($line !~ /Chr/){
		my @a = split(/\t/, $line);
		my $chr = $a[0];
		my $pos = $a[1];
		my $ref_count = $a[6];
		my $ins_count = $a[7];
		my $del_count = $a[8];
		my $alt_count = $a[9];
		my $ref_fq = $a[10];
		my $ins_fq = $a[11];
		my $del_fq = $a[12];
		my $alt_fq = $a[13];
		my $key = $chr.":".$pos;
		#print "$ref_count\t$ins_count\t$del_count\t$alt_count\n";
		if($ins_fq < 0.01 && $del_fq <0.01 && $alt_fq <0.01 && $ref_count > 0)
		{
			if(exists $var_in_normal_hash{$key})
			{
				print "variant seen in the other normal\n";
			}
			else
			{
				# not in variant table
				if(exists $ref_in_normal_hash{$key}){print "$key\n";}
				else
				{
					$ref_in_normal_hash{$key} = "";
				}
			}
		}
		else
		{
			# fail any of the conditions
			$var_in_normal_hash{$key} = "";
		}
	}
}
close($readp);

open(my $readv, "<", $variantFile) or die "Cannot open $variantFile\n";
open(my $w, ">>", $out) or die "Cannot open $out\n";

while(my $l = <$readv>)
{
	chomp($l);
	if($l =~ /Chr/)
	{
		print $w "$l\n";
	}
	else
	{
		my @b = split(/\t/, $l);
		my $ch = $b[0];
		my $po = $b[1];
		my $k = $ch.":".$po;
		if(exists $ref_in_normal_hash{$k})
		{
			print $w "$l\n";
		}
	}
}
close($w);
close($readv);

