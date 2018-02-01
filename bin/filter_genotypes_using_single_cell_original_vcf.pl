#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $file="";
my $original_table="";
my $tut_p = "";
my $nor_p = "";
my @normal_column = ();
my @tumour_column = ();

GetOptions("file=s"=>\$file, "Tpattern=s" => \$tut_p, "Npattern=s" => \$nor_p) or die "Error in input argument\n";
open(my $readfile, "<", $file) or die "Cannot open $file\n";

my $out = $file;
$out =~ s/.table/.preprocess/;
open(my $w, ">>", $out) or die "Cannot write to $out\n";

while(my $line = <$readfile>)
{
	chomp($line);
	if($line =~ /CHROM/)
	{
		#header line
		print $w "CHR\tPOS\tREF\tALT\tNOR_HOMREF_COUNT\tNOR_HET_COUNT\tNOR_HOMALT_COUNT\tNORMAL_NO_GENO\tTOTAL_NORMAL_VARIANT_COUNT\tTUMOUR_HOMREFF_COUNT\tTUMOUR_HET_COUNT\tTUMOUR_HOMALT_COUNT\tTUMOUR_NO_GENO_COUNT\tTOTAL_TUMOUR_VARIANT_COUNT\n";

		my @header_array = split(/\t/, $line);
		for(my $i = 0; $i <= $#header_array; $i++)
		{
			my $header_v = $header_array[$i];
			if($header_v =~ /.GT$/)
			{
				if($header_v =~ /$tut_p/)
				{
					#print "$header_v\n";
					push(@tumour_column, $i);
				}
				elsif($header_v =~ /$nor_p/)
				{
					print "$header_v\n";
					push(@normal_column, $i);	
				}
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
		print $w "$chr\t$pos\t$ref\t$alt\t$nor_homr_c\t$nor_het_c\t$nor_homa_c\t$nor_no_geno\t$total_nor_variant_count\t$tum_homr_c\t$tum_het_c\t$tum_homa_c\t$tum_no_geno\t$total_tum_variant_count\n";
	}
}

close($w);
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
		my $geno = $arr_b[$v];
		if($geno eq $rg){$count_homref++;}
		elsif($geno eq $hg){$count_het++;}
		elsif($geno eq $ag){$count_homalt++;}
		elsif($geno eq "./."){$count_no_geno++;}
	}
	$total = $count_het+$count_homalt;
	return($count_homref, $count_het, $count_homalt, $count_no_geno ,$total);

}

