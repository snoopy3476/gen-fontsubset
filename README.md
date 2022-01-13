# Gen-FontSubset
A simple script that subsetting single heavy font into several subsets of webfont, and then create a css file that lists @font-face for all subsets with unicode-range.

# Prerequisites
- [Fonttools](https://github.com/fonttools/fonttools)
- [Brotli](https://github.com/google/brotli)

# Usage
`$ ./gen-fontsubset.sh <orig-fontfile> <unicode-subset-area-listfile>`
- `<orig-fontfile>`: An original font file to make subsets
- `<unicode-subset-area-listfile>`: A unicode subset area list file
  -  Details of Unicode subset area list file
    - Each range line consists of: `<Unicode-Range> <Comment>`
      - `<Unicode-Range>` is a range starting with "U+", or multiple such ranges concatenated with semicolons (,) between them
        - This field is used directly to both `unicode-range`, and `–unicodes` option in `pyftsubset` command.
      - `<Comment>` is a string that explains the range
    - Ex)
```
# Example of a subset area list file

# lines without leading "U+" will not be interpreted by the script!
# <Unicode-Range> <Comment>
U+0000-036F     Latin-BasicMarks
U+0370-03FF     Greek-Coptic
U+0400-052F     Cyrillic
U+1200-1252     Ethiopic
U+3130-318F,U+3200-327F,U+AC00-D7A3     KoreanCharsUnified
```

# Output
- Subset web fonts (both .woff and .woff2) for all subsets listed in the area list file
- A CSS file which helps to optimize webpage using [unicode-range in @font-face](https://developer.mozilla.org/en-US/docs/Web/CSS/@font-face/unicode-range)
```
// Example of an output CSS file

// * Note: Created CSS file is just a template.
//   You should find & replace data appropriately for your purpose:
//     Ex) Find & replace font parent dir in url(), change font-display attribute, etc.

// Font "Silver-Normalized" with range: "U+0000-036F" (Latin-BasicMarks)
@font-face {
    font-family: "Silver-Normalized";
    font-display: swap;
    src: url("fontdir/Silver-Normalized.U+0000-036F_Latin-BasicMarks.woff2") format("woff2"),
         url("fontdir/Silver-Normalized.U+0000-036F_Latin-BasicMarks.woff") format("woff");
    unicode-range: U+0000-036F;
}


// Font "Silver-Normalized" with range: "U+0370-03FF" (Greek-Coptic)
@font-face {
    font-family: "Silver-Normalized";
    font-display: swap;
    src: url("fontdir/Silver-Normalized.U+0370-03FF_Greek-Coptic.woff2") format("woff2"),
         url("fontdir/Silver-Normalized.U+0370-03FF_Greek-Coptic.woff") format("woff");
    unicode-range: U+0370-03FF;
}

...
```
