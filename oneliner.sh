#!/bin/bash

NAME="oneliner"
VERSION="0.001"
AUTHOR="budRich"
CONTACT='robstenklippa@gmail.com'
CREATED="2018-07-21"
UPDATED="2018-07-21"

THIS_DIR="$( cd "$( dirname "$(readlink "${BASH_SOURCE[0]}")" )" && pwd )"

main(){
  incstring=pel
  declare -A i3list
  eval "$(i3list)"
  cmd="rofi -dmenu -theme <(themefile) " 

  while getopts :vhi:x:y:w:c:p:o:l:t:nf: option; do
    case "${option}" in
      i) incstring="${OPTARG}" ;;
      x) xpos=${OPTARG}        ;;
      y) ypos=${OPTARG}        ;;
      w) width=${OPTARG}       ;;
      o) opts="${OPTARG}"      ;;
      p) prompt="${OPTARG}"    ;;
      n) 

         xpos=$((i3list[AWX]-i3list[WSX]))
         ypos=$((i3list[AWY]-i3list[WSY]))
         width=${i3list[AWW]}

         ;;

      c) colors=${OPTARG}      ;;
      f) cmd+="-filter '${OPTARG}' "      ;;
      l) list="${OPTARG}"      ;;
      t) top="${OPTARG}"       ;;
      
      v) printf '%s\n' \
           "$NAME - version: $VERSION" \
           "updated: $UPDATED by $AUTHOR"
         exit ;;
      h|*) printinfo && exit ;;
    esac
  done

  [[ $colors = l ]] && {
    cmd+="-theme-str '*{
      background-color:    @act2;
      border-color:        @act2;
      text-color:          @act3;
      selbg:               @act3;
      selfg:               @act2;
      promptbg:            @act3;
      promptfg:            @act2;
      font:                @font1; 
    }' "
  }

  [[ $colors = r ]] && {
    cmd+="-theme-str '*{
      background-color:    @red;
      border-color:        @red;
      text-color:          @act2;
      selbg:               @act3;
      selfg:               @act2;
      promptbg:            @act2;
      promptfg:            @red;
      font:                @font1; 
    }' "
  }

  [[ $colors = d ]] && {
    cmd+="-theme-str '*{
      background-color:    @act3;
      border-color:        @act3;
      text-color:          @act2;
      selbg:               @act2;
      selfg:               @act3;
      promptbg:            @act2;
      promptfg:            @act3;
      font:                @font1; 
    }' "
  }

  [[ -n $prompt ]] \
    && cmd+="-p ${prompt} " \
    || incstring=${incstring/[p]/}

  [[ -z $list ]] && {
    incstring=${incstring/[l]/}
    cmd+="-theme-str '#entry {expand: true; width: 0; }' "
  } || {
    cmd+="-theme-str '#listview {
      layout:     horizontal;
      spacing:    5px;
      lines:      $(echo "${list}" | wc -l);
      dynamic:    true;
    }' "
  }

  [[ $incstring =~ [p] ]] && inc+=(prompt)
  [[ $incstring =~ [e] ]] && inc+=(entry)
  [[ $incstring =~ [l] ]] && inc+=(listview)

  incstring=${inc[*]}

  cmd+="-theme-str "
  cmd+="'#horibox {children: [${incstring//' '/','}];}' "

  [[ -n $xpos ]] \
    && cmd+="-theme-str '#window {x-offset: ${xpos}px;}' "

  [[ -n $ypos ]] \
    && cmd+="-theme-str '#window {y-offset: ${ypos}px;}' "

  [[ -n $width ]] && {
    [[ $width =~ [%]$ ]] || width=${width}px
    cmd+="-theme-str '#window {width: ${width};}' "
  }
  
  if [[ -n $list ]];then
    printf '%s\n' "${top}" "__START" "${list}" | awk '
    {
      if (start==1) {
        for (t in tops) {
          if ($0==tops[t]){tfnd[NR]=$0} 
        }
        if (tfnd[NR]!=$0) {lst[NR]=$0}
      }
      if ($0=="__START") {start=1}
      if (start!=1) {tops[NR]=$0;nums++}
    }

    END {
      for (f in tfnd){if (tfnd[f]){print tfnd[f]}}
      for (l in lst){print lst[l]}
    }
    '
  fi | eval "${cmd} ${opts}"
}

themefile(){
  cat "${THIS_DIR}/themevars.rasi"
  ((i3list[AWB]>=20)) \
    && sed "s/.*height[:].*/height: ${i3list[AWB]}px;/" \
       "${THIS_DIR}/oneliner.rasi" \
    || cat "${THIS_DIR}/oneliner.rasi" 
}

printinfo(){
about='`oneliner` - Wrapper for displaying oneline rofi menus

SYNOPSIS
--------

`oneliner` [`-v`|`-h`]  
`oneliner` `-i` [pel]  
`oneliner` `-x` XPOS  
`oneliner` `-y` YPOS  
`oneliner` `-w` WIDTH[%]  
`oneliner` `-o` OPTIONS  
`oneliner` `-p` prompt  
`oneliner` `-n`   
`oneliner` `-c` d|l|r  
`oneliner` `-f` filter  
`oneliner` `-l` LIST  
`oneliner` `-t` TOP  


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

`-i` [pel]  
(default: pel)  
Argument for this option is a string containing the
characters `pel`. It will force the appearance of the
menu. Example:  

`$ oneliner -i pl -l "$(printf '%s\n' one two three)"`  
Without e (entrybox), the entrybox of the menu will 
not be available, only the list. The prompt will also 
be hidden with the example above.  

`$ oneliner -i l -l "$(printf '%s\n' one two three)" -p "enter: "`  
The command above would have the same result as the first
example, since p (prompt) is left out from the argument
to `-i`  

`-x` XPOS  
`-y` YPOS  
`-w` WIDTH[%]  
`-n`   
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

`-o` OPTIONS  
The argument is a string of aditional options to pass
to `rofi`  


`-c` d|l  
specify d or l for dark or light theme.

`-f` filter  
`-p` prompt  

`-l` LIST  
Every line in LIST will be displayed as a menu item.
The order will be the same as entered if not `-t` 
is set.

`-t` TOP  
If a line in TOP matches a line in LIST, that line
will have priority in the menu.

Example:  

``` text
$ oneliner -l "$(print '%s\n' one two three four)" \
           -t "$(print '%s\n' two four)"
```

will result in a list looking like this:  
`two four one three`

DEPENDENCIES
------------

rofi
i3list
'

bouthead="
${NAME^^} 1 ${CREATED} Linux \"User Manuals\"
=======================================

NAME
----
"

boutfoot="
AUTHOR
------

${AUTHOR} <${CONTACT}>
<https://budrich.github.io>

SEE ALSO
--------

rofi(1),i3list(1)
"


  case "$1" in
    m ) printf '%s' "# ${about}" > "${THIS_DIR}/README.md" ;;
    
    f ) 
      printf '%s' "${bouthead}"
      printf '%s' "${about}"
      printf '%s' "${boutfoot}"
    ;;

    ''|* ) 
      printf '%s' "${about}" | awk '
         BEGIN{ind=0}
         $0~/^```/{
           if(ind!="1"){ind="1"}
           else{ind="0"}
           print ""
         }
         $0!~/^```/{
           gsub("[`*]","",$0)
           if(ind=="1"){$0="   " $0}
           print $0
         }
       '
    ;;
  esac
}

ERR(){ >&2 echo "[WARNING]" $@; }
ERX(){ >&2 echo "[ERROR]" $@ && exit 1 ; }

if [ "$1" = "md" ]; then
  printinfo m
  exit
elif [ "$1" = "man" ]; then
  printinfo f
  exit
else
  main "${@}"
fi
