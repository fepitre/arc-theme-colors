# arc-theme-colors
Generate an Arc theme with any color instead of the default blue

## Manual

### 1. Provide one or a list of hexadecimal codes (without 0x or #) and names colors.

Example (colors.lst):

```
cc0000 Red
f57900 Orange
edd400 Yellow
73d216 Green
555753 Gray
3465a4 Blue
75507b Purple
```

By default, an empty name will be replaced by the hex code as Arc theme name

### 2. Generate and render the new Arc themes

./generate.sh --colors=colors.lst

For multi-threading rendering use --threads options (useful when having several colors to generate)

./generate.sh --colors=colors.lst --threads=4

### 3. Install the new Arc themes

sudo ./install.sh --colors=colors.lst

If you want to change options provided by the default Arc theme package, e.g. "--prefix" or "--with-gnome=3.18", simply pass the arguments to the install script.

Example:

./install.sh --colors=colors.lst --prefix=${HOME}/.local/ --with-gnome=3.18
