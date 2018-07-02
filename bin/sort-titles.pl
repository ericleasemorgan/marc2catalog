#!/usr/bin/perl

# sort-titles.pl - update database so it includes a sortable title field

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, and distributed under a GNU Public License

# June    30, 2017 - first cut, but ought to be incorporated into marc2sql.pl
# October 19, 2017 - tweak munging so things are more accurate but still not perfect


# configure
use constant DRIVER   => 'SQLite';
use constant ARTICLES => ( 'a', 'an', 'the', 'die' );

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
binmode( STDOUT, ':utf8' );

# build sql query
$sql = 'SELECT title, system FROM titles ORDER BY title ASC;';		

# search
$handle = $dbh->prepare( $sql );
$result = $handle->execute() or die $DBI::errstr;

# process the result
while( my $row = $handle->fetchrow_hashref() ) {

	# re-initialize
	my $title      = $$row{ 'title' };
	my $system     = $$row{ 'system' };
	my $title_sort = lc( $title );
	my $update     = '';
	
	# munge the title into a sortable title, more or less
	while ( $title_sort =~ /^[[:punct:]]{1,}/ ) { $title_sort =~ s/^[[:punct:]]{1,}// }
	for my $article ( ARTICLES ) { $title_sort =~ s/^$article //e }
	while ( $title_sort =~ /^ {1,}/ ) { $title_sort =~ s/^ {1,}// }
	while ( $title_sort =~ /^[[:punct:]]{1,}/ ) { $title_sort =~ s/^[[:punct:]]{1,}// }

	# escape the sorted title and create an UPDATE statement
	$title_sort =~ s/'/''/g;
	$update     =  qq(UPDATE titles SET title_sort = '$title_sort' where system = '$system';);
	
	# echo our good work
	warn "      system: $system\n";
	warn "       title: $title\n";
	warn "  sort title: $title_sort\n";
	warn "         sql: $update\n";
	warn "\n";
	
	# do the work or die
	$subhandle = $dbh->prepare( $update );
	$result    = $subhandle->execute() or die $DBI::errstr;
	
}

# clean up and done
$dbh->disconnect();
exit;
