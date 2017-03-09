Fasder is a self-contained posix shell script that can be either sourced or
executed. A Makefile is provided to install `fasder` and `fasder.1` in 
the desired locations.


System-wide install:

    make install

Install to $HOME:

    PREFIX=$HOME make install

Or alternatively you can just copy `fasder` anywhere you like.

To get fasder working in a shell, some initialization code must be run. Put the
following line in your shell rc.

    eval "$(fasder --init auto)"

This will set up a command hook that executes on every command and advanced tab
completion for zsh and bash.

If you want more control over what gets into your shell environment, you can
pass a custom set of arguments to `fasder --init`:

    zsh-hook             # define _fasder_preexec and add it to zsh preexec array
    zsh-ccomp            # zsh command mode completion definitions
    zsh-ccomp-install    # setup command mode completion for zsh
    zsh-wcomp            # zsh word mode completion definitions
    zsh-wcomp-install    # setup word mode completion for zsh
    bash-hook            # add hook code to bash $PROMPT_COMMAND
    bash-ccomp           # bash command mode completion definitions
    bash-ccomp-install   # setup command mode completion for bash
    posix-alias          # define alias that applies to all posix shells
    posix-hook           # setup $PS1 hook for shells that's posix compatible
    tcsh-alias           # define aliases for tcsh
    tcsh-hook            # setup tcsh precmd alias

Example for a minimal zsh setup (no tab completion):

    eval "$(fasder --init posix-alias zsh-hook)"

Note that this method will slightly increase your shell start-up time, since
calling binaries has overhead. You can cache fasder init code if you want minimal
overhead. Example code for bash (to be put into .bashrc):

    fasder_cache="$HOME/.fasd-init-bash"
    if [ "$(command -v fasder)" -nt "$fasder_cache" -o ! -s "$fasder_cache" ]; then
      fasder --init posix-alias bash-hook bash-ccomp bash-ccomp-install >| "$fasder_cache"
    fi
    source "$fasder_cache"
    unset fasder_cache

Optionally, you can also source `fasder` if you want `fasder` to be a shell
function instead of an executable.

You can tweak the initialization code. For instance, if you want to use "c"
instead of "z" to do directory jumping, run the code below:

    # function to execute built-in cd
    fasder_cd() {
      if [ $# -le 1 ]; then
        fasder "$@"
      else
        local _fasder_ret="$(fasder -e echo "$@")"
        [ -z "$_fasder_ret" ] && return
        [ -d "$_fasder_ret" ] && cd "$_fasder_ret" || echo "$_fasder_ret"
      fi
    }
    alias c='fasder_cd -d' # `-d' option present for bash completion

