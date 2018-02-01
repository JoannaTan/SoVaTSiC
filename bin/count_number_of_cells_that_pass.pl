#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Scalar::Util qw(looks_like_number);

my $DP_threshold = 0;
my $GQ_threshold = 0;
my $VAF_threshold = 0;
my $file = "";
my @sam = ();
my $headerline = "";
my @headerline_array = ();
my $outprefix = "";

GetOptions("f=s"=>\$file, "DP=i"=>\$DP_threshold, "GQ=i"=>\$GQ_threshold, "VAF=f"=> \$VAF_threshold, "o=s"=> \$outprefix) or die "Error in input argument\n";

print "$file\t$DP_threshold\t$GQ_threshold\t$VAF_threshold\n";


open(my $readfile, "<", $file) or die "Cannot open $file\n";

my $out= $outprefix."_clean.txt";
open(my $w, ">>", $out) or die "Cannot open $out\n";

my $outfile = $outprefix.'_sites_het_homalt_that_fail_threshold.txt';
open(my $wr, ">>", $outfile) or die "Cannot open $outfile\n";

my $of = $outprefix.'_sites_homref_that_fail_threshold.txt';
open(my $whr,">>", $of) or die "Cannot open $of\n";

my $ops = $outprefix.'_sites_that_pass_threshold.txt';
open(my $wp, ">>", $ops) or die "Cannot open $ops\n";

my $output_big_file = $outprefix.'_FINAL_ALL_sites_after_cleanup_variants.txt';
open(my $lw, ">>", $output_big_file) or die "Cannot open $output_big_file\n";

while(my $line = <$readfile>)
{
	chomp($line);
	my $number_cells_pass = 0;
	my $number_fail_DP = 0;
	my $number_fail_GQ = 0;
	my $number_fail_VAF = 0;
	my $hom_ref_counts_pass = 0;
	my $het_counts_pass = 0;
	my $hom_alt_count_pass = 0;
	my $no_coverage_count = 0;
	my $can_rescue = 0;
	my $cannot_rescue = 0;

	if($line =~ /CHROM/)
	{
		$headerline = $line;
		my @a = split(/\t/,$line);
		for(my $i=0; $i<=$#a; $i++)
		{
			my $v = $a[$i];
			if($v =~ /.AD$/)
			{
				print "$v\t$i\n";
				push(@sam, $i);
			}
		}
		print $w "$line\tNum_homalt_pass\tNum_het_pass\tNum_hom_ref_pass\tNo_coverage\n";
		print $lw "Chr\tPos\tRSID\tRef\tAlt";

		@headerline_array = split(/\t/,$line);
		# print headerline
		foreach my $kk (@sam)
		{
			my $name = $headerline_array[$kk];
			my ($n, $sp) = split(/\./,$name );
			print $lw "\t$n";
		}
		print $lw "\tHOMALT_PASS\tHET_PASS\tHOMREF_PASS\tNO_COV\n";
	}
	else
	{
		my @line_array = split(/\t/, $line);
		my $chr = $line_array[0];
		my $pos = $line_array[1];
		my $ID = $line_array[2];
		my $ref = $line_array[3];
		my $alt = $line_array[4];
		print $lw "$chr\t$pos\t$ID\t$ref\t$alt";


		foreach my $j (@sam)
		{
			my $gt = $line_array[$j-1];
			my $gt_h = $headerline_array[$j-1];
			my $ad = $line_array[$j];
			my $ad_h = $headerline_array[$j];
			my $dp = $line_array[$j+1];
			my $dp_h = $headerline_array[$j+1];
			my $gq = $line_array[$j+2];
			my $gq_h = $headerline_array[$j+2];
			my $pl = $line_array[$j+3];
			my $pl_h = $headerline_array[$j+3];			

			my ($re, $al) = split(/,/, $ad);
			my $hom_ref_gt = $ref."/".$ref;
			my $het_gt = $ref."/".$alt;
			my $hom_alt_gt = $alt."/".$alt;
			my $vaf = -1;
			
			if(looks_like_number($dp))
			{
				#DP is a number
				if($dp >= 1)
				{
					$vaf = $al/$dp;
				}
			}			
			
			if($gt eq $hom_ref_gt)
			{
				if(looks_like_number($dp) && $dp >= $DP_threshold)
				{
					if($gq >= $GQ_threshold)
					{
						$hom_ref_counts_pass++;
						print $wp "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\t$pl\t0\n";
						print $lw "\t$gt:$ad:$dp:$gq:$re:$al:$vaf:$pl";
					}
					else
					{
						$number_fail_GQ++;
						print $whr "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\t$pl\n";
						print $lw "\tNA";
					}
				}
				else
				{
					$number_fail_DP++;
					print $whr "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\t$pl\n";
					print $lw "\tNA";
				}
				#print "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\n";
			}
			elsif($gt eq $het_gt)
			{
				if(looks_like_number($dp) && $dp >= $DP_threshold)
				{
					if($gq >= $GQ_threshold)
					{
						if($vaf >= $VAF_threshold)
						{
							$het_counts_pass++;
							print $wp "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\t$pl\t1\n";
							print $lw "\t$gt:$ad:$dp:$gq:$re:$al:$vaf:$pl";
						}
						else
						{
							$number_fail_VAF++;
							print $wr "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\t$pl\n";
							print $lw "\tNA";
                                                }
					}
					else
					{
						$number_fail_GQ++;
						my ($pl0, $pl1, $pl2) = split(',', $pl);
						my $diff1 = abs($pl1-$pl2);
						my $diff2 = abs($pl1-$pl0);
						if($diff1 == $gq )
						{
							#rescue them
							if($diff2 >= $GQ_threshold)
							{
								if($vaf >= $VAF_threshold)
								{
									$can_rescue++;
									$het_counts_pass++;
									print $lw "\t$gt:$ad:$dp:$gq:$re:$al:$vaf:$pl";
									print $wp "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\t$pl\t1\n";
								}
								else
								{
									$cannot_rescue++;
									print $wr "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\t$pl\n";
                                                                 	print $lw "\tNA";
								}
							}
							else
							{	
								#unable to rescue
								$cannot_rescue++;
								print $wr "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\t$pl\n";
								 print $lw "\tNA";
							}
						}
						elsif($diff2 == $gq)
						{
							# cnnot differentiate hom-ref from het ==> cannot rescue	
							$cannot_rescue++;
							print $wr "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\t$pl\n";
							print $lw "\tNA";
						}
					}
				}				
				else
				{
					$number_fail_DP++;
					print $wr "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\t$pl\n";
					print $lw "\tNA";
				}


				#print "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\n";
			}
			elsif($gt eq $hom_alt_gt)
			{
				if(looks_like_number($dp) && $dp >= $DP_threshold)
				{
					if($gq >= $GQ_threshold)
					{
						if($vaf >= $VAF_threshold)
						{
							$hom_alt_count_pass++;
							print $wp "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\t$pl\t2\n";
							print $lw "\t$gt:$ad:$dp:$gq:$re:$al:$vaf:$pl";
						}
						else
						{
							$number_fail_VAF++;
							print $wr "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\t$pl\n";
							print $lw "\tNA";
						}
					}
					else
					{
						$number_fail_GQ++;
						my ($ppl0, $ppl1, $ppl2) = split(',',$pl);
						my $d1 = abs($ppl2-$ppl1);
						my $d2 = abs($ppl2-$ppl0);
						if($d1 eq $gq && $d2 >= $GQ_threshold)
						{
							#can rescue
							if($vaf >= $VAF_threshold)
							{
								$can_rescue++;
								$hom_alt_count_pass++;
								print $wp "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\t$pl\t2\n";
								print $lw "\t$gt:$ad:$dp:$gq:$re:$al:$vaf:$pl";
							}
							else
							{
								$cannot_rescue++;
								print $wr "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\t$pl\n";
                                                        	print $lw "\tNA";
							}
						}
						else
						{
							print $wr "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\t$pl\n";
							print $lw "\tNA";
						}
					}
				}
				else
				{
					$number_fail_DP++;
					print $wr "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\t$pl\n";
					print $lw "\tNA";
				}
	
				#print "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\t$pl\n";
			}
			elsif($gt eq "./.")
			{
				# no coverage
				$no_coverage_count++;
				#print "$chr\t$pos\t$ref\t$alt\t$gt_h\t$ad_h\t$dp_h\t$gq_h\t$gt\t$ad\t$dp\t$gq\t$re\t$al\t$vaf\t$pl\n";
				print $lw "\tNA";
			}
		}
		print $lw "\t$hom_alt_count_pass\t$het_counts_pass\t$hom_ref_counts_pass\t$no_coverage_count\n";
		print $w "$line\t$hom_alt_count_pass\t$het_counts_pass\t$hom_ref_counts_pass\t$no_coverage_count\n";
	}	
}

close($readfile);
close($w);
close($wr);
close($whr);
close($wp);
close($lw);
