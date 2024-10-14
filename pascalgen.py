import uuid
import numpy as np
pascalBegin = """
uses crt, fastgraph;
  
const
"""

procedureHLDraw = """
procedure drawCol(mxi:word;color:byte);
begin
for c:=0 to 1 do begin
	SetColor(color*c);
	y:=0;
	i:=0;
	repeat
		if i > mxi then
			Break;
		if ptr[i*2] = 81 then
		begin
			i:=i+1;
			y:=y+1;
			Continue;
		end;
		if ptr[i*2] = 82 then
		begin
			y:=y+ptr[i*2+1];
			i:=i+1;
			Continue;
		end;
		HLine(ptr[i*2],ptr[i*2+1],y);
		i:=i+1;
	until i =mxi+1;
	end;
end;
"""

procedureB = """
procedure B(x1,y1,x2,y2:byte);
var
	ine:word;
	c:byte;
	x,y,xw,yh:byte;
begin
	if x1=x2 then
	begin
		xw:=x1;
		x:=x2;
	end;
	if x1 < x2 then
	begin
		x := x1;
		xw := x2;
	end;
	if x1 > x2 then
	begin
		x := x2;
		xw := x1;
	end;
	if y1 < y2 then
	begin
		y := y1;
		yh := y2;
	end;
	if y1 > y2 then
	begin
		y := y2;
		yh := y1;
	end;

	c := GetColor;

	if y1=y2 then
	begin
		y:=y1;
		yh:=y2;
	end;



	if x <> xw then
	begin
		if c <> 0 then
		begin
			SetColor(0);
			for ine :=0 to yh-y do
			begin
				HLine(x,xw,y+ine);
			end;
		end;
		SetColor(c);
		for ine :=0 to yh-y do
		begin
			HLine(x,xw,y+ine);
		end;
	end;
	if x=xw then
	begin
		if c <> 0 then
		begin
			setColor(0);
			Line(x,y,xw,yh);
		end;
		setColor(c);
		Line(x,y,xw,yh);
	end;
	
end;
"""

def genConstSQ(layers_squareified,uid,set_grmode,names):
    textdata = ""

    dtype = ""
    if set_grmode == 8:
        dtype = "word"
    else:
        dtype = "byte"

    for layer_id in range(len(layers_squareified)):
        textdata += "\tdata_"+uid+"_"+str(names[layer_id])
        textdata += ": array [0.."+str(4*len(layers_squareified[layer_id])-1)+"]"
        textdata += " of "+dtype+" = ("
        for square_id in range(len(layers_squareified[layer_id])):
            x1,y1,x2,y2 = layers_squareified[layer_id][square_id]
            textdata += str(x1)+","+str(y1)+","+str(x2)+","+str(y2)+","
        textdata = textdata[:-1]
        textdata += ");\n"
    textdata += "\n"
    return textdata

def genProgramSQ(layers_squareified,names, program_uuid):
    program_str = ""

    for layer_id in range(len(layers_squareified)):

        program_str += "\tsetColor("+str(names[layer_id])+");\n"
        program_str += "\tfor i := 0 to "+str(len(layers_squareified[layer_id])-1)+" do\n\tbegin\n"
        program_str += "\t\tB("+"data_"+program_uuid+"_"+str(names[layer_id])+"[i*4],"
        program_str += "data_"+program_uuid+"_"+str(names[layer_id])+"[i*4+1],"
        program_str += "data_"+program_uuid+"_"+str(names[layer_id])+"[i*4+2],"
        program_str += "data_"+program_uuid+"_"+str(names[layer_id])+"[i*4+3]);\n\tend;\n"
    
    return program_str

def genPascalSQ(layers_squareified,names,vc, program_uuid, BYPASSBGSETTING,background_color,grmode_dims):
    set_grmode = vc+8
    if set_grmode>11:
        set_grmode+=2

    textdata = pascalBegin + genConstSQ(layers_squareified,program_uuid,set_grmode,names)
    textdata += "var\n\ti:dword;"

    textdata += procedureB

    textdata += "\nbegin\n"
    textdata += "\tinitgraph(16+"+str(set_grmode)+");\n"
    if not BYPASSBGSETTING:
        textdata += "\tSetColor("+str(background_color)+");\n\tB(0,0,"+str(grmode_dims[vc][0])+","+str(grmode_dims[vc][1])+");\n"
    textdata += genProgramSQ(layers_squareified,names, program_uuid)
    textdata += "\trepeat until false;\nend."
    return textdata

# layers_lines = [y,[[x,ctr]...]]
# layers_colors= [  [ c     ...]]
def genConstHL(layers_lines,layers_names,program_uuid, dtype='byte'):
	textdata = "const\n\t"
	for i in range(len(layers_names)):
		color = layers_names[i]
		textdata += "\tdata_"+program_uuid+"_"+str(color)
		textdata += ": array [0.."+str(2*len(layers_lines[i])-1)+"]"
		textdata += " of "+dtype+" = ("
		for c in layers_lines[i]:
			textdata += str(c[0])+","+str(c[1])+","
		textdata = textdata[:-1]
		textdata += ");\n\t"
	return textdata

def genProgHL(layers_lines,layers_names,program_uuid,grmode_dims,vc,  dtype='byte'):
	program_str = "\nvar\n\ti:word;\n\ty,c:byte;\n\tptr:^byte;"
	program_str += procedureHLDraw 
	program_str += "\nbegin\n\tInitGraph("+str(vc+8)+"+16);\n"
	for i in range(len(layers_names)):
		y = layers_lines[i][0]
		color = layers_names[i]
		color = str(color)
		ln = len(layers_lines[i])
		y = str(y)
		data = "data_"+program_uuid+"_"+str(color)
		program_str += "\tptr := @"+data+";\n"
		program_str += "\tdrawCol("+str(ln)+","+color+");\n"

	return program_str