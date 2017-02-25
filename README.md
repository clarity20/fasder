# Fasder

A descendant of Wei Dai's [fasd] (http://github.com/vv/fasd) project offering
improved performance on Cygwin/Windows and (eventually) more... 

### Requirements

Fasder is a shell script that requires bash version 4.1 or higher. 
We've traded in POSIX compatibility for Bash's greater range of built-in
features to "squeeze" the script for faster performance, particularly
on Cygwin/Windows systems.

### TODO

* Most but not all optimizations scale well as the fasd data file grows.
A close analysis of the mapfile helper function `populate_ranks_and_times`
might turn up code that can be pre-calculated outside the implied loop.
Also, timing the prompt hook by setting `PROMPT_COMMAND="time "$PROMPT_COMMAND`
somehow quickens the time-to-next-prompt (but not necessarily fasd...)
* Optimization work thus far has focused on the prompt hook and the `--add`
and `--query` options. For the other options, there remains some low-hanging
fruit waiting to be picked.
* The issues queue of original fasd project contains some unresolved issues we
might wish to address here.
* Merge the original project's README into this file, making edits wherever
they seem appropriate.

