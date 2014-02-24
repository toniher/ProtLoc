#!/usr/bin/env perl

#use strict;

use Math::MatrixReal;
use Bio::SeqIO;

my $file = shift;


my $seqio = Bio::SeqIO->new(-file => $file, '-format' => 'Fasta');
while(my $seq = $seqio->next_seq) {
	my $string = $seq->seq;
	my $id = $seq->id;

	my $outcome = process( $string );
	print $id."\t".join("\t", @{$outcome});

}


sub process {

	my $seqstring = shift;

	$seqstring=~s/\s*//g;
	chomp($seqstring);

	@seqarray=split("", $seqstring);

	@seqdis = split(//,$seqstring);

	#Fill row of prot with zeroes
	for (my $i=0; $i<21; $i++) { 

		$matrix[$i]=0;

	}

	for (my $i=0; $i<$#seqarray + 1; $i++) {

		&freq($seqarray[$i]);

	}

	#Function assign freqs
	sub freq { 

		my $in= $_[0];

		if ($in=~/A/i) {$matrix[0]++;}
		if ($in=~/C/i) {$matrix[1]++;}
		if ($in=~/D/i) {$matrix[2]++;}
		if ($in=~/E/i) {$matrix[3]++;}
		if ($in=~/F/i) {$matrix[4]++;}
		if ($in=~/G/i) {$matrix[5]++;}
		if ($in=~/H/i) {$matrix[6]++;}
		if ($in=~/I/i) {$matrix[7]++;}
		if ($in=~/K/i) {$matrix[8]++;}
		if ($in=~/L/i) {$matrix[9]++;}
		if ($in=~/M/i) {$matrix[10]++;}
		if ($in=~/N/i) {$matrix[11]++;}
		if ($in=~/P/i) {$matrix[12]++;}
		if ($in=~/Q/i) {$matrix[13]++;}
		if ($in=~/R/i) {$matrix[14]++;}
		if ($in=~/S/i) {$matrix[15]++;}
		if ($in=~/T/i) {$matrix[16]++;}
		if ($in=~/V/i) {$matrix[17]++;}
		if ($in=~/W/i) {$matrix[18]++;}
		if ($in=~/Y/i) {$matrix[19]++;}
	
		$matrix[20]++;

	}

	for ($j=0; $j<21; $j++) {
	$freqmatrix[$j]=($matrix[$j])/$matrix[20];
	}

	for ($k=0; $k<20; $k++) {
	$stringx.="\[\t$freqmatrix[$k]\t\]\n";
	}

	open (VAR, "var/var-0freq") || die "cannot open Variances"; #Matrix of protein variances

	while (<VAR>) {
		$vartext.=$_;
	}
	close (VAR);


	open (INTRA, "avg/avg-1freq") || die "cannot open Intra"; #Average of intra group

	while (<INTRA>) {
		$intratext.=$_;
	}
	close (INTRA);

	open (EXTRA, "avg/avg-2freq") || die "cannot open Extra"; #Average of extra group

	while (<EXTRA>) {
		$extratext.=$_;
	}
	close (EXTRA);

	open (ANCH, "avg/avg-3freq") || die "cannot open Anch"; #Average of anch group

	while (<ANCH>) {
		$anchtext.=$_;
	}
	close (ANCH);

	open (MEM, "avg/avg-4freq") || die "cannot open Mem"; #Average of mem group

	while (<MEM>) {
		$memtext.=$_;
	}
	close (MEM);

	open (NUCL, "avg/avg-5freq") || die "cannot open Nucl"; #Average of nucl group

	while (<NUCL>) {
		$nucltext.=$_;
	}
	close (NUCL);


	$varmatrix= Math::MatrixReal->new_from_string($vartext); #Varmatrix to mem
	$smatrix = $varmatrix->inverse(); #Make inverse

	$x_col= Math::MatrixReal -> new_from_string($stringx); #Prot row freq to mem

	#Matrices of averages
	$intracol= Math::MatrixReal->new_from_string($intratext);  
	$extracol= Math::MatrixReal->new_from_string($extratext);
	$anchcol= Math::MatrixReal->new_from_string($anchtext);
	$memcol= Math::MatrixReal->new_from_string($memtext);
	$nuclcol= Math::MatrixReal->new_from_string($nucltext);

	#Substracted to prot col
	$x_intra_col = $x_col - $intracol;
	$x_extra_col = $x_col - $extracol;
	$x_anch_col = $x_col - $anchcol;
	$x_mem_col = $x_col - $memcol;
	$x_nucl_col = $x_col - $nuclcol;

	#Make row for transpose
	$x_intra_row = new Math::MatrixReal (1, 20);
	$x_extra_row = new Math::MatrixReal (1, 20);
	$x_anch_row = new Math::MatrixReal (1, 20);
	$x_mem_row = new Math::MatrixReal (1, 20);
	$x_nucl_row = new Math::MatrixReal (1, 20);

	#The very transposition
	$x_intra_row->transpose($x_intra_col);
	$x_extra_row->transpose($x_extra_col);
	$x_anch_row->transpose($x_anch_col);
	$x_mem_row->transpose($x_mem_col);
	$x_nucl_row->transpose($x_nucl_col);

	#Calculate Mahalanobis Distance
	$dis{'intra'} = (($x_intra_row)*($smatrix))*($x_intra_col);
	$dis{'extra'} = (($x_extra_row)*($smatrix))*($x_extra_col);
	$dis{'anch'} = (($x_anch_row)*($smatrix))*($x_anch_col);
	$dis{'mem'} = (($x_mem_row)*($smatrix))*($x_mem_col);
	$dis{'nucl'} = (($x_nucl_row)*($smatrix))*($x_nucl_col);


	#Values to array
	$value{'Intracellular'}= $dis{'intra'}->element(1,1);
	$value{'Extracellular'}= $dis{'extra'}->element(1,1);
	$value{'Anchored'}= $dis{'anch'}->element(1,1);
	$value{'Membrane'}= $dis{'mem'}->element(1,1);
	$value{'Nuclear'}= $dis{'nucl'}->element(1,1);

	#Print out results

	sub compfunc {
		$value{$a} <=> $value{$b}
	}

	my @outcome;

	foreach $entry (sort compfunc keys %value) {
	
		push(@outcome, "$entry: $value{$entry}");
	}

	return \@outcome;
}


