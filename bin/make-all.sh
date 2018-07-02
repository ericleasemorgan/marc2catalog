#!/bin/bash

# make-all.sh - one script to rule them all; do all the work in one go

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, and distributed under a GNU Public License

# June 30, 2017 - first cut
# July  2, 2018 - added checking for input


# sanity check
if [[ -z "$1" || -z "$2" ]]; then
	echo "Usage: $0 <MARC> <name>" >&2
	exit
fi

# read input
MARC=$1
NAME=$2

# build database, and then generate indexes
./bin/make-db.sh $MARC $NAME
./bin/make-indexes.sh $NAME

# clean up
rm -rf ./tmp/*
rm -rf ./log/*

# voiula!
echo "Done"
