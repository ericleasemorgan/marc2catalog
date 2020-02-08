
-- schema.sql - a rudimentary bibliographic database schema

-- Eric Lease Morgan <emorgan@nd.edu>
-- (c) University of Notre Dame, and distributed under a GNU Public License

-- June 30, 2017 - first cut

CREATE TABLE titles (
  author     TEXT,
  callnumber TEXT,
  date       TEXT,
  extent     TEXT,
  notes      TEXT,
  oclc       TEXT,
  place      TEXT,
  publisher  TEXT,
  system     TEXT PRIMARY KEY,
  title      TEXT,
  title_sort TEXT,
  year       INT
);

CREATE TABLE subjects (
  subject TEXT,
  system  TEXT
);
