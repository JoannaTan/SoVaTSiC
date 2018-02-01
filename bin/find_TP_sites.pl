#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $bulk_sites = "";
my $sc_file = "";
my $output_prefix = "";
my %bulk_site_hash = ();

GetOptions("B=s" => \$bulk_sites, "SC=s" => \$sc_file ,"o=s" => \$output_prefix) or die "Error in input argument\n";

open(my $readbulk, "<", $bulk_sites) or die "Cannot open $bulk_sites\n";

while(my $line = <$readbulk>)
{
	chomp($line);
	if($line !~ /Pos/)
	{
		my @bulk_lines = split(/\t/, $line);
		my $bulk_chr = $bulk_lines[0];
		my $bulk_pos = $bulk_lines[1];
		my $bulk_ref = $bulk_lines[2];
		my $bulk_alt = $bulk_lines[3];
		my $bulk_geno = $bulk_lines[4];
		my $final_geno = "";
		my $bulk_key = $bulk_chr."_".$bulk_pos."_".$bulk_ref."_".$bulk_alt;
		
		#check geno
		if($bulk_geno eq "0/0"){$final_geno = $bulk_ref."/".$bulk_ref;}
		elsif($bulk_geno eq "0/1"){$final_geno = $bulk_ref."/".$bulk_alt;}
		elsif($bulk_geno eq "1/1"){$final_geno = $bulk_alt."/".$bulk_alt;}		

		if(exists $bulk_site_hash{$bulk_key}){print "repeated $bulk_key\n";}
		else
		{
			$bulk_site_hash{$bulk_key} = $final_geno;
		}
	}
}

close($readbulk);

open(my $readsc, "<", $sc_file) or die "Cannot open $sc_file\n";

my $out_TP_file = $output_prefix."_TP_sites.txt";
open(my $w, ">>", $out_TP_file) or die "Cannot write to $out_TP_file\n";

my $out_not_TP_sites = $output_prefix."_NOT_TP_sites.txt";
open(my $ww, ">>", $out_not_TP_sites) or die "Cannot write to $out_not_TP_sites\n";

my @header_array = ();
my @cells_genotype_position_columns = ();

while(my $sc_line = <$readsc>)
{
	chomp($sc_line);
	if($sc_line =~ /CHROM/)
	{
		print $w "Chr\tPos\tRef\tAlt\tSampleGTINFO\tSampleADINFO\tSampleDPINFO\tSampleGQINFO\tSamplePLINFO\tGT\tAD\tDP\tGQ\tPL\tVAF\n";
		print $ww "$sc_line\n";

		@header_array = split(/\t/, $sc_line);
		for(my $i = 0 ; $i<=$#header_array; $i++)
		{
			my $header_v = $header_array[$i];
			if($header_v =~ /.GT$/)
			{	
				#print "$header_v\t$i\n";
				push(@cells_genotype_position_columns, $i);
			}
		}		
	}
	else
	{
		# remaining lines
		my @remain_line_arr = split(/\t/,$sc_line);
		my $sc_chr = $remain_line_arr[0];
		my $sc_pos = $remain_line_arr[1];
		my $sc_ref = $remain_line_arr[3];
		my $sc_alt = $remain_line_arr[4];
		my $sc_key = $sc_chr."_".$sc_pos."_".$sc_ref."_".$sc_alt;
		if(exists $bulk_site_hash{$sc_key})		
		{
			# site is found in bulk
			my $bulk_genotype_for_comparison = $bulk_site_hash{$sc_key};

			foreach my $col_id (@cells_genotype_position_columns)
			{
				my $sample_gt = $remain_line_arr[$col_id];
				my $sample_ad = $remain_line_arr[$col_id+1];
				my $sample_dp = $remain_line_arr[$col_id+2];
				my $sample_gq = $remain_line_arr[$col_id+3];
				my $sample_pl = $remain_line_arr[$col_id+4];
				my $header_gt_info = $header_array[$col_id];
				my $header_ad_info = $header_array[$col_id+1];
				my $header_dp_info = $header_array[$col_id+2];
				my $header_gq_info = $header_array[$col_id+3];
				my $header_pl_info = $header_array[$col_id+4];		
				if($sample_gt eq $bulk_genotype_for_comparison)
				{
					#keep those that got same geno at the same position
					my ($sample_ref_count, $sample_alt_count) = split(/,/,$sample_ad);
					if($sample_dp ne "NA" && $sample_dp > 0)
					{
						my $vaf = ($sample_alt_count/$sample_dp);
						print $w "$sc_chr\t$sc_pos\t$sc_ref\t$sc_alt\t$header_gt_info\t$header_ad_info\t$header_dp_info\t$header_gq_info\t$header_pl_info\t$sample_gt\t$sample_ad\t$sample_dp\t$sample_gq\t$sample_pl\t$vaf\n";
					}
				}	
			}
		}
		else
		{
			# sites that were not found in bulk
			print $ww "$sc_line\n";
		}		

	}
}
close($readsc);
close($w);
close($ww);
