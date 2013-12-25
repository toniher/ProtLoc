#!/usr/bin/perl

use Math::MatrixReal;
use CGI;


$p = new CGI;

print $p->header, $p->start_html(-title=>'Protloc', -BGCOLOR=>'#EEE9BF'),

"<table width='100%' border='1' bgcolor='#228B22'><tr bgcolor='#228B22'><td><table width='100%' border='0'><tr bgcolor='#228B22'><td width='30%' align='center'><a href='/cgi-bin/trsdb/protloc.cgi'><img
src='/trsdb/Protlogo.png' alt='Logo' border='0'></a></td>
	       
	       <td width='20%' align='left'>",

#Formulari
	       $p-> start_form, $p->p,
	       " <b>Name / ID</b>", $p->br,
               $p->textfield('ID'),  $p->p,
	       "</td><td width='50%' align='left'>",
	       " <b>Sequence</b>",$p->br, 
	       
               $p->textarea(-name=>'seq', -rows=>'10', -columns=>'62') ,

	       $p->br, 
	       "</td></tr><tr><td></td><td></td><td align='right'>", $p->submit(-value=>'ProtLoc!', -name=>'protloc'), "</td></tr></table></td></tr></table>" ,$p->end_form;

	       
#Per usuari


if ($p->param()) {
	
unless ($p->param('seq')=~/^\s*$/) {

	$ide = $p->param('ID');
	$seqstring = $p->param('seq');
	&process;
}

elsif (($p->param('ac')=~/^\s*$/) and ($p->param('seq')=~/^\s*$/)) {
		print "<blockquote>It appears you have entered NO sequence or ID";
	}

	
}

#Portada

else { print "<blockquote><p align='center'><font size=+3><b>Welcome to ProtLoc!</b></font></p><br />",

	"
	<font type='Arial' size=-1>
	<font size=+1><b>ProtLoc</b></font> is a tool that assigns a possible cellular localization of polypeptide sequences according to their amino acid frequencies against predefined sets (INTRACELLULAR, EXTRACELLULAR, MEMBRANE, ANCHORED and NUCLEAR).<br /><br />",

	"<table width='100%' bgcolor='#228B22'><tr><td><b>Usage</b></td></tr></table> <br />",

	"- You can paste or type your sequence and give it a name (optional).<br />
	<br /><br />
	<p><em>The results are printed in two columns. The first is the cellular localization, and the second is a distance value. The lower the distance, upper in the list, the higher likeliness that peptide may be found in that localization.</em></p><br />\n
	",

	"<table width='100%' bgcolor='#228B22'><tr><td><b>Bibliography</b></td></tr></table> <br />",

	"* J. Cedano, P. Aloy, J.A. Pérez-Pons, and E. Querol, <i>Relation betweenm aminoacid composition and cellular localisation of proteins</i>, Journal of Molecular Biology, 266, 594-600, 1997. <br />
	<br />
	<p align='center'><font size=+1>Have a Nice Prediction!</font></p>
	";


print "</blockquote><hr/ ><font size=-1><p align='right'>Contact <a href='mailto:toniher\@bioinf.uab.cat'>toniher\@bioinf.uab.cat</a> IBB-UAB 2002-2011</font></font></blockquote>";


print $p->end_html;


}



sub process {			
print $p->p, 
"<blockquote>
<font face='Arial' size=-1>";



$seqstring=~s/\s*//g;
chomp($seqstring);

@seqarray=split("", $seqstring);

@seqdis = split(//,$seqstring);

$length=@seqdis;

print 	
	"<blockquote>",
	
	"<table width='100%' bgcolor='#228B22'><tr><td><b>Identification</b></td></tr></table> <br />",
	
	"<b>$ide</b><br /></font>";
				




	

print $p->br, "<table width='100%' bgcolor='#228B22'><tr><td><b>ProtLoc Results</b></td></tr></table><br/>";



#Fill row of prot with zeroes
for ($i=0; $i<21; $i++) { 

$matrix[$i]=0;

}

for ($i=0; $i<$#seqarray + 1; $i++) {

&freq($seqarray[$i]);

}

#Function assign freqs
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
	
foreach $entry (sort compfunc keys %value) {
	
	print "<i>$entry</i> => $value{$entry}", $p->br;
}


	
print "</blockquote><br /><hr/ ><p align='right'>Contact <a href='mailto:toniher\@bioinf.uab.cat'>toniher\@bioinf.uab.cat</a> IBB-UAB 2002-2011</font></blockquote>";


}

print $p->end_html;

