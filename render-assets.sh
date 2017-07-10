#! /bin/bash

export INKSCAPE="/usr/bin/inkscape"
export OPTIPNG="/usr/bin/optipng"

export SRC_FILE="assets.svg"
export DARK_SRC_FILE="assets-dark.svg"
export ASSETS_DIR="assets"
export DARK_ASSETS_DIR="assets-dark"

export INDEX="assets.txt"

render_asset() {
  asset_file=$1
  if [ -f $ASSETS_DIR/${asset_file}.png ]; then
      echo $ASSETS_DIR/${asset_file}.png exists.
  else
      echo
      echo Rendering $ASSETS_DIR/${asset_file}.png
      $INKSCAPE --export-id=${asset_file} \
                --export-id-only \
                --export-png=$ASSETS_DIR/${asset_file}.png $SRC_FILE >/dev/null \
      && $OPTIPNG -o7 --quiet $ASSETS_DIR/${asset_file}.png
  fi
  if [ -f $ASSETS_DIR/${asset_file}@2.png ]; then
      echo $ASSETS_DIR/${asset_file}@2.png exists.
  else
      echo
      echo Rendering $ASSETS_DIR/${asset_file}@2.png
      $INKSCAPE --export-id=${asset_file} \
                --export-dpi=180 \
                --export-id-only \
                --export-png=$ASSETS_DIR/${asset_file}@2.png $SRC_FILE >/dev/null \
      && $OPTIPNG -o7 --quiet $ASSETS_DIR/${asset_file}@2.png
  fi
  if [ -f $DARK_SRC_FILE ]; then
    if [ -f $DARK_ASSETS_DIR/${asset_file}.png ]; then
        echo $DARK_ASSETS_DIR/${asset_file}.png exists.
    else
        echo
        echo Rendering $DARK_ASSETS_DIR/${asset_file}.png
        $INKSCAPE --export-id=${asset_file} \
                  --export-id-only \
                  --export-png=$DARK_ASSETS_DIR/${asset_file}.png $DARK_SRC_FILE >/dev/null \
        && $OPTIPNG -o7 --quiet $DARK_ASSETS_DIR/${asset_file}.png
    fi
  fi

}

export -f render_asset

THREADS=$1
cat $INDEX | xargs -P $THREADS -I{} bash -c "render_asset {}"
exit 0
