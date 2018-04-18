# TerminalSaveR
Shell script to trim exported *R* terminal output into a more user-friendly, readable file.

# General Useage
* The first (and only) argument is required and refers to the text file generated from the *R* terminal session.
* R commands, prefixed by ">" which is default for my terminal setup, are retained.
* Up to 5 lines of output following each command are retained.
* Prefixed ">" are removed and prefixed "#" are added to the final trimmed file.
