#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $bulk_TN_sites = "";
my $sc_file = "";
my $output_prefix = "";
my %bulk_site_hash = ();

GetOptions("B=s" => \$bulk_TN_sites, "SC=s" => \$sc_file ,"o=s" => \$output_prefix) or die "Error in input argument\n";

open(my $readbulk, "<", $bulk_TN_sites) or die "Cannot open $bulk_TN_sites\n";

while(my $bulk_line = <$readbulk>)
{
	chomp($bulk_line);
	if(exists $bulk_site_hash{$bulk_line}){print "repeated $bulk_line";}
	else
	{
		$bulk_site_hash{$bulk_line} = "";
	}	
}

close($readbulk);

# find FP sites
open(my $readsc, "<", $sc_file) or die "Cannot read $sc_file\n";

my @headerarray = ();
my @sc_sample_names_col_array = ();

my $outfile = $output_prefix."_FP_Sites.txt";
open(my $w, ">>", $outfile) or die "Cannot write to $outfile\n";

while(my $sc_line = <$readsc>)
{
	chomp($sc_line);
	if($sc_line =~ /CHROM/)
	{
		#process header line
		print $w "Chr\tPos\tRef\tAlt\tSampleINFOGT\tSampleINFOAD\tSampleINFODP\tSampleINFOGQ\tSampleINFOPL\tGT\tAD\tDP\tGQ\tPL\tVAF\n";
		@headerarray = split(/\t/,$sc_line);
		for(my $i = 0; $i <= $#headerarray; $i++)
		{
			my $header_v = $headerarray[$i];
			if($header_v =~ /.GT$/)
			{
				#print "$header_v\t$i\n";
				push(@sc_sample_names_col_array,$i);
			}
		}
	}
	else
	{
		my @s_array = split(/\t/, $sc_line);
		my $sc_chr = $s_array[0];
		my $sc_pos = $s_array[1];
		my $sc_ref = $s_array[3];
		my $sc_alt = $s_array[4];

		my $hom_ref_geno = $sc_ref."/".$sc_ref;

		my $sc_key = $sc_chr.":".$sc_pos;
		if(exists $bulk_site_hash{$sc_key})
		{
			foreach my $col_id (@sc_sample_names_col_array)
			{
				my $sample_gt = $s_array[$col_id];
				my $sample_ad = $s_array[$col_id+1];
				my $sample_dp = $s_array[$col_id+2];
				my $sample_gq = $s_array[$col_id+3];
				my $sample_pl = $s_array[$col_id+4];
				my $sample_info_gt = $headerarray[$col_id];
				my $sample_info_ad = $headerarray[$col_id+1];
				my $sample_info_dp = $headerarray[$col_id+2];
				my $sample_info_gq = $headerarray[$col_id+3];
				my $sample_info_pl = $headerarray[$col_id+4];
				if($sample_gt ne $hom_ref_geno && $sample_gt ne "./.")
				{
					#likely FP
					if($sample_dp ne "NA" && $sample_dp > 0)
					{
						my ($sample_ref_count, $sample_alt_count) = split(/,/,$sample_ad);
						my $vaf = ($sample_alt_count/$sample_dp);
						print $w "$sc_chr\t$sc_pos\t$sc_ref\t$sc_alt\t$sample_info_gt\t$sample_info_ad\t$sample_info_dp\t$sample_info_gq\t$sample_info_pl\t$sample_gt\t$sample_ad\t$sample_dp\t$sample_gq\t$sample_pl\t$vaf\n";
					}
				}
			}
		}		
	}
}

close($readsc);
close($w);

