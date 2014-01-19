#!/usr/bin/perl

#Creates directory where it's stored all the info.
mkdir ("seq$ARGV[0]", 0777) || die "Tu padre!";
open (FILE, "<$ARGV[0]");

while (<FILE>) {
	if ($_=~ /^>/)  {
		if (defined $seq) 
				 {
				$hash{$id}=$seq;
				undef $seq;
				}
		($id)=$_=~/^>(.*)/;	
		} 	
			

	elsif ($_=~ /^\w/)  {
		$_=~ s/\n//g;
		$seq.=$_;
		}	
	}

close FILE;


 	foreach $id (keys %hash)
	{
	($title) = $id =~ /sp\|(\S*)\|/; 
	($word)= $id=~ /sp\|\S*\|(\S*)/;
	($note)= $id=~ /sp\|\S*\|\S*\s(.*)$/;
	$identif="$title\t$word\t";
	chomp($hash{$id});
	$sequence="$hash{$id}\t";
	$entry= "$identif"."$sequence"."$note";
 	print "$title";

	#Temporal file which will be sent to Transcout
	open (TEMP, ">seq$ARGV[0]/$title.txt");
	print TEMP $entry;
	close TEMP;
	}		
	
