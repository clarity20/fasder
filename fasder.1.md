% FASDER(1) fasd user manual
% Wei Dai <x@wei23.net>, Michael Wood
% Jul 16, 2012. Revised March 9, 2017.

# NAME

fasder - quick access to files and directories

# SYNOPSIS

fasder [options] [query ...]

[f|a|s|d|z] [options] [query ...]

fasder [-A|-D] [paths ...]

# OPTIONS

    -s         list paths with ranks
    -l         list paths without ranks
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

# DESCRIPTION

Fasder keeps track of files and directories you access in your shell and gives you
quick access to them. You can use fasder to reference files or directories by just
a few key identifying characters. You can use fasder to boost your command line
productivity by defining your own aliases to launch programs on files or
directories. Fasder, by default, provides some basic aliases, including a shell
function "z" that resembles the functionality of "z" and "autojump."

The name "fasd(er)" comes from the default suggested aliases `f`(files),
`a`(files/directories), `s`(show/search/select), `d`(directories).

Fasder ranks files and directories by "frecency," that is, by both "frequency"
and "recency." The term "frecency" was first coined by Mozilla and used in
Firefox.

# EXAMPLES

    z bundle
    f -e vim nginx conf
    f -i rc$
    vi `f nginx conf`
    cp update.html `d www`
    open `sf pdf`

# SHELL INITIALIZATION

To get fasder working in a shell, some initialization code must be run. Put
lines below in your POSIX compatible shell rc.

    eval "$(fasder --init auto)"

This will setup a command hook that executes on every command and advanced tab
completion for zsh and bash.

If you want more control over what gets into your shell environment, you can
pass customized set of arguments to `fasder --init`.

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

Example for a minimal zsh setup (no tab completion):

    eval "$(fasder --init posix-alias zsh-hook)"

Note that this method will slightly increase your shell start-up time, since
calling binaries has overhead. You can cache fasder init code if you want
minimal overhead. Example code for bash (to be put into .bashrc):

    fasder_cache="$HOME/.fasd-init-bash"
    if [ "$(command -v fasder)" -nt "$fasder_cache" -o ! -s "$fasder_cache" ]; then
      fasder --init posix-alias bash-hook bash-ccomp bash-ccomp-install >| "$fasder_cache"
    fi
    source "$fasder_cache"
    unset fasder_cache

Optionally, if you can also source `fasder` if you want `fasder` to be a shell
function instead of an executable.

You can tweak initialization code. For instance, if you want to use "c"
instead of "z" to do directory jumping, you can use the alias below:

    alias c='fasder_cd -d'
    # `-d' option present for bash completion
    # function fasder_cd is defined in posix-alias

# MATCHING

Fasder has three matching modes: default, case-insensitive, and fuzzy.

For a given set of queries (the set of command-line arguments passed to fasder),
a path is a match if and only if:

1. Queries match the path in order.
2. The last query matches the last segment of the path.

If no match is found, fasder will try the same process ignoring case. If still no
match is found, fasder will allow extra characters to be placed between query
characters for fuzzy matching.

Tips:

* If you want your last query not to match the last segment of the path, append
  `/' as the last query.
* If you want your last query to match the end of the filename, append `$' to
  the last query.

# COMPATIBILITY

Fasder's basic functionalities are POSIX compliant, meaning that you should be
able to use fasder in all POSIX compliant shells. Your shell need to support
command substitution in $PS1 in order for fasder to automatically track your
commands and files. This feature is not specified by the POSIX standard, but
it's nonetheless present in many POSIX compliant shells. In shells without
prompt command or prompt command substitution (tcsh for instance), you can add
entries manually with "fasder -A". You are very welcomed to contribute shell
initialization code for not yet supported shells.

# TAB COMPLETION

Fasder offers two completion modes, command mode completion and word mode
completion. Command mode completion works in bash and zsh. Word mode
completion only works in zsh.

Command mode completion is just like completion for any other commands. It is
triggered when you hit tab on a fasder command or its aliases. Under this mode
your queries can be separated by a space. Tip: if you find that the completion
result overwrites your queries, type an extra space before you hit tab.

Word mode completion can be triggered on *any* command. Word completion is
triggered by any command line argument that starts with "," (all), "f,"
(files), or "d," (directories), or that ends with ",," (all), ",,f" (files),
or ",,d" (directories). Examples:

    $ vim ,rc,lo<Tab>
    $ vim /etc/rc.local

    $ mv index.html d,www<Tab>
    $ mv index.html /var/www/

There are also three zle widgets: "fasder-complete", "fasder-complete-f",
"fasder-complete-d". You can bind them to keybindings you like:

    bindkey '^X^A' fasder-complete    # C-x C-a to do fasder-complete (files and directories)
    bindkey '^X^F' fasder-complete-f  # C-x C-f to do fasder-complete-f (only files)
    bindkey '^X^D' fasder-complete-d  # C-x C-d to do fasder-complete-d (only directories)

# BACKENDS

Fasder can take advantage of different sources of recent / frequent files. Most
desktop environments (such as OS X and Gtk) and some editors (such as Vim) keep
a list of accessed files. Fasder can use them as additional backends if the data
can be converted into fasder's native format. Below is a list of available
backends.

* spotlight: OSX spotlight, provides entries that are changed today or opened
  within the past month

* recently-used: GTK's recently-used file (Usually available on Linux)

* current: Provides everything in $PWD (whereever you are executing `fasder`)

* viminfo: Vim's editing history, useful if you want to define an alias just
  for editing things in vim

You can define your own backend by declaring a function by that name in your
`.fasdrc`. You can set default backend with `_FASD_BACKENDS` variable in our
`.fasdrc`.

# TWEAKS

Upon every execution, fasder will source "/etc/fasdrc" and "$HOME/.fasdrc" if
they are present. Below are some variables you can set:

    $_FASD_DATA
    Path to the fasder data file, default "$HOME/.fasd".

    $_FASD_BLACKLIST
    List of blacklisted strings. Commands matching them will not be processed.
    Default is "--help".

    $_FASD_SHIFT
    List of all commands that needs to be shifted, defaults to "sudo busybox".

    $_FASD_IGNORE
    List of all commands that will be ignored, defaults to "fasder ls echo".

    $_FASD_TRACK_PWD
    Fasder defaults to track your "$PWD". Set this to 0 to disable this behavior.

    $_FASD_AWK
    Which awk to use. fasder can detect and use a compatible awk.

    $_FASD_SINK
    File to log all STDERR to, defaults to "/dev/null".

    $_FASD_MAX
    Max total score / weight, defaults to 2000.

    $_FASD_SHELL
    Which shell to execute. Some shells will run faster than others. fasder
    runs faster with dash and ksh variants.

    $_FASD_BACKENDS
    Default backends.

    $_FASD_RO
    If set to any non-empty string, fasder will not add or delete entries from
    database. You can set and export this variable from command line.

    $_FASD_FUZZY
    Level of "fuzziness" when doing fuzzy matching. More precisely, the number of
    characters that can be skipped to generate a match. Set to empty or 0 to
    disable fuzzy matching. Default value is 2.

    $_FASD_VIMINFO
    Path to .viminfo file for viminfo backend, defaults to "$HOME/.viminfo"

    $_FASD_RECENTLY_USED_XBEL
    Path to XDG recently-used.xbel file for recently-used backend, defaults to
    "$HOME/.local/share/recently-used.xbel"

# DEBUGGING

Fasder is hosted on GitHub: https://github.com/clarity20/fasder

If fasder does not work as expected, please file a bug report on GitHub describing
the unexpected behavior along with your OS version, shell version, awk version,
sed version, and a log file.

You can set `_FASD_SINK` in your `.fasdrc` to obtain a log.

    _FASD_SINK="$HOME/.fasd.log"

# COPYING

Fasder is descended from fasd.
Fasd was originally written based on code from z (https://github.com/rupa/z) by
rupa deadwyler under the WTFPL license. Most if not all of the code has been
rewritten. Fasder is licensed under the "MIT/X11" license.

