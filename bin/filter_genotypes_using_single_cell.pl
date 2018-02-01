#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $file="";
my $nor_p = "";
my $tum_p = "";

GetOptions("file=s"=>\$file, "Tpattern=s" =>\$tum_p, "Npattern=s" => \$nor_p) or die "Error in input argument\n";
open(my $readfile, "<", $file) or die "Cannot open $file\n";

my $outfile = $file;
$outfile =~ s/.txt/_rm_germline_sc_3normal.txt/;
open(my $w, ">>", $outfile) or die "Cannot open $outfile\n";

my $out2 = $file;
$out2 =~ s/.txt/_in_germline_sc_3normal.txt/; 
open(my $ww, ">>", $out2) or die "Cannot open $out2\n";

my @tumour_column = ();
my @normal_column = ();

while(my $line = <$readfile>)
{
	chomp($line);
	if($line =~ /Pos/)
	{
		#headerline
		print $w "$line\n";
		print $ww "$line\n";
		my @header_array = split(/\t/, $line);
		for(my $i = 0; $i <= $#header_array; $i++)
		{
			my $header_v = $header_array[$i];
			if($header_v =~ /$nor_p/)
			{
				#print "$header_v\n";
				push(@normal_column, $i);
			}
			elsif($header_v =~ /$tum_p/)
			{
				push(@tumour_column, $i);
			}
		}
		
	}
	else
	{
		my @b = split(/\t/, $line);
		my $chr = $b[0];
		my $pos = $b[1];
		my $ref = $b[3];
		my $alt = $b[4];
		my $ref_geno = $ref."/".$ref;
		my $het_geno = $ref."/".$alt;
		my $alt_geno = $alt."/".$alt;	
		my ($nor_homr_c, $nor_het_c, $nor_homa_c, $nor_no_geno,$total_nor_variant_count) =count_number_of_variant_cells(\@normal_column, $ref_geno, $het_geno, $alt_geno, \@b);
		my ($tum_homr_c, $tum_het_c, $tum_homa_c, $tum_no_geno,$total_tum_variant_count) = count_number_of_variant_cells(\@tumour_column, $ref_geno, $het_geno, $alt_geno, \@b);
		if($total_nor_variant_count == 0 && $nor_homr_c >= 3)	
		{
			print $w "$line\n";
		}
		else
		{
			print $ww "$line\n";
		}
	}
}

close($w);
close($ww);
close($readfile);

#functions
sub count_number_of_variant_cells
{
	my ($col_info, $rg, $hg, $ag, $arb) = @_;
	my @col_array = @{$col_info};
	my @arr_b = @{$arb};
	my $count_het = 0;
	my $count_homref = 0;
	my $count_homalt = 0;
	my $count_no_geno =0;
	my $total = 0;

	foreach my $v (@col_array)
	{
		my $geno1 = $arr_b[$v];
		my ($geno, $ad, $dp,$gq,$re,$al,$vaf) = split(/:/,$geno1);
		if($geno eq $rg){$count_homref++;}
		elsif($geno eq $hg){$count_het++;}
		elsif($geno eq $ag){$count_homalt++;}
		elsif($geno eq "NA"){$count_no_geno++;}
	}
	$total = $count_het+$count_homalt;
	return($count_homref, $count_het, $count_homalt, $count_no_geno ,$total);

}

