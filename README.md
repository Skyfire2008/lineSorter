# lineSorter
## Building
To build run "__haxe lineSorter.hxml__".
You'll need the format library, which can be installed by using "__haxelib install format__".

## Running
Run by executing "__neko bin/lineSorter.n -i *filename*__" from the command line. Only PNG files are supported right now.
The resulting file will be located at *filename-output.png*.

### Options:
The following arguments can be used to change the behaviour of the utility:
* *-i filename* - to specify the input file (required).
* *-m (h|s|l|r|g|b)* - to specify the criterium used to sort the values. **H**, **S**, **L**, **R**, **G**, **B** stand for **hue**, **saturation**, **lightness**(default), **red**, **green** and **blue** respectively.
* *-l* - to use the *line-wise* mode, sorts single pixel values within every vertical line of the image.

## Album with examples
http://imgur.com/a/gOzgk
