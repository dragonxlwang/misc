# misc
miscellaneous stuffs

## Shell special variables
|----------|---------------------------------------------------|
|$1 - $9   |these variables are the positional parameters.      |
| $0       |the name of the command currently being executed.   |
| $#       |the number of positional arguments given to this invocation of the shell. |
| $?       |exit status of the last command executed as a decimal string. it returns 0 upon success. |
| $$       |Process ID of shell - useful for including in filenames, to make them unique. |
| $!       |Process ID of last process run in the background using ampersand (&) operator. |
| $-       |A list of all shell flags currently enabled. |
| $_       |Name of last command. |
| $*       |Complete list of arguments passed to the shell, separated by the first character of 
            the IFS (input field separators) variable., starting at $1. |
| $@       | same as above, separated by spaces. |

[1](https://developer.apple.com/library/mac/documentation/OpenSource/Conceptual/ShellScripting/SpecialShellVariables/SpecialShellVariables.html)
[2](http://sillydog.org/unix/scrpt/scrpt2.2.2.php)
[3](http://www.tutorialspoint.com/unix/unix-special-variables.htm)
