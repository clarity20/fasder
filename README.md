# Fasder

A descendant of Wei Dai's [fasd](https://github.com/clvv/fasd) project offering
improved performance on Cygwin/Windows and (eventually) more... 

_Fasder_ (approximate pronunciation "faster") is a command-line productivity
booster that offers quick jumping and naming access to files and directories
at the POSIX shell prompt. _Fasder_ tracks your command history to give priority
access to the files you've accessed most often or most recently.
_Fasder_ is a direct descendant of [fasd](https://github.com/clvv/fasd) which was
inspired by tools like [autojump](https://github.com/joelthelion/autojump),
[z](http://github.com/rupa/z) and [v](https://github.com/rupa/v). 

_fasder_ (and its ancestor _fasd_) takes its name from the convenient default
aliases that provide most of _fasder_'s functionality:
* `f`(files),
* `a`(all, i.e. files/directories)
* `s`(show/search/select interactively)
* `d`(directories).

_Fasder_ ranks files and directories by "frecency," that is, by a combination of
"frequency" and "recency." The term "frecency" was coined by Mozilla and is
used in Firefox
([link](https://developer.mozilla.org/en/The_Places_frecency_algorithm)).

# Introduction

If you use your shell to navigate and launch applications, _fasder_ can help you
do so more efficiently. With _fasder_, you can open files from any directory.
_Fasder_ can find a "frecent" file or directory and open it with the command you
specify. Here are some scenarios where the _fasder_ command on the left 
will expand to the shell command on the right. Pretty magical, huh?

```
  v def conf       =>     vim /some/awkward/path/to/type/default.conf
  j abc            =>     cd /hell/of/a/awkward/path/to/get/to/abcdef
  m movie          =>     mplayer /whatever/whatever/whatever/awesome_movie.mp4
  o eng paper      =>     xdg-open /you/dont/remember/where/english_paper.pdf
  vim `f rc lo`    =>     vim /etc/rc.local
  vim `f rc conf`  =>     vim /etc/rc.conf
```

_Fasder_ comes with some useful aliases by default:

```sh
alias a='fasder -a'        # any
alias s='fasder -si'       # show / search / select
alias d='fasder -d'        # directory
alias f='fasder -f'        # file
alias sd='fasder -sid'     # interactive directory selection
alias sf='fasder -sif'     # interactive file selection
alias z='fasder_cd -d'     # cd, same functionality as j in autojump
alias zz='fasder_cd -d -i' # cd with interactive selection
```

Fasder will smartly detect when to display a list of files or just the best
match. For instance, when you call fasder in a subshell with some search
parameters, fasder will only return the best match. This enables you to do:

```sh
mv update.html `d www`
cp `f mov` .
```

# Install

Fasder is a self-contained POSIX shell script that can be either sourced or
executed. A Makefile is provided to install `fasder` and `fasder.1` to the
desired places.

System-wide install:

    make install

Install to $HOME:

    PREFIX=$HOME make install

Or alternatively you can just copy `fasder` anywhere you like (preferably
under some directory in your `$PATH`).

To get fasder working in a shell, some initialization code must be run. Put the
following line in your shell rc:

```sh
eval "$(fasder --init auto)"
```

This will setup a command hook that executes on every command as well as
advanced tab completion for zsh and bash.

If you want more control over what gets into your shell environment, you can
pass a customized set of arguments to `fasder --init`.

```
zsh-hook             # define _fasder_preexec and add it to zsh preexec array
zsh-ccomp            # zsh command mode completion definitions
zsh-ccomp-install    # setup command mode completion for zsh
zsh-wcomp            # zsh word mode completion definitions
zsh-wcomp-install    # setup word mode completion for zsh
bash-hook            # add hook code to bash $PROMPT_COMMAND
bash-ccomp           # bash command mode completion definitions
bash-ccomp-install   # setup command mode completion for bash
posix-alias          # define aliases that applies to all posix shells
posix-hook           # setup $PS1 hook for shells that's posix compatible
tcsh-alias           # define aliases for tcsh
tcsh-hook            # setup tcsh precmd alias
```

Example for a minimal zsh setup (no tab completion):

```sh
eval "$(fasder --init posix-alias zsh-hook)"
```

Note that this method will slightly increase your shell start-up time, since
calling binaries has overhead. You can cache fasder init code if you want minimal
overhead. Example code for bash (to be put into .bashrc):

```sh
fasd_cache="$HOME/.fasder-init-bash"
if [ "$(command -v fasder)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
  fasder --init posix-alias bash-hook bash-ccomp bash-ccomp-install >| "$fasd_cache"
fi
source "$fasd_cache"
unset fasd_cache
```

Optionally, you can also source `fasder` if you want `fasder` to be a shell
function instead of an executable.

You can tweak the initialization code. For instance, if you want to use "c"
instead of "z" to do directory jumping, you can use the alias below:

```sh
alias c='fasder_cd -d'
# `-d` option present for bash completion
# function fasder_cd is defined in posix-alias
```

After you install fasder, warm up the fasder database by opening some files
(with any program) as you `cd` around your filesystem. Then try some of the
examples below.

# Examples

```sh
f foo           # list frecent files matching foo
a foo bar       # list frecent files and directories matching foo and bar
f js$           # list frecent files that ends in js
f -e vim foo    # run vim on the most frecent file matching foo
mplayer `f bar` # run mplayer on the most frecent file matching bar
z foo           # cd into the most frecent directory matching foo
open `sf pdf`   # interactively select a file matching pdf and launch `open`
```

You can add your own aliases to fully utilize the power of fasder. Here are
some examples to get you started:

```sh
alias v='f -e vim' # quick opening files with vim
alias m='f -e mplayer' # quick opening files with mplayer
alias o='a -e xdg-open' # quick opening files with xdg-open
```

If you're using bash, you have to call `_fasder_bash_hook_cmd_complete` to make
completion work. For instance:

    _fasder_bash_hook_cmd_complete v m j o

You can select an entry in the list of matching files.

# Matching

Fasder has three matching modes: default, case-insensitive, and fuzzy.

For a given set of queries (groups of command-line arguments passed to fasder),
a pathname is a match if and only if:

1. Queries match the path *in order*.
2. The last query matches the *last segment* of the path.

If no match is found, fasder will try the same process ignoring case. Failing
this, fasder will allow extra characters to be placed between query
characters for fuzzy matching.

Tips:

* If you want your last query not to match the last segment of the path, append
  `/` to the last query.
* If you want your last query to match the end of the filename, append `$` to
  the last query.

# How It Works

When you initialize the fasder system (typically through your shell config
scripts), fasder creates a hook function which will be executed after 
every shell command. The hook will scan your commands for file
and directory names and add them to its database. 

# Compatibility

Fasder's basic functionalities are POSIX compliant, meaning that you should be
able to _use_ fasder in all POSIX compliant shells. Your shell needs to support
command substitution in `$PS1` in order to automatically track your
commands and files. This feature is not specified by the POSIX standard, but
is present in many POSIX-compliant shells. In shells without
prompt command or prompt command substitution (csh for instance), you can add
entries manually with `fasder -A`. You are most welcome to contribute shell
initialization code for shells not yet supported.

Fasder has been tested on the following shells: bash, zsh, mksh, pdksh, dash,
busybox ash, FreeBSD 9 /bin/sh and OpenBSD /bin/sh.

Fasder is written in bash-4.1; you need a bash interpreter at least as new.
Basically, we've traded in the POSIX compatibility of _fasd_ for Bash's greater
range of built-in features to "squeeze" the script for faster performance.

# Synopsis

    fasder [options] [query ...]
    [f|a|s|d|z] [options] [query ...]
      options:
        -s         list paths with scores
        -l         list paths without scores
        -i         interactive mode
        -e <cmd>   set command to execute on the result file
        -b <name>  only use <name> backend
        -B <name>  add additional backend <name>
        -a         match files and directories
        -d         match directories only
        -f         match files only
        -r         match by rank only
        -t         match by recent access only
        -R         reverse listing order
        -h         show a brief help message
        -[0-9]     select the nth entry

    fasder [-A|-D] [paths ...]
        -A    add paths
        -D    delete paths

# Tab Completion

Fasder offers two completion modes: command completion and word 
completion. Command completion works in bash and zsh. Word 
completion only works in zsh.

Command completion is just like completion for any other command. It is
triggered when you hit tab on a `fasd` command or its aliases. Under this mode
your queries can be separated by a space. Tip: if you find that the completion
result overwrites your queries, type an extra space before you hit tab.

Word completion can be triggered on *any* command. Word completion is
triggered by any command line argument that starts with `,` (all), `f,`
(files), or `d,` (directories), or that ends with `,,` (all), `,,f` (files), or
`,,d` (directories). Examples:

    $ vim ,rc,lo<Tab>
    $ vim /etc/rc.local

    $ mv index.html d,www<Tab>
    $ mv index.html /var/www/

There are also three zle widgets: `fasder-complete`, `fasder-complete-f`,
`fasder-complete-d`. You can bind them to any keybindings you like:

```sh
bindkey '^X^A' fasder-complete    # C-x C-a to do fasder-complete (files and directories)
bindkey '^X^F' fasder-complete-f  # C-x C-f to do fasder-complete-f (only files)
bindkey '^X^D' fasder-complete-d  # C-x C-d to do fasder-complete-d (only directories)
```

# Backends

Fasder can take advantage of different sources of recent / frequent files. Most
desktop environments (such as OS X and Gtk) and some editors (such as Vim) keep
a list of accessed files. Fasder can use them as additional backends if the data
can be converted into fasder's native format. Below is a list of available
backends.

```
`spotlight`
OSX spotlight, provides entries that were changed today or opened within the
past month

`recently-used`
GTK's recently-used file (Usually available on Linux)

`current`
Provides everything in $PWD (wherever you are executing `fasder`)

`viminfo`
Vim's editing history, useful if you want to define an alias just for editing
things in vim
```

You can define your own backend by declaring a function by that name in your
`.fasdrc`. You can set default backend with `_FASD_BACKENDS` variable in your
`.fasdrc`.

Fasder can mimic [v](http://github.com/rupa/v)'s behavior by this alias:

```sh
alias v='f -t -e vim -b viminfo'
```

# Configuration settings

The following shell variables can be set before sourcing `fasder`. You can set them
in `$HOME/.fasdrc`

```
$_FASD_DATA
Path to the fasder data file, default "$HOME/.fasd".

$_FASD_BLACKLIST
List of "blacklisted" strings. Commands matching them will not be processed.
Default is "--help".

$_FASD_SHIFT
List of all command names that need to be shifted; defaults to "sudo busybox".

$_FASD_IGNORE
List of all commands that will be ignored; defaults to "fasder ls echo".

$_FASD_TRACK_PWD
Fasder tracks your "$PWD" by default. Set this to 0 to disable this behavior.

$_FASD_AWK
The awk program to use. Fasder can detect and use a compatible awk.

$_FASD_SINK
Log file to capture the standard error; defaults to "/dev/null".

$_FASD_MAX
Maximum total score / weight; defaults to 2000.

$_FASD_SHELL
The shell to execute. Some shells will run faster than others. fasder
runs faster with dash and ksh variants.

$_FASD_BACKENDS
Default backends. (See the "backends" section above.)

$_FASD_RO
If set to any non-empty string, fasder will not add or delete entries from
the database. You can set and export this variable from the command line.

$_FASD_FUZZY
Level of "fuzziness" when doing fuzzy matching. More precisely, the number of
characters that can be skipped to generate a match. Set to empty or 0 to
disable fuzzy matching. Default value is 2.

$_FASD_VIMINFO
Path to .viminfo file for viminfo backend; defaults to "$HOME/.viminfo"

$_FASD_RECENTLY_USED_XBEL
Path to XDG recently-used.xbel file for recently-used backend, defaults to
"$HOME/.local/share/recently-used.xbel"

```

# Debugging

If fasder does not work as expected, please file a bug report describing the
unexpected behavior along with your OS version, shell version, awk version, sed
version, and a log file.

You can set `_FASD_SINK` in your `.fasdrc` to obtain a log.

```sh
_FASD_SINK="$HOME/.fasd.log"
```

# COPYING

Fasder is adapted from Wei Dai's [fasd](https://github.com/clvv/fasd) project.
Fasd is based on code from [z](https://github.com/rupa/z) by
rupa deadwyler under the WTFPL license. Most if not all of the code has been
rewritten. Fasder is licensed under the "MIT/X11" license.

###### This document is adapted from the README for the original fasd project.

# Please see also:

[Thoughts about a faster "fasder"](https://github.com/clarity20/fasder/wiki/Thoughts-about-a-faster-%22fasder%22)

### TODO

* Discuss the optimization strategies employed.
* Discuss the remaining bottlenecks in the prompt hook: the call to mapfile,
the "heaviness" of forking a process under Cygwin, and the extra burden when 
context-switching into a Cygwin shell (especially the DLLs) from the outside.
* Optimization work thus far has focused on the prompt hook and the `--add`
and `--query` options. For the other options, there is still plenty of low-hanging
fruit.
* There are many style issues: Comments and variable names can be made better,
for example. Sub-functions can be extracted. Low-hanging fruit here too.
* Implement a --clean option to delete duplicate entries and entries no longer
present in the filesystem
* Inventory the open issues and PRs of the original fasd project
for anything we might wish to address here.
* Develop a more thorough, systematic testing process. There are two classes of use cases:
(1) the hidden action of the \_fasder_prompt_func (the prompt hook) and 
(2) the explicit invocation of fasder or its short aliases. Regarding the former,
the script's dependency on a `PROMPT_COMMAND` whose exact behavior
changes whenever we edit the script makes testing challenging; the situation is akin to
the observer effect familiar to physicists. As a workaround, we could
structure our test rig to invoke "fasder --proc <cmd>" directly for each test
case while we monitor the effects this has on a suitably mocked-up data file.
OTOH, the "type 2" use cases wherein fasder is explicitly called should be easier to test.
* The original fasd contains notes about downloading it through package managers 
or the project website. Consider pursuing either or both of these for fasder.

