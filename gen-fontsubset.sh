#!/bin/bash

##### Gen-Fontsubset #####
# Subsetting single heavy font into several subset of webfont,
# and then create css file that lists @font-face for all subsets with unicode-range.
#
# Usage: $ ./gen-fontsubset.sh <orig-fontfile> <unicode-subset-area-listfile>
#




# font file to subset
FONT_FILE="$1"
# unicode subset area list file
AREALIST_FILE="$2"

### Contents of Unicode Subset Area List File ('AREALIST_FILE') ###
#
# * Only lines starting with "U+" will be interpreted!
# <Range>       <Range-Comment>
# ex) U+0000-036F Latin-BasicMarks
#
# U+0000-036F     Latin-BasicMarks
# U+0370-03FF     Greek-Coptic
# U+0400-052F     Cyrillic
# U+1200-1252     Ethiopic
# ...
# U+3130-318F,U+3200-327F,U+AC00-D7A3     KoreanCharsUnified
# ...


FONT_FILE_WITHOUT_EXT="${FONT_FILE%.*}"
FONT_FILE_BASENAME="$(basename "$FONT_FILE_WITHOUT_EXT")"

# CSS file created, which contains 'unicode-range' info in @font-face
# for efficient font downloads and reduce traffics
CSS_FILE="$FONT_FILE_WITHOUT_EXT".css




# validation
if ! [ -f "$FONT_FILE" ]
then
	printf "Font file '%s' does not exist!\n" "$FONT_FILE" 1>&2
	printf "usage: $0 <orig-fontfile> <unicode-subset-area-listfile>\n" 1>&2
	exit 1
fi

if ! [ -f "$AREALIST_FILE" ]
then
	printf "Font area list file '%s' does not exist!\n" "$AREALIST_FILE" 1>&2
	printf "usage: $0 <orig-fontfile> <unicode-subset-area-listfile>\n" 1>&2
	exit 1
fi




# generate woff & woff2 for each unicode area in list file
for TYPE in woff woff2
do
	PYFTSUBSET_CMD="$(awk -v FONT_FILE="$FONT_FILE" -v FONT_FILE_WITHOUT_EXT="$FONT_FILE_WITHOUT_EXT" -v TYPE="$TYPE" '/^U\+/ {print "echo \" - Generating a font subset \\\"" FONT_FILE_WITHOUT_EXT "." $1 "_" $2 "." TYPE "\\\" ...\" ; pyftsubset \"" FONT_FILE "\" --output-file=\"" FONT_FILE_WITHOUT_EXT "." $1 "_" $2 "." TYPE "\" --flavor=\"" TYPE "\" --unicodes=\"" $1 "\""}' "$AREALIST_FILE")"
	#echo "$PYFTSUBSET_CMD"
	eval "$PYFTSUBSET_CMD"

done

# generate @font-face css with unicode-range
echo " - Generating a CSS file \"$CSS_FILE\" for unicode-range ..."
GENCSS_CMD="$(awk -v FONT_FILE_BASENAME="$FONT_FILE_BASENAME" '/^U\+/ {printf "\n// Font \"%s\" with range: \"" $1 "\" (" $2 ")\n@font-face {\n\tfont-family: \"%s\";\n\tfont-display: swap;\n\tsrc: url(\"fontdir/%s." $1 "_" $2 ".woff2\") format(\"woff2\"),\n\t\turl(\"fontdir/%s." $1 "_" $2 ".woff\") format(\"woff\");\n\tunicode-range: " $1 ";\n}\n\n", FONT_FILE_BASENAME, FONT_FILE_BASENAME, FONT_FILE_BASENAME, FONT_FILE_BASENAME}' "$AREALIST_FILE")"
echo "$GENCSS_CMD" > "$CSS_FILE"
echo
echo
echo " ******************************************************* "
echo " ***         Before applying output CSS file,        *** "
echo " *** replace the path 'fontdir' of the font in url() *** "
echo " ***          with actual path of the font!          *** "
echo " ******************************************************* "
echo
echo "     ex)"
echo "     ..."
echo "     src: url(\"fontdir/$FONT_FILE_BASENAME ...\""
echo
echo "  => src: url(\"/actual-path-that-font-can-be-accessed-with/$FONT_FILE_BASENAME ...\""
echo
