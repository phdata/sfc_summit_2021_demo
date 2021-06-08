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

The data should now be available in your database.

### Details
The `init/init_objects.sql` script created the following objects:

1. The `raw_device_data` table -- This table will hold the raw json files, and
will contain three rows, one for each json file in the `json/` directory.
1. The `ui_views` view -- This view is handy to remove some redundant common table
expression (CTE) definitions used in some of the queries in the `query/` directory.
It represents the User Interface (UI) views from the device logs, after the array
is flattened.

The `init/load_files.sql` script performs the following:

1. Performs a `put` for all files from the `json/` directory into the table stage
of the `raw_device_data` table.
1. Performs a `copy into` to the `raw_device_data` table for all data in the
table's stage.

## Querying the data
Querying the data can be done via SnowSQL or the Snowflake Worksheets UI on the
website.

1. `raw.sql` -- This file contains the most basic query for this data, and showcases
what the variant json looks like when loaded directly from the file.
1. `tf_views.sql` -- This file contains a query that is approximately the same as
the `ui_views` view, and doesn't do much more than simply flattening the `Views`
json array, and processing some of the common elements of each object.
1. `tf_prepare_actions.sql` -- This file contains a query that, starting from the
`ui_views` view, explodes the json object, filtering results down to only those
that are both from the `Prepare` UI view and have key's that can parse to dates
provided.
1. `tf_agg_filename.sql` -- This file contains a query that shows aggregation
features provided by Snowflake that assist with creating variant datatypes.
1. `tf_agg_procedure.sql` -- This file contains a query that goes a bit deeper.
First, it creates two common table expressions (CTE's), where the first
represents just the `ProcedureDetails` views (hint, the `ProcedureDetails`
entries aren't actually UI views...), and their start and end times. The
second is each UI view joined with the corresponding Procedure, defined by
a common filename and the UI view endtime being between the Procedure's start
and end times. Finally the query joins the two CTE's together and performs an 
`array_agg` when grouping by the filename and array_idx to show which UI
views are asssociated with which Procedures as an array datatype.