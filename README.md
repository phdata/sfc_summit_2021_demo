This repo exists as a set of supplemental materials to a presentation I did at
Snowflake Summit 2021 on JSON support in Snowflake.

## Repo Contents
The `json/` directory contains JSON files that can be loaded into Snowflake to be
processesed using Snowflakes support for variant datatypes.

The `init/` directory contains some scripts to create the initial table that will
hold the JSON data and to populate it with the contents of the files. It is worth
noting that this process uses the PUT command, so the recommended means to invoke
these scripts is via SnowSQL. Using SnowSQL is not covered in this repo, but the
Snowflake documentation can be found
[here](https://docs.snowflake.com/en/user-guide/snowsql.html).

The `query/` directory contains example SQL queries that utilize various Snowflake
variant supporting functions to manipulate the JSON data in different ways.

## Getting Started
Start SnowSQL with variable substitution enabled (the example here shows me using
the 'nick' connection defined in config, yours will likely vary):

```
$ snowsql -c nick -o variable_substitution=true
```

Setup context...it is important to be operating out of a database and schema that
you can create tables from. When specifying the `project_directory`, __use a trailing
slash.__ The remainder of this example will use my path, replace with yours as
necessary. [/Users/nh/work/sfc_summit/]

```
SNOWSQL> use database my_db;
SNOWSQL> use schema my_schema;
SNOWSQL> use warehouse my_wh;
SNOWSQL> !define project_dir=/Users/nh/work/sfc_summit/
```

Create (or replace) table and load data into table

```
SNOWSQL> !source /Users/nh/work/sfc_summit/init/init_objects.sql
SNOWSQL> !source /Users/nh/work/sfc_summit/init/load_files.sql
```

The data is now available in your table.  You may query results using SnowSQL,
or you may move to the Snowflake Worksheets UI.