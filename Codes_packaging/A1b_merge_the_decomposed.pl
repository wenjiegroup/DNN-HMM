#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;

###<discription>we merge the six cell cycle phases to get the format of signal

my $dir_in="Custom_Signal/decomposed";
my $dir_out="Custom_Signal/merged";
mkdir $dir_out unless -e $dir_out;

opendir(DIR,$dir_in) or die($!);
my @dirs=sort grep { -d "$dir_in/$_" && !/^\./ } readdir(DIR);

foreach my $dir(@dirs)
{
	say $dir;
	my ($cell,$rep)=split(/_/,$dir);
	my $dir_out="$dir_out/$dir";
	mkdir $dir_out unless -e $dir_out;
	
	opendir(DIR,"$dir_in/$dir") or die($!);
	my @chr_files=sort grep { /-G1\.decomposed\.signal$/ } readdir(DIR);
	foreach my $chr_file(@chr_files)
	{
		my @data;
		my $chr=(split(/-/,$chr_file))[2];
		say "  $chr";
		foreach my $phase("G1","S1","S2","S3","S4","G2")
		{
			open(IN,"<","$dir_in/$dir/$cell-$rep-$chr-$phase.decomposed.signal") or die($!);
			my $i=0;
			while(<IN>)
			{
				$data[$i].=(split)[0]."\t";
				$i++;
			}
		}
		open(OUT,">","$dir_out/$cell-$rep-${chr}_signal.merged");
		say OUT "${cell}_$rep\t$chr";
		say OUT "G1\tS1\tS2\tS3\tS4\tG2";
		foreach (@data)
		{
			s/\t$//;
			say OUT;
		}
	}
}