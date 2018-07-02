#!/usr/bin/perl

# make-subject-index.pl - create a list subjects and their associated titles; a subject index

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, and distributed under a GNU Public License

# June 30, 2017 - first cut


# configure
use constant DRIVER   => 'SQLite';
use constant PREFACE  => qq(\n\nSubject index\n\n\n);

# require
use strict;
use DBI;

my $name = $ARGV[ 0 ];
if ( ! $name ) { die "Usage: $0 <name>" }


# initialize
my $driver       = DRIVER; 
my $database = "./etc/$name.db";
my $dbh          = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;
my $sql          = '';
my $result       = '';
my $handle       = '';
my $subhandle    = '';
my $subsubhandle = '';
my $count        = 0;
#binmode( STDOUT, ':utf8' );

# create a list of all the authors
$sql = qq(SELECT DISTINCT( subject ) FROM subjects ORDER BY subject ASC;);

# do the work
$handle = $dbh->prepare( $sql );
$result = $handle->execute() or die $DBI::errstr;

# start the output
print PREFACE;

# output, disconnect, and done
while( my $row = $handle->fetchrow_hashref() ) {

	# the subject
	my $subject = $$row{ 'subject' };

	# echo and escape
	print "$subject\n";
	$subject =~ s/'/''/g;

	# build a did subquery
	$sql = qq(SELECT system FROM subjects WHERE subject='$subject';);
	$subhandle = $dbh->prepare( $sql );
	$result = $subhandle->execute() or die $DBI::errstr;
	while( my $systems = $subhandle->fetchrow_hashref() ) {
	
		# parse and increment
		my $system = $$systems{ 'system' };
		
		# build a title subsubquery
		$sql = qq(SELECT title, callnumber FROM titles WHERE system='$system' ORDER BY title_sort;);
		$subsubhandle = $dbh->prepare( $sql );
		$result = $subsubhandle->execute() or die $DBI::errstr;
		while( my $titles = $subsubhandle->fetchrow_hashref() ) {
		
			# parse, increment, and output
			my $title      = $$titles{ 'title' };
			my $callnumber = $$titles{ 'callnumber' };
			$count++;
			print "\t$count. $title ($callnumber)\n";
			
		}
		
	}
	
	# delimit and reset
	print "\n";
	$count = 0;
	
}

# clean up and done
$dbh->disconnect();
exit;
