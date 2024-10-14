
# atari.bmp

This is a python tool that allows users to compress images and display them on an atari 8bit computer

atari.bmp works by generating a Pascal file, compiling it with mp and assembling with mads. There are two compression algorithms available, which i will explain in a later section of this Readme.


## examples:


![mig29 photo](https://github.com/jj15warrior/atari.bmp/blob/main/readme/mig29.jpg?raw=true)

for educational purposes we will use this mig29 photo as our image.

```
python main.py -c rect readme/mig29.jpg 
```
when user does not provide a graphical mode to use, the program will generate all options and prompt the user. You can find all of the generated images in the out/ directory.

here are the generated images

gr8: ![gr8](https://github.com/jj15warrior/atari.bmp/blob/main/out/gr8.png?raw=true)

gr9: ![gr9](https://github.com/jj15warrior/atari.bmp/blob/main/out/gr9.png?raw=true)

gr10: ![gr10](https://github.com/jj15warrior/atari.bmp/blob/main/out/gr10.png?raw=true)

gr11: ![gr11](https://github.com/jj15warrior/atari.bmp/blob/main/out/gr11.png?raw=true)

gr14: ![gr14](https://github.com/jj15warrior/atari.bmp/blob/main/out/gr14.png?raw=true)

gr15: ![gr15](https://github.com/jj15warrior/atari.bmp/blob/main/out/gr15.png?raw=true)

the images will look distorted because atari has non-square pixels

In this case i suppose that gr15 looks the best
```
choose version > 15
```
This generates the pascal file, and we can take a look inside.

There are 3 major segments. First, const data:
```pas
const
    data_65fadaa9_1: array [0..2575] of byte = (<data>);
    data_65fadaa9_2: array [0..2999] of byte = (<data>);
    data_65fadaa9_0: array [0..859] of byte = (<data>);
```

the var name structure is `data_<random_uuid>_<color>`


Second important segment is `procedure B` that contains a drawing function, and last we have loops that call this procedure. This is slightly different in the HLine compression mode.


Now, we have to compile this .pas file into an atari executable format like .obx

```
./Mad-Pascal/bin/mp image.pas -ipath:Mad-Pascal/lib -o:a.a65 -target:a8
```
this creates a.a65 which we can assemble

```
./Mad-Assembler/mads a.a65 -x -i:Mad-Pascal/base
```

## Running
I recommend emulating an atari800 xl using [this](https://github.com/atari800/atari800) emulator. It's available in APT and AUR, but any other emulator will do.

```
atari800 -xl -run a.obx
```

how it looks emulated: ![emulated image](https://github.com/jj15warrior/atari.bmp/blob/main/readme/emulator.png?raw=true)

You can also copy this obx file onto a SDRIVE device




## references:

 - [tebe6502's mads assembler](https://github.com/tebe6502/Mad-Assembler)
 - [tebe6502's mad pascal](https://github.com/tebe6502/Mad-Pascal)
 - [atariarchives mappings](https://www.atariarchives.org/mapping/memorymap.php)
 


## Compression algorithms
- Rectangle matching

1. layerizing the image into single-color images
2. sorting layers by amount of set pixels
3. finding largest possible rectangles on each layer and removing them
4. drawing rectangles using individual HLines from mad-pascal's fastgraph library
``` this compression mode was first using pascal's Bar() procedure, but later i found fastgraph and decided to port the pascal part to it. It achieves suprisingly good drawing speeds with a decent compression ratio```
- HLine matching
1. layerize and sort as above
2. from left to right and layer by layer find horizontal lines with the same color
3. denote line breaks (Y increments) using a coordinate = width+1. 
4. replace multiple empty lines with a (width+2, lines) pair, and remove the redundant width+1 pairs
5. pass coordinate pointers to a pascal procedure that also uses HLine





## Requirements

- fpc compiler for tebe6502's tools
- python3
- python3-venv is very recommended, and without it cv2 cnstallation is problematic
-

## Installation

Clone this repo with submodule recursion

```sh
git clone --recurse-submodules https://github.com/jj15warrior/atari.bmp
cd atari.bmp
```

Make the build tools
```
make all
```

Enable venv and install requirements:
```
python -m venv .
source bin/activate
pip install -r requirements.txt
```
note: depending on your shell you will have to use other bin/activate files. For fish it's:
```
source bin/activate.fish
```
etc.


## Usage

```
python main.py -c <algo> -g <grmode> [file1] [file2] ...
```
note: multi-file compression is not supported at the moment. You can however hack together two pascal scripts because of uuids used to match data to programs

## Support

For help, DM jj15 on discord

