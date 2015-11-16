#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;


###<discription>this program filters the dead zones according to the previously calculated threshold to get a refined result

my $state_source=6;
my $state_destination=7;

my $algorithm="DNN_HMM";   #   DNN_HMM  or  DNN   or   Kmeans_GMM_HMM   or   EM_GMM_HMM
my $dir_in="Result_of_prediction_bed_$algorithm";
my $len=1000;
my $max_num=99999999;

open(IN,"<","$dir_in/E6_threshold_for_filtering.txt") or die($!);
$_=<IN>;
my ($thre_len,$thre_dis)=split;
say "The threshold of the length and the distance of E6 is $thre_len kb, $thre_dis kb respectively";


opendir(DIR,$dir_in) or die($!);
my @dirs=sort grep { -d "$dir_in/$_" && !/^\./ } readdir(DIR);
foreach my $dir(@dirs)
{
	# next unless $dir=~/Bj_Rep1/;
	
	say $dir;
	
	
	## filter E6
	open(IN,"<","$dir_in/$dir/${dir}_${state_source}_segments.bed") or die($!);
	open(OUT,">","$dir_in/$dir/${dir}_${state_destination}_segments.bed");
	my $end=-$max_num*$len;
	my $chr="";
	my @data;
	while(<IN>)
	{
		my @temp=split;
		if($temp[0] ne $chr)
		{
			$chr=$temp[0];
			$end=-$max_num*$len;
			@data=();
		}
		
		if(/E6/)
		{
			my $d=$temp[1]-$end;
			my $l=$temp[2]-$temp[1];
			$end=$temp[2];
			if($d<$thre_dis*$len && $l<$thre_len*$len)
			{
				@data=( "$chr\t".(split(/\s+/,$data[0]))[1]."\t$end\tE7\n" );
			}
			elsif($l>=$thre_len*$len)
			{
				# if(defined($data[0]))
				# {
					# print OUT foreach @data;
				# }
				# @data=();
				push @data,$_;
				$end=-$max_num*$len;
			}
			else
			{
				# if(defined($data[0]))
				{
					print OUT foreach @data;
				}
				@data=();
				push @data,$_;
			}
			
		}
		else
		{
			push @data,$_;
		}
	}
	
	
	###MakeBrowserFiles
	# open(OUT,">","colormappingfile$state_destination.txt");
	# if($state_destination==7)
	# {
		# say OUT "1\t255,0,0";
		# say OUT "2\t0,0,255";
		# say OUT "3\t0,102,0";
		# say OUT "4\t0,255,0";
		# say OUT "5\t255,154,0";
		# say OUT "6\t102,102,102";
		# say OUT "7\t0,0,0";
		
	# }
	# else
	# {
		# die('wrong number of state!\n');
	# }
	
	# my $command="java -jar /public2/home/liufeng/Software/Chromatin_states/ChromHMM/ChromHMM/ChromHMM.jar MakeBrowserFiles -c colormappingfile$state_destination.txt /public2/home/liufeng/Work/Replication_Timing_2013-10/Identification/$dir_in/$dir/${dir}_${state_destination}_segments.bed ${dir}_${state_destination}_segments /public2/home/liufeng/Work/Replication_Timing_2013-10/Identification/$dir_in/$dir/${dir}_${state_destination}";
	# say "  $command";
	# system($command);

}