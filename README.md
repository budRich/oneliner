# `oneliner` - Wrapper for displaying oneline rofi menus

SYNOPSIS
--------

`oneliner` `-v`|`--version`  
`oneliner` `-h`|`--help`  
`oneliner` `-i`|`--include` [pel]  
`oneliner` `-x`|`--xpos` XPOS  
`oneliner` `-y`|`--ypos` YPOS  
`oneliner` `-w`|`--width` WIDTH[%]  
`oneliner` `-o`|`--options` OPTIONS  
`oneliner` `-p`|`--prompt` prompt  
`oneliner` `-n`|`--titlebar`   
`oneliner` `-c`|`--color` d|l|r  
`oneliner` `-f`|`--filter` filter  
`oneliner` `-l`|`--list` LIST  
`oneliner` `-t`|`--top` TOP  


DESCRIPTION
-----------

`oneliner` wraps the options i use the most with 
`rofi` and make it easy to set different colorthemes 
and positions for the menu.

It is also possible to pass a LIST, in which each line
will be displayed as an item in the menu. The list
can be *sorted* with the TOP option.  

The foundation for the appearance of the menus are
the themefiles (*oneliner.rasi*|*themevars.rase*),
but depending on the options passed to `oneliner`
certain values of the themefiles will get overwritten.  

If no prompt (`-p`) is given, the prompt element will be 
completely removed from the menu, likewise with the list.
To force which parts of the menu to be visible or hidden,
one can specify that with the `-i` option.

OPTIONS
-------

`-v`|`--version`  
Show version and exit.

`-h`|`--help`  
Show help and exit.

`-i`|`--include` [pel]  
(default: pel)  
Argument for this option is a string containing the
characters `pel`. It will force the appearance of the
menu. Example:  

`$ oneliner -i pl -l "$(printf %sn one two three)"`  
Without e (entrybox), the entrybox of the menu will 
not be available, only the list. The prompt will also 
be hidden with the example above.  

`$ oneliner -i l -l "$(printf %sn one two three)" -p "enter: "`  
The command above would have the same result as the first
example, since p (prompt) is left out from the argument
to `-i`  

`-x`|`--xpos` XPOS  
`-y`|`--ypos` YPOS  
`-w`|`--width` WIDTH[%]  
`-n`|`--titlebar`   
(default: `-x 0, -y 0, -w 100%`)
These options override the default position and width
of the menu. If `-n` is set, the menu will have the
same position as the top left corner of the active window
and the same width as the window. If both `-n` and 
`-y 50` is set, the menu will be placed 50pixels below
the active window.  

If the argument to `-w` (width) ends with a `%` character
the width will be that many percentages of the screenwidth.
Without `%` absolute width in pixels will be used.  

`-o`|`--options` OPTIONS  
The argument is a string of aditional options to pass
to `rofi`  


`-c`|`--color` d|l  
specify d or l for dark or light theme.

`-f`|`--filter` filter  
`-p`|`--prompt` prompt  

`-l`|`--list` LIST  
Every line in LIST will be displayed as a menu item.
The order will be the same as entered if not `-t` 
is set.

`-t`|`--top` TOP  
If a line in TOP matches a line in LIST, that line
will have priority in the menu.

Example:  

``` text
$ oneliner -l "$(printf '%s\n' one two three four)" \
           -t "$(printf '%s\n' two four)"
```

will result in a list looking like this:  
`two four one three`

DEPENDENCIES
------------

rofi  
i3list  
