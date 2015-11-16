#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;

###<discription> This program transforms the .wig data to the format of signal. Here we just gets the decomposed data;in the next program we merge the six cell cycle phase


my $dir_in="UW_Repli-seq_data";
my $dir_out="Custom_Signal";
mkdir $dir_out unless -e $dir_out;
$dir_out="Custom_Signal/decomposed";
mkdir $dir_out unless -e $dir_out;

open(IN,"<","./hg19.txt");
my %size_of_hg19;
$size_of_hg19{ (split)[0] }=(split)[1] while <IN>;

opendir(DIR,$dir_in) or die($!);
my @files=sort grep { /PctSignalRep/ && /\.wig$/ } readdir(DIR);

say "You first need download the '.bigWig' files of six cell cycle fractions (G1/G1b, S1, S2, S3, S4, G2) from ENCODE and transform them from .bigWig format into .wig format.\nDetail see UW_Repli-seq_data\/readme.txt" unless @files;

foreach my $file(@files)
{
	say $file;
	
	my ($cell,$phase,$rep)= ( $file=~/wgEncodeUwRepliSeq(\w+)([SG]\w+)PctSignal(\w+)\.wig$/ );
	$phase=~s/b//;
	open(IN,"<","$dir_in/$file") or die($!);
	
	my %count_of_chr_location;
	my $chr="";
	my %list_of_chr;
	while(<IN>)
	{
		my @temp=split;
		if(@temp==3)
		{
			$chr=(split(/=/,$temp[1]))[1];
			$list_of_chr{$chr}++;
		}
		elsif(@temp==2)
		{
			$count_of_chr_location{"$chr\t$temp[0]"}=$temp[1];
		}
		else
		{
			die("the content of line is not correct!");
		}
	}
	
	my $dir_out="$dir_out/${cell}_$rep";
	mkdir $dir_out unless -e $dir_out;
	foreach my $chr(sort keys %list_of_chr)
	{
		say $chr;
		open(OUT,">","$dir_out/$cell-$rep-$chr-$phase.decomposed.signal");
		for(my $i=500;$i+1000<=$size_of_hg19{$chr};$i=$i+1000)
		{
			$count_of_chr_location{"$chr\t$i"}=0 unless defined( $count_of_chr_location{"$chr\t$i"} );
			say OUT $count_of_chr_location{"$chr\t$i"};
		}
	}
	
}

