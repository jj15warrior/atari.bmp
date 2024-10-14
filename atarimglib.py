import cv2.version
import numpy as np
import os
import sys
import math
import cv2
import time
import pickle
import uuid
import matplotlib.pyplot as plt
# 8,9,10,11,14,15
# 8: 320x192
# 9: 80x192
# 10: 80x192
# 11: 80x192
# 14: 160x192
# 15: 160x192


THRESHOLD = False
BYPASSBGSETTING = False
gr_delta_sum = 0

grmode_dims = [
    (320, 192),
    (80, 192),
    (80, 192),
    (80, 192),
    (160, 192),
    (160, 192)
]

grmode_names = [
    "gr8.png",
    "gr9.png",
    "gr10.png",
    "gr11.png",
    "gr14.png",
    "gr15.png"
]

grmode_colors = [ 
    [
        "034653",
        "599ba9"
    ],
    [
        "040404",
        "0f0f0f",
        "1b1b1b",
        "272727",
        "333333",
        "414141",
        "4f4f4f",
        "5e5e5e",
        "686868",
        "787878",
        "898989",
        "9a9a9a",
        "ababab",
        "bfbfbf",
        "d3d3d3",
        "eaeaea"
    ],
    [
        "040404",
        "040404",
        "040404",
        "040404", # weird bug in atari gr10

        "9b5446",
        "74a52f",
        "034653",
        "80306f"
    ],
    [
        "040404",
        "77480b",
        "833c2d",
        "84373f",
        "80306f",
        "752f8f",
        "6434a4",
        "3b49a4",
        "29568f",
        "1e626f",
        "1a6d3f",
        "27710b",
        "396c00",
        "4f6200",
        "655600",
        "77480b"
    ],
    [
        "040404",
        "9b5446"
    ],
    [
        "040404",
        "9b5446",
        "74a52f",
        "034653"
    ]
]
grmode_prep = [[(26.803628513138975, -13.693454184414838, -13.172178046834048), (60.27623665952895, -17.18736095643458, -13.859395405360054)], [(1.096693984095186, 0.0001492039488348862, -0.0002952203635442352), (4.314983863482798, 0.0005870485668274528, -0.001161555660333935), (9.766934231515162, 0.0011685082452611573, -0.0023119569494189918), (15.637956087163825, 0.0014347540230608136, -0.002838738663424323), (21.24673129498138, 0.0016891071415725545, -0.003341990105887316), (27.53469245408516, 0.0019742607572370563, -0.0039061820027108674), (33.60250620710151, 0.002249430877870884, -0.004450621013107892), (39.90405327318042, 0.002535200602726828, -0.005016031915350272), (44.00716156902536, 0.002721273025307891, -0.005384186296986115), (50.43126613670573, 0.003012600627072537, -0.005960593760345745), (57.0908399379113, 0.00331460655556004, -0.006558128872269364), (63.601820542204834, 0.0036098739107370825, -0.007142331351328579), (69.9821315768838, 0.003899215513580856, -0.007714809408021495), (77.34033035450726, 0.004232903482281891, -0.008375029155027747), (84.5561167363605, 0.0045601331715716675, -0.009022470846042907), (92.69767225125261, 0.004929345692683551, -0.009752977847088395)], [(1.096693984095186, 0.0001492039488348862, -0.0002952203635442352), (1.096693984095186, 0.0001492039488348862, -0.0002952203635442352), (1.096693984095186, 0.0001492039488348862, -0.0002952203635442352), (1.096693984095186, 0.0001492039488348862, -0.0002952203635442352), (43.87428795464153, 27.950160058657193, 21.20786790616873), (62.36259681208635, -34.681759929155234, 53.03629293774754), (26.803628513138975, -13.693454184414838, -13.172178046834048), (33.67019803615474, 42.38030288403638, -19.633027857362073)], [(1.096693984095186, 0.0001492039488348862, -0.0002952203635442352), (35.16438465478814, 15.39254087955555, 40.845831271858586), (34.49101221204723, 29.30386781292832, 23.63871279657248), (33.976201816925936, 33.869512256149285, 11.676765059118232), (33.67019803615474, 42.38030288403638, -19.633027857362073), (33.558833550518266, 46.034918298132304, -39.87810022579769), (33.65933018986788, 44.778553971890844, -52.601797226205974), (34.75243711515362, 24.06454747012671, -51.00279631910807), (36.195539121068826, 4.593071458007025, -36.06053478421991), (38.126440854894184, -16.279553768737852, -13.500456818698115), (40.43592830269313, -35.77343501417729, 18.868604383099086), (41.63540843981713, -40.83788075594683, 43.880343673226854), (40.565027964365505, -33.73465867524947, 45.957355395015774), (38.54681992617759, -19.782014165028063, 44.98970579667317), (36.78493224444451, -2.231899324974945, 44.59956527034675), (35.16438465478814, 15.39254087955555, 40.845831271858586)], [(1.096693984095186, 0.0001492039488348862, -0.0002952203635442352), (43.87428795464153, 27.950160058657193, 21.20786790616873)], [(1.096693984095186, 0.0001492039488348862, -0.0002952203635442352), (43.87428795464153, 27.950160058657193, 21.20786790616873), (62.36259681208635, -34.681759929155234, 53.03629293774754), (26.803628513138975, -13.693454184414838, -13.172178046834048)]]

def rgb_to_cielab(rgb):
    sR, sG, sB = rgb

    var_R = ( sR / 255 )
    var_G = ( sG / 255 )
    var_B = ( sB / 255 )

    if ( var_R > 0.04045 ):
        var_R = ( ( var_R + 0.055 ) / 1.055 ) ** 2.4
    else:
        var_R = var_R / 12.92
    if ( var_G > 0.04045 ):
        var_G = ( ( var_G + 0.055 ) / 1.055 ) ** 2.4
    else:
        var_G = var_G / 12.92
    if ( var_B > 0.04045 ):
        var_B = ( ( var_B + 0.055 ) / 1.055 ) ** 2.4
    else:
        var_B = var_B / 12.92

    var_R = var_R * 100
    var_G = var_G * 100
    var_B = var_B * 100

    X = var_R * 0.4124 + var_G * 0.3576 + var_B * 0.1805
    Y = var_R * 0.2126 + var_G * 0.7152 + var_B * 0.0722
    Z = var_R * 0.0193 + var_G * 0.1192 + var_B * 0.9505


    var_X = X / 95.047
    var_Y = Y / 100.000
    var_Z = Z / 108.883

    if ( var_X > 0.008856 ):
        var_X = var_X ** ( 1/3 )
    else:
        var_X = ( 7.787 * var_X ) + ( 16 / 116 )
    if ( var_Y > 0.008856 ):
        var_Y = var_Y ** ( 1/3 )
    else:
        var_Y = ( 7.787 * var_Y ) + ( 16 / 116 )
    if ( var_Z > 0.008856 ):
        var_Z = var_Z ** ( 1/3 )
    else:
        var_Z = ( 7.787 * var_Z ) + ( 16 / 116 )

    CIEL = ( 116 * var_Y ) - 16
    CIEa = 500 * ( var_X - var_Y )
    CIEb = 200 * ( var_Y - var_Z )

    return CIEL, CIEa, CIEb

def str_to_rgb(s):
    return tuple(int(s[i:i+2], 16) for i in (0, 2, 4))

def CieLab2Hue(x, y): # todo: ai gen, check this
    if ( x > 0 ):
        return math.atan( y / x ) * 180 / math.pi
    elif ( x < 0 and y >= 0 ):
        return 360 + math.atan( y / x ) * 180 / math.pi
    elif ( x < 0 and y < 0 ):
        return 180 + math.atan( y / x ) * 180 / math.pi
    else:
        return 180

def deg2rad(x):
    return x * math.pi / 180

def rad2deg(x):
    return x * 180 / math.pi

def distance(cielab1, cielab2):
    CIEL1, CIEa1, CIEb1 = cielab1
    CIEL2, CIEa2, CIEb2 = cielab2
    WHTL, WHTC, WHTH = (1,1,1) # for weight adjustments

    xC1 = math.sqrt( CIEa1 * CIEa1 + CIEb1 * CIEb1 )
    xC2 = math.sqrt( CIEa2 * CIEa2 + CIEb2 * CIEb2 )
    xCX = ( xC1 + xC2 ) / 2
    xGX = 0.5 * ( 1 - math.sqrt( ( xCX ** 7 ) / ( ( xCX ** 7 ) + ( 25 ** 7 ) ) ) )
    xNN = ( 1 + xGX ) * CIEa1
    xC1 = math.sqrt( xNN * xNN + CIEb1 * CIEb1 )
    xH1 = CieLab2Hue( xNN, CIEb1 )
    xNN = ( 1 + xGX ) * CIEa2
    xC2 = math.sqrt( xNN * xNN + CIEb2 * CIEb2 )
    xH2 = CieLab2Hue( xNN, CIEb2 )
    xDL = CIEL2 - CIEL1
    xDC = xC2 - xC1
    if ( ( xC1 * xC2 ) == 0 ):
        xDH = 0
    
    else:
        xNN = round( xH2 - xH1, 12 )
        if ( abs( xNN ) <= 180 ):
            xDH = xH2 - xH1
        else:
            if ( xNN > 180 ):
                xDH = xH2 - xH1 - 360
            else:
                xDH = xH2 - xH1 + 360
    
    xDH = 2 * math.sqrt( xC1 * xC2 ) * math.sin( deg2rad( xDH / 2 ) )
    xLX = ( CIEL1 + CIEL2 ) / 2
    xCY = ( xC1 + xC2 ) / 2
    if ( ( xC1 *  xC2 ) == 0 ):
        xHX = xH1 + xH2
    else:
        xNN = abs( round( xH1 - xH2, 12 ) )
        if ( xNN >  180 ):
            if ( ( xH2 + xH1 ) <  360 ):
                xHX = xH1 + xH2 + 360
            else:
                xHX = xH1 + xH2 - 360
        else:
            xHX = xH1 + xH2
        
        xHX /= 2
    
    xTX = 1 - 0.17 * math.cos( deg2rad( xHX - 30 ) ) + 0.24 * math.cos( deg2rad( 2 * xHX ) ) + 0.32 * math.cos( deg2rad( 3 * xHX + 6 ) ) - 0.20 * math.cos( deg2rad( 4 * xHX - 63 ) )
    xPH = 30 * math.exp( - ( ( xHX  - 275 ) / 25 ) * ( ( xHX  - 275 ) / 25 ) )
    xRC = 2 * math.sqrt( ( xCY ** 7 ) / ( ( xCY ** 7 ) + ( 25 ** 7 ) ) )
    xSL = 1 + ( ( 0.015 * ( ( xLX - 50 ) * ( xLX - 50 ) ) )
            / math.sqrt( 20 + ( ( xLX - 50 ) * ( xLX - 50 ) ) ) )

    xSC = 1 + 0.045 * xCY
    xSH = 1 + 0.015 * xCY * xTX
    xRT = - math.sin( deg2rad( 2 * xPH ) ) * xRC
    xDL = xDL / ( WHTL * xSL )
    xDC = xDC / ( WHTC * xSC )
    xDH = xDH / ( WHTH * xSH )

    DeltaE00 = math.sqrt( xDL ** 2 + xDC ** 2 + xDH ** 2 + xRT * xDC * xDH )
    
    return DeltaE00

def bgr_to_rgb(x):
    return (x[2], x[1], x[0])

def closest_color(gr, x):
    global gr_delta_sum

    delta_min = 9999999
    color_dmin = []
    for color_id in range(len(grmode_prep[gr])):
        delta = distance(grmode_prep[gr][color_id], rgb_to_cielab((x)))
        if delta < delta_min:
            delta_min = delta
            color_dmin = color_id
    gr_delta_sum += delta_min

    return (str_to_rgb(grmode_colors[gr][color_dmin]),color_dmin)


def posterize(scaled_img, Ti, gr):
    x2,y2 = grmode_dims[gr]
    for x1 in range(0, x2):
        for y1 in range(0, y2):
            (r,g,b),id = closest_color(gr,scaled_img[y1][x1])
            scaled_img[y1][x1] = (r,g,b)
            Ti[x1][y1] = id

def thresh(scaled_img):
    gray = cv2.cvtColor(scaled_img, cv2.COLOR_RGB2GRAY)
    gray = cv2.threshold(gray,100,255,cv2.THRESH_BINARY)[1]
    return cv2.cvtColor(gray,cv2.COLOR_GRAY2BGR)


def prompt():
    #print("images generated and saved to the out/ folder")

    version = input("choose version > ")

    if version not in ["8", "9", "10", "11", "14", "15"]:
        #print("invalid version, please use the version mentioned in filename, corresponding to atari's graphics")
        version = input("graphic mode number > ")

    vc = 0
    match version:
        case "8":
            vc = 0
        case "9":
            vc = 1
        case "10":
            vc = 2
        case "11":
            vc = 3
        case "14":
            vc = 4
        case "15":
            vc = 5
    return vc

def layerize(fwd_T,vc):
    layers_T = np.zeros((len(grmode_colors[vc]),grmode_dims[vc][1],grmode_dims[vc][0]), np.uint8)
    counts = np.zeros(len(grmode_colors[vc]), np.uint64)

    for y1 in range(len(fwd_T)):
        for x1 in range(len(fwd_T[0])):
            layers_T[fwd_T[y1][x1]][x1][y1] = 1
            counts[fwd_T[y1][x1]] +=1
    return layers_T,counts


def overlaps(x1,y1,x2,y2, can_override):
    if x1<0 or y1<0 or x2>=len(can_override[0]) or y2>=len(can_override):
        return False
    
    for x in range(min(x1,x2), max(x1,x2)+1):
        for y in range(min(y1,y2), max(y1,y2)+1):
            if not can_override[y][x]:
                return False
    return True

def fillzero(x1,y1,x2,y2,arr):
    for x in range(x1,x2+1):
        for y in range(y1,y2+1):
            arr[y][x] = False
    return arr


def genLayerSquares(tsrt,vc,path):
    layers_squareified = []
    names = []

    for i in range(len(tsrt)):
        layer,count,name = tsrt[i]
        if path:
            cv2.imwrite(f"{path}layer_{name}.png", (layer*255).astype(np.uint8))
        if count >0:
            layers_squareified.append(squareify(layer,tsrt[i:], vc))
            names.append(name)
    return layers_squareified,names

def countInImg(img):
    counts = {}
    for y in img:
        for x in y:
            if x in counts:
                counts[int(x)]+=1
            else:
                counts[int(x)] = 0
        
    ca = []
    for c in counts.keys():
        ca.append((c,counts[c]))

    counts = sorted(ca, key=lambda tup:tup[1], reverse=True)
    return counts

def setOnes(bmp,canoverride):
    for y in range(len(bmp)):
        for x in range(len(bmp[0])):
            if bmp[y][x]:
                canoverride[y][x] = True


def setOnes1(lines,canoverride, vc):
    y = 0
    for x,ctr in lines:
        if x >= grmode_dims[vc][1]:
            y+=1
            continue
        for i in range(ctr):
            canoverride[y][x+i] = True
        if ctr+x >= grmode_dims[vc][1]:
            y+=1
    

def setOnes2(x1,x2,y,canoverride, vc):
    y = 0
    if x2 >= grmode_dims[vc][1]:
        return
        
    for i in range(x2-x1):
        canoverride[y][x1+i] = True
    

def genLayerHLines(fwdT,vc,path):
    layers_lines = []
    layers_names = []
    counts = countInImg(fwdT)
    flat_canoverride = np.zeros((grmode_dims[vc][0],grmode_dims[vc][1]), np.bool)
    for c in counts:
        flat_bmp = np.zeros((grmode_dims[vc][0],grmode_dims[vc][1]), np.bool)
        ctr = 0
        tmp = []
        for y in range(len(fwdT[0])):
            for x in range(len(fwdT)):
                #print("pos:",x,y,"fwdT:",fwdT[x][y])

                if fwdT[x][y] == c[0]:
                    ctr += 1
                    #print("print ctr++:",ctr)
                    flat_bmp[x][y] = True
                elif not flat_canoverride[x][y] and (ctr >0):
                    ctr +=1
                else:
                    if ctr !=0:
                        #print("normal append",x-ctr,ctr)
                        tmp.append((x-ctr,x-1))
                        ctr = 0

            if ctr == 0:
                #print("ctr = 0 append",grmode_dims[vc][1],grmode_dims[vc][1])
                if len(tmp)>0:
                    if tmp[-1] == (81,81):
                        tmp[-1] = (82,2)
                    elif tmp[-1][0] == 82:
                        tmp[-1] = (82,tmp[-1][1]+1)
                    else:
                        tmp.append((grmode_dims[vc][0]+1,grmode_dims[vc][0]+1))
                else:
                        tmp.append((grmode_dims[vc][0]+1,grmode_dims[vc][0]+1))
            if ctr != 0:
                tmp.append((grmode_dims[vc][0]-ctr,grmode_dims[vc][0]-1))
                tmp.append((81,81))
                ctr = 0
        setOnes(flat_bmp,flat_canoverride)
        layers_lines.append(tmp)
        layers_names.append(c[0])
    return layers_lines,layers_names
squarecount = 0

def squareify(todo, can_override, vc):
    global squarecount
    flat_canoverride = np.zeros((grmode_dims[vc][1],grmode_dims[vc][0]), np.bool)
    squares = []
    for layer,count,name in can_override:
        for y in range(len(layer)):
            for x in range(len(layer[0])):
                if layer[y][x]:
                    flat_canoverride[y][x] = True
    for xm in range(len(todo[0])):
        x = len(todo[0])-xm-1
        for y in range(len(todo)):
            if todo[y][x] == 0:
                continue
            dims = [x,y,x,y].copy()
            failcount = 0

            while True:
                if overlaps(dims[0]-1,dims[1],dims[2],dims[3], flat_canoverride):
                    dims[0] -=1
                    failcount = 0
                elif overlaps(dims[0],dims[1]-1,dims[2],dims[3], flat_canoverride):
                    dims[1] -=1
                    failcount = 0

                elif overlaps(dims[0],dims[1],dims[2]+1,dims[3], flat_canoverride):
                    dims[2] +=1
                    failcount = 0

                elif overlaps(dims[0],dims[1],dims[2],dims[3]+1, flat_canoverride):
                    dims[3] +=1
                    failcount = 0
                else:
                    failcount += 1

                if failcount >=4:
                    #print(dims[0],dims[1],dims[2]-dims[0]+1, dims[3]-dims[1]+1)
                    squares.append([dims[0],dims[1],dims[2], dims[3]])
                    for xf in range(dims[0], dims[2]+1):
                        for yf in range(dims[1], dims[3]+1):
                            todo[yf][xf] = False
                            flat_canoverride[yf][xf] = False
                    failcount = 0
                    break
    squarecount += len(squares)
    return squares