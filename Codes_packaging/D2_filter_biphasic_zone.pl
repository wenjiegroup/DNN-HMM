#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;


###<discription>this program calculates the length of the biphasic zones labelled as E5 for the following  filtering to get a refined result

my $state_source=7;
my $state_destination=7;

my $algorithm="DNN_HMM";   #   DNN_HMM  or  DNN   or   Kmeans_GMM_HMM   or   EM_GMM_HMM
my $dir_in="Result_of_prediction_bed_$algorithm";
my $len=1000;

my $thre_len=150_000;  ## we want to find a threshold automatically just as the dead zones in the process of filtering E6, but the result is satisfacory. So we  set the threshold manually. We find that 15000 bp is a fine threshold
my $label_refined="E5";

opendir(DIR,$dir_in) or die($!);
my @dirs=sort grep { -d "$dir_in/$_" && !/^\./ } readdir(DIR);
foreach my $dir(@dirs)
{
	# next unless $dir=~/Bj_Rep1/;
	
	say $dir;
	
	
	## filter E5
	open(IN,"<","$dir_in/$dir/${dir}_${state_source}_segments.bed") or die($!);
	open(OUT,">","$dir_in/$dir/${dir}_${state_destination}_${label_refined}_refined_segments.bed");
	my $chr="";
	my @data;
	while(<IN>)
	{
		s/[\r\n]+$//;
		my @temp=split;
		if($temp[0] ne $chr)
		{
			$chr=$temp[0];
			if(@data)
			{
				foreach my $i(0..$#data)
				{
					if($data[$i]=~/$label_refined/)
					{
						my @temp=split(/\s+/,$data[$i]);
						if($temp[2]-$temp[1]<$thre_len)
						{
							if($i<$#data && $i>0 && (split(/\s+/,$data[$i-1]))[-1] eq (split(/\s+/,$data[$i+1]))[-1])
							{
								my $label_next=(split(/\s+/,$data[$i+1]))[-1];
								$data[$i]=~s/$label_refined/$label_next/ ;
							}
							else
							{
								$data[$i]=~s/$label_refined/E7/ ;
							}
						}
					}
				}
				my @data_merged;
				push @data_merged,shift(@data);
				while(@data)
				{
					my $zone1=pop(@data_merged);
					my $zone2=shift(@data);
					my @temp1=split(/\s+/,$zone1);
					my @temp2=split(/\s+/,$zone2);
					if($temp1[0] eq $temp2[0] && $temp1[-1] eq $temp2[-1] && $temp1[2] eq $temp2[1])
					{
						push @data_merged,"$temp1[0]\t$temp1[1]\t$temp2[2]\t$temp1[-1]";
					}
					else
					{
						push @data_merged,$zone1;
						push @data_merged,$zone2;
					}
					
				}
				say OUT foreach @data_merged;
				
			}
			@data=();
		}
		
		push @data,$_;
	}
	foreach my $i(0..$#data)
	{
		if($data[$i]=~/$label_refined/)
		{
			my @temp=split(/\s+/,$data[$i]);
			if($temp[2]-$temp[1]<$thre_len)
			{
				if($i<$#data && $i>0 && (split(/\s+/,$data[$i-1]))[-1] eq (split(/\s+/,$data[$i+1]))[-1])
				{
					my $label_next=(split(/\s+/,$data[$i+1]))[-1];
					$data[$i]=~s/$label_refined/$label_next/ ;
				}
				else
				{
					$data[$i]=~s/$label_refined/E7/ ;
				}
			}
		}
	}
	my @data_merged;
	push @data_merged,shift(@data);
	while(@data)
	{
		my $zone1=pop(@data_merged);
		my $zone2=shift(@data);
		my @temp1=split(/\s+/,$zone1);
		my @temp2=split(/\s+/,$zone2);
		if($temp1[0] eq $temp2[0] && $temp1[-1] eq $temp2[-1] && $temp1[2] eq $temp2[1])
		{
			push @data_merged,"$temp1[0]\t$temp1[1]\t$temp2[2]\t$temp1[-1]";
		}
		else
		{
			push @data_merged,$zone1;
			push @data_merged,$zone2;
		}
		
	}
	say OUT foreach @data_merged;
	
	
	
	###MakeBrowserFiles
	
	# my $command="java -jar /public2/home/liufeng/Software/Chromatin_states/ChromHMM/ChromHMM/ChromHMM.jar MakeBrowserFiles -c colormappingfile$state_destination.txt /public2/home/liufeng/Work/Replication_Timing_2013-10/Identification/$dir_in/$dir/${dir}_${state_destination}_${label_refined}_refined_segments.bed ${dir}_${state_destination}_${label_refined}_refined_segments /public2/home/liufeng/Work/Replication_Timing_2013-10/Identification/$dir_in/$dir/${dir}_${state_destination}_${label_refined}_refined";
	# say "  $command";
	# system($command);

}