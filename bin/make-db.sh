#!/bin/bash

# make-db.sh - given a set of MARC records, build a rudimentary database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, and distributed under a GNU Public License

# June 30, 2017 - first cut


# get input
MARC=$1
NAME=$2

# configure
MARC2SQL='./bin/marc2sql.pl'

# initialize
SQL="./tmp/$NAME-cataloging.sql"
DB="./etc/$NAME.db"

# set up environment
mkdir -p ./tmp

# extract sql
$MARC2SQL $MARC $NAME

# build sql
cat './etc/schema.sql'                > $SQL
echo 'BEGIN TRANSACTION;'            >> $SQL
cat "./tmp/$NAME-bibliographics.sql" >> $SQL
cat "./tmp/$NAME-subjects.sql"       >> $SQL
echo 'END TRANSACTION;'              >> $SQL

# build database
rm -rf $DB
cat $SQL | sqlite3 $DB

# sort titles
./bin/sort-titles.pl $NAME

# ta-da!
echo "Done."
