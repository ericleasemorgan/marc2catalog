#!/bin/bash

# make-indexes.sh - a brain-dead front-end to the index-building scripts

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, and distributed under a GNU Public License

# June 30, 2017 - first cut
# July  2, 2018 - created collections directory


NAME=$1

# set up environment
mkdir -p "./collections/$NAME"

# do the work
echo "Making title index"
./bin/make-title-index.pl $NAME    > "./collections/$NAME/titles.txt"


echo "Making author index"
./bin/make-author-index.pl $NAME    > "./collections/$NAME/authors.txt"

echo "Making subject index"
./bin/make-subject-index.pl $NAME  > "./collections/$NAME/subjects.txt"

echo "Making publisher index"
./bin/make-publisher-index.pl $NAME > "./collections/$NAME/publishers.txt"

echo "Making date index"
./bin/make-date-index.pl  $NAME    > "./collections/$NAME/dates.txt"
