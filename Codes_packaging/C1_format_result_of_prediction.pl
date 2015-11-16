#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use File::Copy;

###<discription>this program gets the segmentations in the '.bed' format as the '_segments.bed' files 

my $num_state=14;
my $len=1000;
my $algorithm="DNN_HMM";   #   DNN_HMM  or  DNN   or   Kmeans_GMM_HMM   or   EM_GMM_HMM

my $dir_in="Result_of_prediction";
my $dir_out="Result_of_prediction_bed_$algorithm";
mkdir $dir_out unless -e $dir_out;

opendir(DIR,$dir_in) or die($!);
my @dirs=sort grep { -d "$dir_in/$_" && !/^\./ } readdir(DIR);

foreach my $dir(@dirs)
{
	# next unless $dir=~/Bj_Rep/;
	
	say $dir;
	
	my $dir_out="$dir_out/$dir";
	mkdir $dir_out unless -e $dir_out;
	open(OUT,">","$dir_out/${dir}_${num_state}_segments.bed");
	foreach my $i(1..23)
	{
		my $chr="chr$i";
		open(IN1,"<","$dir_in/$dir/${dir}_labelled_state_of_".$algorithm."_$chr.txt") or die($!);
		$chr="chrX" if $i==23;
		# next unless $chr eq "chr1";
		
		my $pre_state='';
		my $count=0;
		my ($start,$end)=(0,0);
		while( defined(my $line1=<IN1> ) )   #gets the refined segmentations
		{
			my @temp1=split(/\s+/,$line1);
			die("a row of new state contains more than 1 state!\n") unless @temp1==1;
			if($temp1[0] ne $pre_state)
			{
				say OUT "$chr\t$start\t$end\tE$pre_state" if $end;
				$start=$end;
			}
			$end=($count+1)*$len;
			
			
			$count++;
			$pre_state=$temp1[0];
		}
		say OUT "$chr\t$start\t$end\tE$pre_state" if $end;
	}
	###MakeBrowserFiles
	
	# my $command="java -jar /public2/home/liufeng/Software/Chromatin_states/ChromHMM/ChromHMM/ChromHMM.jar MakeBrowserFiles -c colormappingfile$num_state.txt /public2/home/liufeng/Work/Replication_Timing_2013-10/Identification/$dir_out/${dir}_${num_state}_segments.bed ${dir}_${num_state} /public2/home/liufeng/Work/Replication_Timing_2013-10/Identification/$dir_out/${dir}_${num_state}";
	# say "  $command";
	# system($command);
	
}
