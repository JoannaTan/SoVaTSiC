#!/usr/bin/perl

# script modified using perl commands given in Perl for Biologists workshop by Robert Bukowski
# use to count mpileup

use strict;
use warnings;
use Getopt::Long;

my $input = "";

GetOptions ("file=s"=>\$input) or die ("Error in command line arguments\n");
open(my $readfile, "<", $input) or die "Cannot open $input\n";

my $outfile=$input.".withcounts";
open(my $w, ">>", $outfile) or die "Cannot write to $outfile\n";

print $w "Chr\tPos\tRef\tCount\tReadsinfo\tQuality\tRef_count\tIns_count\tDel_count\tAlt_count\tRef_freq\tIns_freq\tDel_freq\tAlt_freq\n";

while(my $line=<$readfile>)
{
	chomp($line);
my @string_array = split(/\t/, $line);
	my $dp = $string_array[3];
	if($dp > 0) 
	{
		my $sentence = $string_array[4];
		#print "$sentence\n";
		$sentence =~ s/\$//g;
		$sentence =~ s/\^[\x00-\x7F]//g;
		#print "$sentence\n";
		my $nl = process_deletion($sentence);
		my $nl2 = process_insertion($nl);
		my($ref_count, $ins_count, $del_count, $alt_count)=count_variables($nl2);
		my $ref_freq = $ref_count/$dp;
		my $ins_freq = $ins_count/$dp;
		my $del_freq = $del_count/$dp;
		my $alt_freq = $alt_count/$dp;
		print $w "$line\t$ref_count\t$ins_count\t$del_count\t$alt_count\t$ref_freq\t$ins_freq\t$del_freq\t$alt_freq\n";
	}
}
close($w);
close($readfile);

# functions
sub process_deletion
{
	my $str = shift;
	my @p  = ( $str =~ m/(-[0-9]+[ACGTNacgtn]+)/g );	
	foreach my $j (@p)
	{
		$j =~ /-([0-9]+)/;
		my $length = $1;
		my $r = substr($j,length($1)+1,$length);
		my $pattern = $1.$r;
		$str =~ s/.-$pattern/D/g;
		$str =~ s/,-$pattern/D/g;
		print "DEL:$str\n";
	}
	return($str);
}

sub process_insertion
{
	my $str = shift;
	my @p = ( $str =~ m/(\+[0-9]+[ACGTNacgtn]+)/g );
	foreach my $j (@p)
	{
		print "$j\n";
		$j =~ /\+([0-9]+)/;
		my $length = $1;
		print "$length\n";
		my $r = substr($j,length($1)+1,$length);
		my $pattern = $1.$r;
		$str =~ s/.\+$pattern/I/g;
		$str =~ s/,\+$pattern/I/g;
		print "INS:$str\n";
	}
	return($str);
}

sub count_variables
{
	my $str = shift;
	my $rc = 0;
	my $ac = 0;
	my $ic = 0;
	my $dc = 0;
	my @array = split(//, $str);

	foreach my $a (@array)
	{
		if($a eq "." || $a eq ",")
		{
			$rc++;
		}
		elsif($a eq "I")
		{
			$ic++;
		}
		elsif($a eq "D")
		{
			$dc++;
		}
		else
		{
			$ac++;
		}	
	}
	return($rc,$ic,$dc,$ac);
} 
