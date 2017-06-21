#!/usr/bin/env perl

# Automatically enables "strict", "warnings", "utf8" and Perl 5.10 features
use Mojolicious::Lite;
use Protloc;
use Data::Dumper;
use JSON qw(decode_json);

get '/' => sub {
	my $self = shift;
	$self->render('index');
};

post '/' => sub {
	my $self = shift;
	my $id = $self->param('id');
	my $seq = $self->param('seq');
	my $value = process( $seq );
	
	my @outcome;

	foreach my $entry (sort { $value->{$a} <=> $value->{$b} } keys %{$value}) {

		my $str = $entry.": ".$value->{$entry};
		push( @outcome, $str );
	}
	
	$self->render('submit', id=> $id, seq => $seq, result => \@outcome );
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
	
	my @seqs = ();
	
	$seqs[0] = {};
	$seqs[0]->{"seq"} = $seq;
	$seqs[0]->{"distance"} = \@outcome;
	
	$out->{"program"} = "ProtLoc";
	$out->{"version"} = "0.1.0";
	$out->{"results"} = \@seqs;
	
	$self->render(json => $out );
};


# Route with placeholder
post '/api/batch/' => sub {
	
	my $self = shift;

	my $out;
	
	my @seqs = ();
	
	if ( defined( $self->req ) ) {
		
		if ( defined( $self->req->body ) ) {
			
			my $body =  $self->req->body;
			
			my $array = decode_json( $body );

			if ( $array ) {
				if (ref($array) eq 'ARRAY') {
					
					print "Here!";
					my $iter = 1;
					foreach my $case ( @{$array} ) {
						
						my $id = "seq".$iter; 
						if ( defined( $case->{"id"} ) ) {
							$id = $case->{"id"};
						}
						
						if ( defined( $case->{"seq"} ) ) {
							my $seq = $case->{"seq"};
							my $value = process( $seq );
							
							my @outcome;

							foreach my $entry (sort { $value->{$a} <=> $value->{$b} } keys %{$value}) {
							
								my %result;
								$result{$entry} = $value->{$entry};
								push( @outcome, \%result );
							}
							
							my $struct = {};
							$struct->{"id"} = $id;
							$struct->{"distance"} = \@outcome;
							
							push( @seqs, $struct );
							
						} 
						
						$iter++;
						
					}
					
				}
			}

		}
		
	}
	
	$out->{"program"} = "ProtLoc";
	$out->{"version"} = "0.1.0";
	$out->{"results"} = \@seqs;
	
	$self->render(json => $out );
};

# Start the Mojolicious command system
app->start;
__DATA__

@@ index.html.ep
<!DOCTYPE html>
<html>
<head>
<title>ProtLoc</title>
</head>
<body>
<h1>ProtLoc</h1>
<p><strong>ProtLoc</strong> is a tool that assigns a possible cellular localization of polypeptide sequences according to their amino acid frequencies against predefined sets (INTRACELLULAR, EXTRACELLULAR, MEMBRANE, ANCHORED and NUCLEAR).</p>
<div id="form">
<form method="post" action="/">
<label>Name/ID</label><input type="text" name="id">
<label>Sequence</label><textarea name="seq">
</textarea>
<input type="submit" value="Predict!">
</form>
<h3>Bibliography</h3>
<blockquote>
<ul>
<li>J. Cedano, P. Aloy, J.A. Pérez-Pons, and E. Querol, <em>Relation between aminoacid composition and cellular localisation of proteins</em>, Journal of Molecular Biology, 266, 594-600, 1997.</li>
</ul>
</blockquote>
<p align='right'>Contact <a href='mailto:toniher\@bioinf.uab.cat'>toniher@bioinf.uab.cat</a> IBB-UAB 2002-2016</p>
</body>
</html>

@@ submit.html.ep
<!DOCTYPE html>
<html>
<head>
<title>ProtLoc Results</title>
</head>
<body>
<h1>ProtLoc Results</h1>
<p><strong>ProtLoc</strong> is a tool that assigns a possible cellular localization of polypeptide sequences according to their amino acid frequencies against predefined sets (INTRACELLULAR, EXTRACELLULAR, MEMBRANE, ANCHORED and NUCLEAR).</p>
<div id="form">
<form method="post" action="/">
<label>Name/ID</label><input type="text" name="id" value="<%= $id %>">
<label>Sequence</label><textarea name="seq">
<%= $seq %>
</textarea>
<input type="submit" value="Predict!">
</form>
<h3>Results</h3>
<div id="result">
<ul>
% foreach my $item (@$result) {
<li><%= $item %></li>
% }
</ul>
</div>
<h3>Bibliography</h3>
<blockquote>
<ul>
<li>J. Cedano, P. Aloy, J.A. Pérez-Pons, and E. Querol, <em>Relation betweenm aminoacid composition and cellular localisation of proteins</em>, Journal of Molecular Biology, 266, 594-600, 1997.</li>
</ul>
</blockquote>
<p align='right'>Contact <a href='mailto:toniher\@bioinf.uab.cat'>toniher@bioinf.uab.cat</a> IBB-UAB 2002-2014</p>
</body>
</html>


