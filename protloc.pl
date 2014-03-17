#!/usr/bin/env perl

use strict;

use Bio::SeqIO;
use Protloc;

my $file = shift;

if ( $file && -e $file ) {

	my $seqio = Bio::SeqIO->new(-file => $file, '-format' => 'Fasta');
	while(my $seq = $seqio->next_seq) {
		my $string = $seq->seq;
		my $id = $seq->id;

		my $value = process( $string );
		my @outcome;

		foreach my $entry (sort { $value->{$a} <=> $value->{$b} } keys %{$value}) {
	
			push(@outcome, "$entry: $value->{$entry}");
		}

		print $id."\t".join("\t", @outcome), "\n";

	}

}




