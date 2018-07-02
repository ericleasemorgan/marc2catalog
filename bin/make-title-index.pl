#!/usr/bin/perl

# make-title-index.pl - create a list titles and all of their associated metadata; create the main index

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, and distributed under a GNU Public License

# June     29, 2017 - first cut
# October  19, 2017 - changed the output to: 1) take up less space and 2) look more catalog card-like
# November 10, 2017 - removed box number in favor of call number


# configure
use constant DRIVER   => 'SQLite';
use constant PREFACE  => qq(\n\nTitle index\n\n\n);

# require
use strict;
use DBI;

my $name = $ARGV[ 0 ];
if ( ! $name ) { die "Usage: $0 <name>" }

# initialize
my $driver   = DRIVER; 
my $database = "./etc/$name.db";
my $dbh      = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;
my $handle   = '';
$|           = 1;
#binmode( STDOUT, ':utf8' );

# add some context
print PREFACE;

# find some titles
$handle = $dbh->prepare( qq(SELECT * FROM titles ORDER BY title_sort ASC;) );
$handle->execute() or die $DBI::errstr;

# process each result
while( my $titles = $handle->fetchrow_hashref ) {

	# re-initialize
	my @subjects  = ();
	my @boxes     = ();
	my $subhandle = '';
	
	# parse the title data
	my $author     = $$titles{ 'author' };
	my $callnumber = $$titles{ 'callnumber' };
	my $date       = $$titles{ 'date' };
	my $extent     = $$titles{ 'extent' };
	my $place      = $$titles{ 'place' };
	my $publisher  = $$titles{ 'publisher' };
	my $system     = $$titles{ 'system' };
	my $title      = $$titles{ 'title' };
	my $notes      = $$titles{ 'notes' };
	
	# get subjects
	$subhandle = $dbh->prepare( qq(SELECT subject FROM subjects WHERE system='$system' ORDER BY subject;) );
	$subhandle->execute() or die $DBI::errstr;
	while( my @subject = $subhandle->fetchrow_array ) { push @subjects, $subject[ 0 ] }

	# dump sort of like a catalog card
	print "$title ";
	if ( $author )    { print "$author -- " }
	if ( $publisher ) { print "$place $publisher $date" }
	print "\n  * $extent";
	if ( $notes )     { print "\n  * $notes" }
	print "\n  * call number: $callnumber";
	if ( @subjects )  { print "\n  * "; print join( ' ', @subjects ) }
	print "\n\n\n";

}

# clean up and done
$dbh->disconnect();
exit;
