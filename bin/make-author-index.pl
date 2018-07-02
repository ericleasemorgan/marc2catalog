#!/usr/bin/perl

# make-author-index.pl - create a list authors and their associated titles; an author index

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, and distributed under a GNU Public License

# June     30, 2017 - first cut
# November 10, 2017 - removed box number in favor of call number

# configure
use constant DRIVER   => 'SQLite';
use constant PREFACE  => qq(\n\nAuthor index\n\n\n);

# require
use strict;
use DBI;

my $name = $ARGV[ 0 ];
if ( ! $name ) { die "Usage: $0 <name>" }

# initialize
my $driver    = DRIVER; 
my $database = "./etc/$name.db";
my $dbh       = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;
my $sql       = '';
my $result    = '';
my $handle    = '';
my $subhandle = '';
my $subsubhandle = '';
my $count     = 0;
#binmode( STDOUT, ':utf8' );

# create a list of all the authors
$sql = qq(SELECT DISTINCT( author ) FROM titles ORDER BY author ASC;);

# do the work
$handle = $dbh->prepare( $sql );
$result = $handle->execute() or die $DBI::errstr;

# start the output
print PREFACE;

# output, disconnect, and done
while( my $row = $handle->fetchrow_hashref() ) {

	# the author
	my $author = $$row{ 'author' };
	my @boxes     = ();
	
	# only want titles with authors
	next if ( ! $author );
	
	# echo and escape
	print "$author\n";
	$author =~ s/'/''/g;

	# build a title subquery
	$sql = qq(SELECT title, callnumber FROM titles WHERE author='$author' ORDER BY title_sort ASC;);
	$subhandle = $dbh->prepare( $sql );
	$result = $subhandle->execute() or die $DBI::errstr;
	while( my $titles = $subhandle->fetchrow_hashref() ) {
	
		# parse and increment
		my $title      = $$titles{ 'title' };
		my $callnumber = $$titles{ 'callnumber' };
		$count++;
		
		# echo
		print "\t$count. $title ($callnumber)\n";
		
	}
	
	# delimit and reset
	print "\n";
	$count = 0;
	
}

# clean up and done
$dbh->disconnect();
exit;
