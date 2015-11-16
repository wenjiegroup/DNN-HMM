#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;


###<discription>this program merges the reslut of DNN-HMM from 14 sub states to 6 final states


my $state_source=14;
my $state_destination=6;
my $algorithm="DNN_HMM";   #   DNN_HMM  or  DNN   or   Kmeans_GMM_HMM   or   EM_GMM_HMM

my $dir_in_out="Result_of_prediction_bed_$algorithm";
mkdir $dir_in_out unless -e $dir_in_out;

my %maps;
if($state_destination==6)## map 14 sub-states to 6 states
{
	$maps{'E1'}='E1';
	$maps{'E2'}='E1';
	$maps{'E3'}='E1';
	$maps{'E4'}='E2';
	$maps{'E5'}='E2';
	$maps{'E6'}='E2';
	$maps{'E7'}='E3';
	$maps{'E8'}='E3';
	$maps{'E9'}='E3';
	$maps{'E10'}='E4';
	$maps{'E11'}='E4';
	$maps{'E12'}='E4';
	$maps{'E13'}='E5';
	$maps{'E14'}='E6';
}
else
{
	die('wrong number of state!\n');
}



opendir(DIR,$dir_in_out) or die($!);
my @dirs=sort grep { -d "$dir_in_out/$_" && !/^\./ } readdir(DIR);

foreach my $dir(@dirs)
{
	# next unless $dir=~/Bj_Rep1/;
	
	say $dir;

	open(IN,"<","$dir_in_out/$dir/${dir}_${state_source}_segments.bed") or die("$dir_in_out/$dir/${dir}_${state_source}_segments.bed\n$!");
	open(OUT,">","$dir_in_out/$dir/${dir}_${state_destination}_segments.bed");
	my $chr="";
	my $end="";
	my @data;
	while(<IN>)
	{
		my @temp=split;
		
		warn("start should <= end!\n$_") if $temp[1] >= $temp[2];
		if($chr ne $temp[0])
		{
			$chr=$temp[0];
			$end="";
		}
		else
		{
			warn("please check $_\n$end") unless $temp[1] >= $end;
		}
		s/$temp[-1]$/$maps{$temp[-1]}/;
		say $temp[-1] unless defined($maps{$temp[-1]});
		push @data,$_;
		$end=$temp[2];
	}
	my @data_new;
	push @data_new,$data[0];
	foreach my $i(1..$#data)
	{
		my @temp1=split(/\s+/,$data[$i]);
		my @temp2=split(/\s+/,$data_new[-1]);
		if($temp1[0] eq $temp2[0])
		{
			warn("start and end not match!\n") unless $temp1[1]==$temp2[2];
		}
		if($temp1[0] eq $temp2[0] && $temp1[-1] eq $temp2[-1])
		{
			$data_new[-1]="$temp1[0]\t$temp2[1]\t$temp1[2]\t$temp2[-1]\n";
		}
		else
		{
			push @data_new,$data[$i];
		}
	}
	print OUT foreach @data_new;
	
	###MakeBrowserFiles
	# open(OUT,">","colormappingfile$state_destination.txt");
	# if($state_destination==6)
	# {
		# say OUT "1\t255,0,0";
		# say OUT "2\t0,0,255";
		# say OUT "3\t0,102,0";
		# say OUT "4\t0,255,0";
		# say OUT "5\t255,154,0";
		# say OUT "6\t102,102,102";
		
	# }
	# else
	# {
		# die('wrong number of state!\n');
	# }
	
	# my $command="java -jar /public2/home/liufeng/Software/Chromatin_states/ChromHMM/ChromHMM/ChromHMM.jar MakeBrowserFiles -c colormappingfile$state_destination.txt /public2/home/liufeng/Work/Replication_Timing_2013-10/Identification/$dir_in_out/$dir/${dir}_${state_destination}_segments.bed ${dir}_${state_destination}_segments /public2/home/liufeng/Work/Replication_Timing_2013-10/Identification/$dir_in_out/$dir/${dir}_${state_destination}";
	# say "  $command";
	# system($command);
	
}