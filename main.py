import cv2.version
import numpy as np
import os
import cv2
import pascalgen
import uuid
import argparse
# 8,9,10,11,14,15
# 8: 320x192
# 9: 80x192
# 10: 80x192
# 11: 80x192
# 14: 160x192
# 15: 160x192

import atarimglib
import pascalgen


parser = argparse.ArgumentParser(
                    prog='deltagen.py',
                    description='generate images and gifs for atari 8bit computers',
                    epilog='for more info refer to source and comments')

parser.add_argument('-c','--compression', required=False, choices=['rect','hline'] ,help='set compression type. you have to experiment to find one most suitable')
parser.add_argument('-g', '--grmode', required=False, help='set graphical mode. optional (will generate all if not set)')
parser.add_argument('-m','--maxmem', required=False, help='work in progress. Compress until size matched set limit\nrecommended 15kb for 24kb roms, etc')
parser.add_argument('image', type=argparse.FileType('r', encoding=None), nargs='+')

parser.add_help = True

filenames = [n.name for n in parser.parse_args().image]
compressionmode = "rect"
compressionmode = parser.parse_args().compression if parser.parse_args().compression != None else compressionmode
print(compressionmode)

if len(filenames) == 1:
    img = cv2.imread(filenames[0])
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

try:
    os.mkdir("out")
except Exception:
    pass

imgs = []
Ts = []

set_grmode = -1


modes_to_process = range(0,len(atarimglib.grmode_names))
set_grmode = 0
set_grmode = int(parser.parse_args().grmode) if parser.parse_args().grmode != None else None
if set_grmode:
    print("loading only grmode", set_grmode)
    if set_grmode > 11:
        set_grmode-=2
    modes_to_process = [set_grmode-8]

for gr in modes_to_process:
        x2,y2 = atarimglib.grmode_dims[gr]

        scaled_img = cv2.resize(img, (x2, y2), interpolation = cv2.INTER_AREA)
        print(x2,y2)
        print(np.shape(scaled_img))
        Ti = np.zeros((x2,y2), dtype=np.uint8)
        atarimglib.posterize(scaled_img,Ti, gr)
        imgs += [scaled_img]
        Ts += [Ti]
        sc = cv2.cvtColor(scaled_img,cv2.COLOR_BGR2RGB)
        cv2.imwrite("out/"+atarimglib.grmode_names[gr], sc)

if len(modes_to_process)==1:
    vc = set_grmode-8
    fwd_img = imgs[0]
    fwd_T = Ts[0]

else:
    vc = atarimglib.prompt()
        
    fwd_img = imgs[vc]
    fwd_T = Ts[vc]

del Ts
del imgs

cv2.imwrite("out/fwd.png", fwd_img)



program_uuid = str(uuid.uuid4()).split('-')[0]

program = ""

if compressionmode == 'rect':
    layers_T,counts = atarimglib.layerize(fwd_T,vc)

    tsrt = []
    for i in range(len(atarimglib.grmode_colors[vc])):
        tsrt.append([layers_T[i], counts[i],i])
    tsrt = sorted(tsrt, key = lambda x : x[1], reverse=True)

    if not atarimglib.BYPASSBGSETTING:
        background_color = tsrt[0][2]
        tsrt = tsrt[1:]
        print("background color:", background_color)

    atarimglib.squarecount = 0
    layers_squareified,names = atarimglib.genLayerSquares(tsrt,vc,"out/layers/")

    if set_grmode == 8:
        print(atarimglib.squarecount*4*2,"bytes used for raw data")
    else:
        print(atarimglib.squarecount*4,"bytes used for raw data")

    program=pascalgen.genPascalSQ(layers_squareified,names,vc, program_uuid,atarimglib.BYPASSBGSETTING,background_color,atarimglib.grmode_dims)

elif compressionmode == 'hline':
    lines_layers,names = atarimglib.genLayerHLines(fwd_T,vc,"out/layers/")
    count = 0
    for l in lines_layers:
        count += len(l)
    print(count*2, "bytes used for raw data")
    #print(lines_layers)
    s = "uses crt,fastgraph;\n\n"
    s+=pascalgen.genConstHL(lines_layers,names,program_uuid)
    s+=pascalgen.genProgHL(lines_layers,names,program_uuid,atarimglib.grmode_dims,vc)
    s+="\nrepeat until false;\nend."
    program = s

print(program)
f = open("./image.pas","w")
f.write(program)
f.close()