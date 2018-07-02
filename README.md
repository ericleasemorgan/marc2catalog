# marc2catalog

Given a set of MARC records, output a set of library catalogs

This set of scripts will take a set of MARC data, parse it into a simple (rudimentary and SQLite) database, and then generate a report against the database in the form of plain text files -- a set of "library catalogs & indexes". These catalogs & indexes are intended to be printed, but they can also be used to support rudimentary search via one's text editor. For extra credit, the programer could read the underlying database, feed the result to an indexer, and create an OPAC (online public access catalog).

The system requires a bit of infrastructure: 1) Bash, 2) Perl, 3) a Perl module named MARC::Batch, 4) the DBI driver for SQLite. 

The whole MARC-to-catalog process can be run with a single command:

    ./bin/make-all.sh <marc> <name>

Where &lt;marc&gt; is the name of the MARC file, and &lt;name&gt; is a one-word moniker for the collection. The distribution comes with sample data, and therefore an example execution includes:

    ./bin/make-all.sh ./etc/morse.mrc morse
    
The result ought to be the creation of a .db file in the ./etc directory, a collections directory, and sub-directory of collections, and a set of plain text files in the later. The plain text files are intended to be printed or given away like candy to interested learners or scholars.

Eric Lease Morgan &lt;emorgan@nd.edu&gt;  
July 2, 2018

