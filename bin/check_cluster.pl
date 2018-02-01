#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Switch;

my $in = "";
my $out = "";

GetOptions("i=s"=>\$in ,"o=s" => \$out) or die "Error in input argument\n";

my $prev_chr = 0;
my $prev_pos = 0;
my @array = ();

open(my $r, "<", $in) or die "Cannot open $in\n";
open(my $w, ">>", $out) or die "Cannot write to $out\n";

while(my $line = <$r>)
{
	chomp($line);
	if($line =~ /CHROM/){print $w "$line\n";}
	else{
		my @a = split(/\t/,$line);
		my $curr_chr = $a[0];
		my $curr_pos = $a[1];
	
		if($curr_chr eq "MT"){$curr_chr = 25;}
		elsif($curr_chr eq "X"){$curr_chr = 23;}
		elsif($curr_chr eq "Y"){$curr_chr = 24;}
	
		if($curr_chr != $prev_chr)
		{
			#print "$prev_chr\t$curr_chr\t";
			#print scalar @array;
			#print "\t";

			#process the current array and set everything to null
			for(my $i = 0; $i<= $#array; $i++)
			{
				my $l = $array[$i];
				my @b = split(/\t/,$l);
				my $chr = $b[0];
				my $pos = $b[1];
				my $diff_b = 0;
				my $diff_a = 0;

				if($i == 0 && $i == $#array)
				{
					#only 1 element
					print $w "$l\n";
				}
				elsif($i != 0 && $i != $#array)	
				{
					#as long not the first or last
					my $prev_line = $array[$i-1];
					my @prev_a = split(/\t/, $prev_line);
					my $p_chr = $prev_a[0];
					my $p_pos = $prev_a[1];
					$diff_b = ($pos - $p_pos);
	
					my $next_line = $array[$i+1];
					my @next_a = split(/\t/, $next_line);
					my $n_chr = $next_a[0];
					my $n_pos = $next_a[1];
					$diff_a = ($n_pos - $pos);
					
					if($diff_a > 10 && $diff_b > 10)
					{
						print $w "$l\n";
					}
				}		
				elsif($i==0)
				{
					my $next_line1 = $array[$i+1];
					my @next_arr = split(/\t/, $next_line1);
					my $nxt_chr = $next_arr[0];
					my $nxt_pos = $next_arr[1];
					$diff_a = ($nxt_pos - $pos);
					if($diff_a > 10)
					{
						print $w "$l\n";
					}
				}
				elsif($i == $#array)
				{
					my $prev_line1 = $array[$i-1];
					my @prev_arr = split(/\t/, $prev_line1);
					my $prev_chr = $prev_arr[0];
					my $prev_pos = $prev_arr[1];
					$diff_b = ($pos - $prev_pos);
					if($diff_b > 10)
					{
						print $w "$l\n";
					}
				}
					
			}

			@array = ();
			#print scalar @array;
			#print "\t";
			push(@array, $line);
			#print scalar @array;
			#print "\n";		
		}
		else
		{
			push(@array, $line);
		}
		$prev_chr = $curr_chr;
		$prev_pos = $curr_pos
	}
}


##print the last chromosome
for(my $j=0; $j <=$#array; $j++)
{
	my $c_line = $array[$j];
	my @c_array = split(/\t/, $c_line);
	my $c_chr = $c_array[0];
	my $c_pos = $c_array[1];
	my $diff_b1 = 0;
	my $diff_a1 = 0;

	if($j == 0 && $j == $#array)
	{
		#only 1 pos
		print $w "$c_line\n";
	}
	elsif($j != 0 && $j != $#array)
	{
		my $pre_line = $array[$j-1];
		my @pre_array = split(/\t/, $pre_line);
		my $pre_chr = $pre_array[0];
		my $pre_pos = $pre_array[1];
		
		my $nxt_line = $array[$j+1];
		my @nxt_array = split(/\t/, $nxt_line);
		my $nxt_chr = $nxt_array[0];
		my $nxt_pos = $nxt_array[1];

		$diff_b1 = ($c_pos - $pre_pos);
		$diff_a1 = ($nxt_pos - $c_pos);
		if($diff_b1 > 10 && $diff_a1 > 10)
		{
			print $w "$c_line\n";
		}
	}
	elsif($j == 0)
	{
		my $nxl = $array[$j+1];
		my @nxl_array = split(/\t/, $nxl);
		my $nxl_chr = $nxl_array[0];
		my $nxl_pos = $nxl_array[1];
		$diff_a1 = ($nxl_pos - $c_pos);
		if($diff_a1 > 10)
		{
			print $w "$c_line\n";
		}
	}
	elsif($j == $#array)
	{
		my $prel = $array[$j-1];
		my @prel_array = split(/\t/, $prel);
		my $prel_chr = $prel_array[0];
		my $prel_pos = $prel_array[1];
		$diff_b1 = ($c_pos - $prel_pos);
		if($diff_b1 > 10)
		{
			print $w "$c_line\n";
		}

	}

}

close($r);
close($w);
