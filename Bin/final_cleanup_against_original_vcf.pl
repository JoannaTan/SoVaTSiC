#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $file="";
my $original_table="";
my %hash = ();

GetOptions("file=s"=>\$file, "ori=s" => \$original_table) or die "Error in input argument\n";
open(my $rf, "<", $original_table) or die "Cannot open $original_table\n";

while(my $l = <$rf>)
{
	chomp($l);
	if($l !~ /CHR/)
	{
		my @table_array= split(/\t/, $l);
		my $ch = $table_array[0];
		my $po = $table_array[1];
		my $ref1 = $table_array[2];
		my $alt1 = $table_array[3];
		my $total_nor_variant_count = $table_array[8];

		my $key = $ch."_".$po."_".$ref1."_".$alt1;
		if($total_nor_variant_count > 0)
		{
			# sites whereby variant is seen in normal cells prior to genotype filtering
			if(exists $hash{$key}){print "ori $key";}
			else
			{
				$hash{$key} = $l;
			}
		}
	}
}
close($rf);

open(my $readfile, "<", $file) or die "Cannot open $file\n";

my $out = $file;
$out =~ s/.txt/.againstoriginal_notinNormal.txt/;
open(my $w, ">>", $out) or die "Cannot write to $out\n";

my $out2 = $file;
$out2 =~ s/.txt/.againstoriginal_appearInNormal.txt/;
open(my $ww, ">>", $out2) or die "Cannot write to $out2\n";

my $outforsamtools = $file;
$outforsamtools =~ s/.txt/_for_samtools.txt/;
open(my $wb, ">>", $outforsamtools) or die "Cannot write to $outforsamtools\n";

while(my $line = <$readfile>)
{
	chomp($line);
	if($line =~ /Chr/)
	{
		print $w "$line\n";;
	}
	else
	{
		my @b = split(/\t/, $line);
		my $chr = $b[0];
		my $pos = $b[1];
		my $ref = $b[3];
		my $alt = $b[4];
		my $k = $chr."_".$pos."_".$ref."_".$alt;
		if(exists $hash{$k})
		{
			#site has variant seen in normal cell prior to filtering
			my $v = $hash{$k};
			print $ww "$line\t$v\n";
		}
		else
		{
			print $w "$line\n";
			print $wb "$chr $pos\n";
		}
	}
}

close($readfile);
close($w);
close($ww);
close($wb);

