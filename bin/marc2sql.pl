#!/usr/bin/perl

# marc2sql.pl - given a set of MARC records, output sets of sql

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# June     29, 2017 - first investigations; this is the hard work
# November 10, 2017 - removed "box" and replaced it with call number; hacked year



# require
use strict;
use MARC::Batch;

# get input and do sanity check
my $marc = $ARGV[ 0 ];
my $name = $ARGV[ 1 ];
if ( ! $marc or ! $name ) { die "Usage: $0 <marcfile> <name>\n" }

# initialize
my $batch          = MARC::Batch->new( 'USMARC', $marc );
my $bibliographics = "./tmp/$name-bibliographics.sql";
my $subjects       = "./tmp/$name-subjects.sql";

# turn off warnings because we have dirty data
$batch->strict_off;
$batch->warnings_off;

# open outputs
open B, " > $bibliographics" or die "Can't open $bibliographics ($!) Call Eric ";
open S, " > $subjects"       or die "Can't open $subjects ($!) Call Eric ";

# assume and specify UTF-8 output (and input)
binmode( STDERR, ':utf8' );
binmode( STDOUT, ':utf8' );
binmode( B,      ':utf8' );
binmode( S,      ':utf8' );

# process each item in the batch
while ( my $record = $batch->next ) { 
	
	# parse the easy stuff, and update
	my $system          = $record->field( '001' )->as_string;
	my $author          = $record->author;
	my $title           = $record->title_proper;
	my $datePublication = $record->subfield( '260', 'c' );
	my $place           = $record->subfield( '260', 'a' );
	my $publisher       = $record->subfield( '260', 'b' );
	my $extent          = $record->subfield( '300', 'a' );
	my $date            = $datePublication;

	# notes
	my @notes = ();
	foreach my $note ( $record->field( '50.' ) ) { push( @notes, $note->as_string )	}
	my $notes = join( '; ', @notes );
	
	# subjects
	my @subjects = ();
	foreach my $_6xx ( $record->field( '6..' ) ) {
	
		my @subfields = ();
		my $found     = 0;
		foreach my $subfield ($_6xx->subfields ) {
		
			if ( $$subfield[ 1 ] eq 'Catholic pamphlets.' ) {
			
				$found = 1;
				last;
				
			}
			
			push( @subfields, $$subfield[ 1 ] );
			
		}
		
		if ( $found == 0 ) { push( @subjects, join( ' -- ', @subfields ) ) }
		
	}
	
	# get call number
	my $call_number = '';
	if ( $record->field( '852' ) ) {
	
		# process each 035, if they exist
		foreach my $_852 ( $record->field( '852' ) ) {
		
			$call_number = $_852->subfield( 'h' ) . ' ' . $_852->subfield( 'i' );
			
		}
				
	}
	# get oclc number
	my $oclc = '';
	if ( $record->field( '035' ) ) {
	
		# process each 035, if they exist
		foreach my $_035 ( $record->field( '035' ) ) {
		
			# check for oclc number
			if ( $_035->as_string =~ /OCoLC/ ) {
			
				# parse, clean, and done
				$oclc =  $_035->as_string;
				$oclc =~ s/[[:punct:]]//g;
				$oclc =~ s/OCoLC//g;
				last;
				
			}
		
		}
				
	}
	
	# look at leader; determine whether or not this is an rda record
	my $isrda = 0;
	my $_018  = substr( $record->leader, 18, 1 );
	if ( $_018 eq 'i' or $_018 eq 'c' ) { $isrda = 1 }
	
	# if an rda record, then override publication information, if it exists	
	if ( $isrda ) {
	
		# look for 264 field(s)
		if ( $record->field( '264' ) ) {
		
			# process each 264 field
			foreach my $_264 ( $record->field( '264' ) ) {
			
				# check second indicator
				if ( $_264->indicator( 2 ) == 1 ) {
				
					# overide existing information
					$publisher       = $_264->subfield( 'b' );
					$place           = $_264->subfield( 'a' );
					$datePublication = $_264->subfield( 'c' );

				}
				
				# got copyright information?
				elsif ( $_264->indicator( 2 ) == 4 ) { $date = $_264->subfield( 'c' ) }
				
			}
								
		}
		
	}
	
	# munge the date into a year
	my $year =  $date;
	$year    =~ s/\D+//g;
	if ( length( $year) > 4 ) { $year = substr( $year, 0, 3 ) }

	# escape single quotes
	$author    =~ s/'/''/g;
	$title     =~ s/'/''/g;
	$publisher =~ s/'/''/g;
	$place     =~ s/'/''/g;
	$notes     =~ s/'/''/g;
	
	# debug
	warn "     system number: $system\n";
	warn "            author: $author\n";
	warn "             title: $title\n";
	warn "    copyright date: $date\n";
	warn "              year: $year\n";
	warn "         publisher: $publisher\n";
	warn "             place: $place\n";
	warn "              oclc: $oclc\n";
	warn "             notes: $notes\n";
	warn "       call number: $call_number\n";
	warn "        subject(s): ", join( '; ', @subjects ), "\n";
	
	# output
	print B "-- system number: $system\n";
	print B "INSERT INTO titles ('author', 'callnumber', 'date', 'extent', 'notes', 'oclc', 'place', 'publisher', 'system', 'title', 'year') VALUES ( '$author', '$call_number', '$date', '$extent', '$notes', '$oclc', '$place', '$publisher', '$system', '$title', '$year' );\n";
	
	# output
	print S "-- system number: $system\n";
	foreach my $subject ( @subjects ) {
	
		$subject =~ s/'/''/g;
		print S "INSERT INTO subjects ( 'subject', 'system' ) VALUES ( '$subject', '$system' );\n";
	
	}
		
	# beautify
	warn "\n";
	
}

# done
exit;


