#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;


###<discription>this program calculates the length and distance of the dead zones labelled as E6 for the following  filtering to get a refined result

my $num_state=6;
my $algorithm="DNN_HMM";   #   DNN_HMM  or  DNN   or   Kmeans_GMM_HMM   or   EM_GMM_HMM
my $dir_in="Result_of_prediction_bed_$algorithm";

my $len=1000;
my $max_num=99999999;

opendir(DIR,$dir_in) or die($!);
my @dirs=sort grep { -d "$dir_in/$_" && !/^\./ } readdir(DIR);

open(OUT,">","$dir_in/E6_data_for_filtering.txt");
foreach my $dir(@dirs)
{
	# next unless $dir=~/Bj_Rep1/;
	
	say $dir;
	
	##
	open(IN,"<","$dir_in/$dir/${dir}_${num_state}_segments.bed") or die($!);
	my $end=-$max_num;
	my $chr="";
	while(<IN>)
	{
		next unless /E6/;
		my @temp=split;
		if($temp[0] ne $chr)
		{
			$chr=$temp[0];
			$end=-$max_num;
		}
		my $d=$temp[1]/$len-$end;
		my $l=$temp[2]/$len-$temp[1]/$len;
		$end=$temp[2]/$len;
		say OUT "$l\t$d";
	}
	

}