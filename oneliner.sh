#!/usr/bin/env bash

__name="oneliner"
__version="0.002"
__author="budRich"
__contact='robstenklippa@gmail.com'
__created="2018-07-21"
__updated="2018-09-15"

main(){
  local option optarg kol lopt sopt o

  # globals
  __incstring=pel
  __cmd="rofi -dmenu -theme <(themefile) " 

  declare -A i3list
  eval "$(i3list)"

  declare -A options

  options[version]=v
  options[help]=h::
  options[xpos]=x:
  options[ypos]=y:
  options[width]=w:
  options[color]=c:
  options[filter]=f:
  options[include]=i:
  options[options]=o:
  options[prompt]=p:
  options[titlebar]=n
  options[list]=l:
  options[top]=t:

  for o in "${!options[@]}"; do
    [[ ${options[$o]} =~ ([:]*)$ ]] \
      && kol="${BASH_REMATCH[1]:-}"
    lopt+="$o$kol,"
    sopt+="${options[$o]}"
  done

  eval set -- "$(getopt --name "$__name" \
    --options "$sopt" \
    --longoptions "$lopt" \
    -- "$@"
  )"

  while true; do
    [[ $1 = -- ]] && option="$1" || {
      option="${1##--}" 
      option="${option##-}"
      optarg="${2:-}" 
    }

    case "$option" in
      v | version ) printinfo version  ; exit ;;
      h | help    ) printinfo "${optarg}" ; exit ;;
      
      i|include  ) __incstring="${optarg}"  && shift     ;;
      x|xpos     ) __xpos=${optarg} && shift             ;;
      y|ypos     ) __ypos=${optarg}  && shift            ;;
      w|width    ) __width=${optarg} && shift            ;;
      o|options  ) __opts="${optarg}" && shift           ;;
      p|prompt   ) __prompt="${optarg}" && shift         ;;
      n|titlebar ) 
         __xpos=$((i3list[AWX]-i3list[WSX]))
         __ypos=$((i3list[AWY]-i3list[WSY]))
         __width=${i3list[AWW]}
        ;;
      c|color    ) __colors=${optarg} && shift           ;;
      f|filter   ) __cmd+="-filter '${optarg}' " && shift;;
      l|list     ) __list="${optarg}" && shift           ;;
      t|top      ) __top="${optarg}" && shift            ;;

      -- ) shift ; break ;;
      *  ) break ;;
    esac
    shift
  done

  [[ -n $__stdin ]] && __list="${__stdin}"


  [[ $__colors = l ]] && {
    __cmd+="-theme-str '*{
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

  [[ $__colors = r ]] && {
    __cmd+="-theme-str '*{
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

  [[ $__colors = d ]] && {
    __cmd+="-theme-str '*{
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

  [[ -n $__prompt ]] \
    && __cmd+="-p ${__prompt} " \
    || __incstring=${__incstring/[p]/}

  [[ -z $__list ]] && {
    __incstring=${__incstring/[l]/}
    __cmd+="-theme-str '#entry {expand: true; width: 0; }' "
  } || {
    __cmd+="-theme-str '#listview {
      layout:     horizontal;
      spacing:    5px;
      lines:      $(echo "${__list}" | wc -l);
      dynamic:    true;
    }' "
  }

  [[ $__incstring =~ [p] ]] && inc+=(prompt)
  [[ $__incstring =~ [e] ]] && inc+=(entry)
  [[ $__incstring =~ [l] ]] && inc+=(listview)

  __incstring=${inc[*]}

  __cmd+="-theme-str "
  __cmd+="'#horibox {children: [${__incstring//' '/','}];}' "

  [[ -n $__xpos ]] \
    && __cmd+="-theme-str '#window {x-offset: ${__xpos}px;}' "

  [[ -n $__ypos ]] \
    && __cmd+="-theme-str '#window {y-offset: ${__ypos}px;}' "

  [[ -n $__width ]] && {
    [[ $__width =~ [%]$ ]] || __width=${__width}px
    __cmd+="-theme-str '#window {width: ${__width};}' "
  }
  
  if [[ -n $__list ]];then
    printf '%s\n' "${__top}" "__START" "${__list}" | awk '
    {
      if (start==1) {
        for (t in tops) {
          if ($0==tops[t]){tfnd[NR]=$0;topa[t]=$0} 
        }
        if (tfnd[NR]!=$0) {lst[NR]=$0}
      }
      if ($0=="__START") {start=1}
      if (start!=1) {tops[NR]=$0;nums++}
    }

    END {
      for (f in topa){if (topa[f]){print topa[f]}}
      for (l in lst){print lst[l]}
    }
    '
  fi | eval "${__cmd} ${__opts}"
}

themefile(){
  cat "${__dir}/themevars.rasi"
  ((i3list[AWB]>=20)) \
    && sed "s/.*height[:].*/height: ${i3list[AWB]}px;/" \
       "${__dir}/oneliner.rasi" \
    || cat "${__dir}/oneliner.rasi" 
}

printinfo(){
about=\
'`oneliner` - Wrapper for displaying oneline rofi menus

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

`$ oneliner -i pl -l "$(printf '%s\n' one two three)"`  
Without e (entrybox), the entrybox of the menu will 
not be available, only the list. The prompt will also 
be hidden with the example above.  

`$ oneliner -i l -l "$(printf '%s\n' one two three)" -p "enter: "`  
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
$ oneliner -l "$(printf '"'"'%s\n'"'"' one two three four)" \
           -t "$(printf '"'"'%s\n'"'"' two four)"
```

will result in a list looking like this:  
`two four one three`

DEPENDENCIES
------------

rofi  
i3list  
'

bouthead="
${__name^^} 1 ${__created} Linux \"User Manuals\"
=======================================

NAME
----
"

boutfoot="
AUTHOR
------

${__author} <${__contact}>
<https://budrich.github.io>

SEE ALSO
--------

rofi(1), i3list(1)
"


  case "$1" in
    # print version info to stdout
    version )
      printf '%s\n' \
        "$__name - version: $__version" \
        "updated: $__updated by $__author"
      exit
      ;;
    # print help in markdown format to stdout
    md ) printf '%s' "# ${about}" ;;

    # print help in markdown format to README.md
    mdg ) printf '%s' "# ${about}" > "${__dir}/README.md" ;;
    
    # print help in troff format to __dir/__name.1
    man ) 
      printf '%s' "${bouthead}" "${about}" "${boutfoot}" \
      | go-md2man > "${__dir}/${__name}.1"
    ;;

    # print help to stdout
    * ) 
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

ERR(){ >&2 echo "[WARNING]" "$*"; }
ERX(){ >&2 echo "[ERROR]" "$*" && exit 1 ; }

init(){
  # set -o errexit
  # set -o pipefail
  # set -o nounset
  # set -o xtrace

  __source="$(readlink -f "${BASH_SOURCE[0]}")"
  __dir="$(cd "$(dirname "${__source}")" && pwd)"
}

init
# __lastarg="${!#:-}"

__=""
__stdin=""

read -N1 -t0.01 __  && {
  (( $? <= 128 ))  && {
    IFS= read -rd '' __stdin
    __stdin="$__$__stdin"
  }
}


main "${@}"
