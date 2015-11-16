#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;

###<discription>this program extracts data of unlabelled sets.

my $dir_in='./Custom_Signal/merged';
my $dir_out="Data_for_training_tesing_and_prediction/unlabelled_set";
mkdir $dir_out unless -e $dir_out;

opendir(DIR,$dir_in) or die($!);
my @subdirs=sort grep { -d "$dir_in/$_" && !/^\./} readdir(DIR);

foreach my $dir(@subdirs)
{ 
	
	say $dir;
	my $dir_in="$dir_in/$dir";
	my $dir_out="$dir_out/$dir";
	mkdir $dir_out unless -e $dir_out;
	foreach my $i(1..23)
	{
		
		my $chr="chr$i";
		$chr="chrX" if $i==23;
		my $name=$dir;
		$name=~s/_/-/;
		open(IN,"<","$dir_in/$name-${chr}_signal.merged") or die("$dir_in/$name-${chr}_signal.merged\n$!");
		open(OUT,">","$dir_out/x_$chr.matrix");
		
		my @temp=split(/\s+/,<IN>);
		die('chr name not match!!!\n') unless $temp[-1] eq $chr;
		$_=<IN>;
		s/[\n\r]+$//;
		die('six phases order not match!!!\n') unless $_ eq "G1	S1	S2	S3	S4	G2";
		print OUT while <IN>;
	}
}