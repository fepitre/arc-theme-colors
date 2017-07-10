#!/bin/bash

function help() {
  echo "
    -c=,  --colors=     colors file
    -t=,  --threads=    multi-threading rendering (useful when having several colors to generate)
    -h,   --help       show this message

  Example:
  1) Provide a list of hexadecimal codes (without 0x or #) and names colors. Example (colors.lst):

      cc0000 Red
      f57900 Orange
      edd400 Yellow
      73d216 Green
      555753 Gray
      3465a4 Blue
      75507b Purple

    By default, an empty name will be replaced by the hex code as name.

  2) ./generate.sh --colors=colors.lst --threads=4"
  exit 0
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
    -t=*|--threads=*)
      threads="${i#*=}" # Read number of parallel execution for assets rendering
      shift
    ;;
    -h|--help)
      help
      exit 0
    ;;
  esac
done

# Script location
directory=$(cd `dirname $0` && pwd)

# Add Arc base theme
git clone https://github.com/horst3180/arc-theme

# Arc theme default color
arc_code=5294e2

for i in `seq 1 ${#codes[@]}`
do
  if [ "x${names[$i-1]}" = "x" ]; then
    NAME=${codes[$i-1]}
  else
    NAME=${names[$i-1]}
  fi

  echo "+ Copy initial Arc theme directory to arc-theme-$NAME"
  rm -rf arc-theme-$NAME
  cp -r arc-theme{,-$NAME}
  find arc-theme{,-$NAME} -name ".git*" -exec rm -rf {} \;

  echo "+ Rename Arc theme"
  sed -i "s/Arc/Arc-$NAME/g" arc-theme-$NAME/common/index.theme* arc-theme-$NAME/common/Makefile.am

  echo "+ Remove old assets"
  rm -rf arc-theme-$NAME/common/gtk-2.0/assets/*.png
  rm -rf arc-theme-$NAME/common/gtk-2.0/assets-dark/*.png
  rm -rf arc-theme-$NAME/common/gtk-2.0/menubar-toolbar/*.png
  rm -rf arc-theme-$NAME/common/gtk-3.0/3.14/assets/*.png
  rm -rf arc-theme-$NAME/common/gtk-3.0/3.16/assets/*.png
  rm -rf arc-theme-$NAME/common/gtk-3.0/3.18/assets/*.png
  rm -rf arc-theme-$NAME/common/gtk-3.0/3.20/assets/*.png
  rm -rf arc-theme-$NAME/common/xfwm4/assets/*.{png,xpm}
  rm -rf arc-theme-$NAME/common/xfwm4/assets-dark/*.{png,xpm}

  echo "+ Change default blue Arc theme color to the new colors"
  find arc-theme-$NAME/ -type f -exec sed -i 's/'${arc_code}'/'${codes[$i-1]}'/gI' {}  \;

  echo "+ Regenerate css files"
  gulp --cwd arc-theme-$NAME

  echo "+ Make assets"
  assets_folders=($(find arc-theme-$NAME/ -name "render-assets.sh" -printf '%h\n'))

  for i in ${assets_folders[@]}
  do
    if [ "x$threads" = "x" || "$threads" = "1" ]; then
      # If threads=1 or empty we use the default script else we use the one of the repo
      sh -c "cd $i && ./render-assets.sh"
    else
      sh -c "cd $i && $directory/render-assets.sh $threads"
    fi
  done
done
