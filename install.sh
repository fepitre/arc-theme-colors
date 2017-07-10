#!/bin/bash

function help() {
  echo "
    -c=,  --colors=     colors file
    -h,  --help       show this message

  Example:

  0) Generate themes with generate.sh (see generate.sh -h)

  1) Provide a list of hexadecimal codes (without 0x or #) and names colors. Example (colors.lst):

      cc0000 Red
      f57900 Orange
      edd400 Yellow
      73d216 Green
      555753 Gray
      3465a4 Blue
      75507b Purple

  2) ./generate.sh --colors=colors.lst --threads=4"
  exit 1
}

for i in "$@"
do
  case $i in
    -c=*|--colors=*)
      # Read colors codes and names from input file
      if [ -e "${i#*=}" ]; then
        codes=($(cat "${i#*=}" | awk '{print $1}'))
        names=($(cat "${i#*=}" | awk '{print $2}'))
        shift
      else
        echo "Please provide a file with colors! See ./generate.sh --help"
        exit 1
      fi
    ;;
    -h|--help)
      help
      exit 0
    ;;
		*)
			args="$args ${i}"
			shift
		;;
  esac
done

for i in `seq 1 ${#codes[@]}`
do
	if [ "x${names[$i-1]}" = "x" ]; then
		NAME=$i
	else
		NAME=${names[$i-1]}
	fi

  if test arc-theme-$NAME/autogen.sh; then
    if [ "x$args" = "x" ]; then
      sh -c "cd arc-theme-$NAME && ./autogen.sh && make install"
    else
      sh -c "cd arc-theme-$NAME && ./autogen.sh $args && make install"
    fi
  else
    echo "Arc-$NAME not found"
  fi
done
