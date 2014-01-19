#!/usr/bin/perl

use DBI;

$num=$ARGV[0];
$user="flipe";
$password="mecagondio";
$database="protloc";

$dbh = DBI->connect("DBI:mysql:$database", $user, $password) || die "Cannot connect $database: $dbh->errstr\n";

	$sth = $dbh->prepare("SELECT SWISS, SEQ from ProtSet");

	$sth->execute || die "Cannot make query: $sth->errstr\n";

	while (@row= $sth->fetchrow) {


		$ide=$row[0];
		$seqstring=$row[1];

		@seqarray=split("", $seqstring);

		for ($i=0; $i<21; $i++) {

		$matrix[$i]=0;

		}

		for ($i=0; $i<$#seqarray + 1; $i++) {

		&freq($seqarray[$i]);

		}


		sub freq {

		my $in;

		$in=@_[0];

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

		print "$ide|";

		for ($k=0; $k<20; $k++) {
		print "$freqmatrix[$k]*";
		}
		print "\n";

		}

		
	$sth->finish;
	$dbh->disconnect;


