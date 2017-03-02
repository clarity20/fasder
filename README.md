# Fasder

A descendant of Wei Dai's [fasd] (https://github.com/clvv/fasd) project offering
improved performance on Cygwin/Windows and (eventually) more... 

### Requirements

Fasder is a shell script that requires bash version 4.1 or higher. 
We've traded in POSIX compatibility for Bash's greater range of built-in
features to "squeeze" the script for faster performance, particularly
on Cygwin/Windows systems.

### TODO

* Refashion this TODO list into a project issues page in the usual GitHub fashion.
* Most but not all optimizations scale well as the fasd data file grows.
A close analysis of our mapfile helper function `populate_ranks_and_times`
might turn up code that can be pre-calculated outside the implied loop.
Also, timing the prompt hook by setting `PROMPT_COMMAND="time "$PROMPT_COMMAND`
somehow quickens the time-to-next-prompt (but not necessarily fasd...)
* Optimization work thus far has focused on the prompt hook and the `--add`
and `--query` options. For the other options, there remains some low-hanging
fruit waiting to be picked.
* The issues queue of the original fasd project contains some unresolved issues we
might wish to address here.
* Merge the original project's README into this file, making changes wherever
appropriate.
* Rename all components from "fasd" to "fasder."
* Check the main script for indentation and/or markers to facilitate folding
* Develop a more formal strategy for testing. There are two classes of use cases:
(1) the hidden operation of the \_fasd_prompt_func at the command line and 
(2) explicit invocations of fasd, often through its short aliases. Regarding
the former, our script's dependency on a `PROMPT_COMMAND` whose exact meaning
changes whenever we edit the script creates a challenging situation akin to
the Observer Effect familiar to physicists. As a workaround, we could
structure our test rig to invoke "fasd --proc <cmd>" directly for each test
case while we monitor the effects this has on a suitably mocked-up data file.
The use cases wherein fasd is explicitly called should be easier to test.

