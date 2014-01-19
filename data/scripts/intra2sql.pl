#!/usr/bin/perl

use DBI;

$dir=$ARGV[0];
$database="protloc";
$user="flipe";
$password="mecagondio";

$class=1;

$dbh = DBI->connect("DBI:mysql:$database", $user, $password) || die "Cannot connect $database: $dbh->errstr\n";


	opendir(HTML, "$dir") || die "Tus muertos!";
	while ($entry=readdir(HTML))
		{
		if ($entry=~ /.*txt/)
		{push(@llista, $entry);}
		}
	print "@llista\n";

	foreach $cas (@llista) {
		open (CAS, "<$dir/$cas") || die "cony!";
		while (<CAS>) {
			($swiss)=$_=~/^(\S*)\s*/;
			($word)=$_=~/^\S*\s*(\S*)\s*/;
			($seq)=$_=~/^\S*\s*\S*\s*(\S*)\s*/;
			($note)=$_=~/^\S*\s*\S*\s*\S*\s*(.*)$/;

		}
	
		$swiss=$dbh->quote($swiss);
		$word=$dbh->quote($word);
		$seq=$dbh->quote($seq);
		$note=$dbh->quote($note);

		print "$swiss, $word, $seq, $note\n";
		#insert in DB by SQL Query
		$sth = $dbh->prepare("INSERT INTO ProtSet (CLASS, SWISS, WORD, SEQ, NOTE) values
('$class', $swiss, $word, $seq, $note)");
		$sth->execute || die "Cannot make query: $sth->errstr\n";
		$sth->finish;
		undef $swiss, $word, $note, $seq;	
	}
	closedir(HTML);
	undef @llista;

$dbh->disconnect;	

