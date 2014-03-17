#!/usr/bin/env perl

# Automatically enables "strict", "warnings", "utf8" and Perl 5.10 features
use Mojolicious::Lite;
use Protloc;

get '/' => sub {
	my $self = shift;
	$self->render(text => "Hello!");
};

# Route with placeholder
get '/api/seq/:seq' => sub {
	my $self = shift;
	my $seq  = $self->param('seq');
	my $value = process( $seq );

	my @outcome;

	foreach my $entry (sort { $value->{$a} <=> $value->{$b} } keys %{$value}) {

		my %result;
		$result{$entry} = $value->{$entry};
		push( @outcome, \%result );
	}
	
	my $out;
	$out->{"result"} = \@outcome;
	$out->{"seq"} = $seq;
	
	$self->render(json => $out );
};

# Start the Mojolicious command system
app->start;
