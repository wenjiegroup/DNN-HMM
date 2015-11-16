#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;

###<discription>this program extracts data and labels of training and test sets annotated manually.
##Because the training and test set are annotated on Replicate1 of Bj cells, you need first run the previous scripts to prepare well data of Bj Rep1.

my $num_state=14;
my $bin_size=1000;
my $dir_in='./Manual_annotation/Bj_Rep1';
my $dir_in2='./Custom_Signal/merged/Bj_Rep1';
my $dir_out="Data_for_training_tesing_and_prediction";
mkdir $dir_out unless -e $dir_out;


foreach my $flag('training_set','test_set')  #  test_set  or  training_set
{
	say "prepare $flag";
	my $dir_out.="$dir_out/$flag";
	mkdir $dir_out unless -e $dir_out;
	
	foreach my $i(1..23)
	{
		# next unless $i==1 || $i==3 || $i==4 || $i==10 || $i==14 || $i==17;  
		
		my $chr="chr$i";
		$chr="chrX" if $i==23;
		
		open(IN2,"<","$dir_in2/Bj-Rep1-${chr}_signal.merged") or die("open $dir_in2/Bj-Rep1-${chr}_signal.merged error!\nrun the previous scripts to get necessary inputs of Bj cell Replicate 1\n$!");
		
		
		my @temp=split(/\s+/,<IN2>);
		die('chr name not match!!!\n') unless $temp[-1] eq $chr;
		$_=<IN2>;
		s/[\n\r]+$//;
		die('six phases order not match!!!\n') unless $_ eq "G1	S1	S2	S3	S4	G2";
		my @data;
		push @data,$_ while <IN2>;
		
		open(IN,"<","$dir_in/Bj_Rep1_${num_state}_${flag}_segments.bed") or die($!);
		
		# my @data;
		# my %state;
		my $flag=0;
		my $seq=1;
		my $pre=-1;
		while(<IN>)
		{
			last if !/^$chr\t/ && $flag==1;
			next unless /^$chr\t/;
			$flag=1 unless $flag;
			my @temp=split;
			$temp[-1]=~s/^E//;
			if($pre!=$temp[1])
			{
				open(OUT,">","$dir_out/y_${chr}_seq$seq.matrix");
				open(OUT2,">","$dir_out/x_${chr}_seq$seq.matrix");
				$seq++;
			}
			for(my $i=$temp[1]/$bin_size;$i<$temp[2]/$bin_size;$i++)
			{
				say OUT $temp[3];
				print OUT2 $data[$i];
				# push @data,$temp[3];
				# $state{$temp[3]}++;
			}
			$pre=$temp[2];
		}

		# my $i=1;
		# $state{$_}=$i++ foreach sort keys %state;
		# say OUT $state{$_} foreach @data;
		#say OUT ("0\t" x ($state{$_}-1))."1".("\t0" x ((keys %state)-$state{$_})) foreach @data;
	}
}