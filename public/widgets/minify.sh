#!/bin/sh

type yuicompressor >/dev/null 2>&1 || { echo >&2 "yuicompressor is required but not installed. Aborting."; exit 1; }

MINDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Make minify dir if it doesn't exist
if [ ! -d "$MINDIR/minified" ]; then
  echo "Creating 'minified' directory"
  mkdir minified
fi

yuicompressor -o '.css$:.min.css' *.css
yuicompressor -o '.js$:.min.js' *.js

mv *.min.* $MINDIR/minified/

echo "JS and CSS files minified and stored in minified directory"