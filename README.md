Bin Search Script
Overview

This bash script provides functionalities to search and display information about files in the /bin directory based on specific criteria. It supports three options:

    -s: Search for files containing a specific string.
    -b: Search for files based on their size with comparison operators.
    -l: List all symbolic links and their targets.

Usage
Options

    -s: Search for files containing a specific string.
    -b: Search for files based on their size with comparison operators (GT, LT, LE, GE, EQ, NE).
    -l: List all symbolic links and their targets.

Syntax

    ./bin_search.sh -s <string>
    ./bin_search.sh -b <operator,value>
    ./bin_search.sh -l

Examples

  Search for files containing a specific string:

    ./bin_search.sh -s "bash"

  Search for files based on their size:

    ./bin_search.sh -b "GT,1024"

  List all symbolic links and their targets:

    ./bin_search.sh -l

Functions
unit()

Formats byte size into human-readable format (bytes, kilobytes, megabytes).
string(arg)

Searches for files in /bin that contain the specified string and displays their names and sizes.
bsize(bs)

Searches for files in /bin based on the specified byte size and comparison operator, displaying their names and sizes.
symlink()

Lists all symbolic links in /bin and displays the link name and the target.
Error Handling

The script includes error handling for:

  No options or arguments passed.
  Multiple arguments passed.
  Invalid options passed.
  Missing arguments for options -s and -b.
  Invalid byte values or operators for the -b option.
  Arguments passed to the -l option.

Prerequisites

  Ensure you have execute permissions for the script:

    chmod +x bin_search.sh

Code Review

All contributions will be reviewed before merging. Feedback may be provided to ensure code quality, maintainability, and adherence to best practices.
