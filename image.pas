
uses crt, fastgraph;
  
const
	data_65fadaa9_1: array [0..2575] of byte = (0,0,159,1,35,2,159,17,108,18,159,24,109,25,159,32,136,33,159,38,134,47,159,95,141,96,159,99,143,100,159,102,148,103,159,103,149,104,159,110,154,111,159,191,136,41,159,46,137,39,159,40,79,112,153,113,91,114,153,114,105,115,153,115,123,116,153,116,136,117,153,117,143,118,153,126,148,127,153,140,150,141,153,191,145,142,149,143,147,144,149,144,129,146,149,149,130,150,149,159,131,160,149,170,132,171,149,180,133,181,149,182,134,183,149,186,135,187,149,191,139,141,148,141,84,128,147,133,129,134,147,134,134,135,147,135,137,136,147,137,140,138,147,138,142,139,147,139,85,127,146,127,142,145,148,145,142,140,145,140,142,142,144,142,137,144,145,144,135,119,142,122,140,123,142,126,135,143,142,143,132,118,141,118,138,97,140,97,140,98,140,98,137,140,140,140,134,139,139,139,134,142,139,142,129,145,139,145,133,138,137,138,131,141,137,141,135,140,135,140,129,144,135,144,109,33,134,34,109,35,133,37,123,86,133,92,129,137,133,137,128,143,133,143,109,38,132,40,131,84,133,85,121,139,132,140,128,142,132,142,109,41,131,43,129,178,131,179,109,44,130,45,122,136,130,136,130,166,130,167,130,170,130,170,127,177,130,177,109,46,129,47,110,48,129,48,116,60,129,62,129,135,129,135,129,138,129,138,127,176,129,176,109,49,128,50,117,63,129,63,113,65,128,66,126,67,128,67,124,141,128,141,128,171,128,171,128,179,128,179,108,51,127,52,109,53,127,54,117,64,128,64,126,137,127,138,108,55,126,56,123,142,126,142,126,164,126,165,126,180,126,180,108,57,125,57,110,58,125,58,124,138,125,138,121,143,125,143,114,59,125,59,120,144,123,144,118,67,124,69,118,141,122,141,118,145,121,145,119,174,121,174,120,175,121,176,121,182,121,182,110,71,123,71,120,140,120,140,117,142,120,142,119,177,120,177,120,181,120,181,115,143,119,143,111,146,119,146,119,176,119,176,118,178,119,180,118,149,118,149,118,168,118,169,117,181,118,181,114,144,117,144,115,147,118,147,113,148,117,148,111,145,116,145,113,149,115,149,115,183,115,183,111,150,114,150,114,153,114,153,112,119,121,119,109,147,113,147,109,151,113,151,112,67,112,67,111,185,112,185,110,59,111,60,107,64,111,65,108,148,111,148,108,152,111,152,111,186,111,186,106,149,110,149,109,60,109,60,100,153,109,153,108,26,108,30,108,63,110,63,105,150,108,150,104,154,108,154,103,151,107,151,103,152,105,152,103,155,106,155,102,156,105,156,37,18,106,19,38,20,106,20,38,21,105,22,38,23,104,23,40,24,104,24,64,86,111,88,62,89,110,89,64,90,106,94,99,154,102,154,100,157,103,157,99,158,102,158,41,25,103,25,42,26,103,26,43,27,103,28,75,83,113,85,63,95,104,95,44,29,103,29,45,30,102,30,45,31,101,31,98,155,100,155,97,159,100,159,47,32,100,33,48,34,99,34,49,35,99,35,81,78,106,79,96,156,99,156,50,36,98,36,51,37,98,38,78,80,105,80,62,97,104,99,94,157,98,157,95,160,98,160,52,39,97,40,54,41,97,41,55,42,96,42,56,43,96,44,58,45,96,45,77,81,104,82,93,158,96,158,94,161,97,161,58,46,95,47,93,162,95,162,59,48,94,49,62,50,94,51,92,159,94,159,92,163,94,163,63,52,93,52,65,53,93,57,63,96,103,96,90,164,93,165,62,58,92,60,83,77,108,77,90,160,93,160,91,158,91,158,89,161,91,161,87,166,91,166,90,184,91,184,62,61,90,62,88,162,90,162,90,163,90,163,62,63,89,63,86,167,89,167,89,168,89,169,61,64,88,65,85,163,88,164,88,165,89,165,57,66,87,66,84,168,87,168,83,165,86,165,82,169,86,170,84,164,84,164,81,166,84,166,82,120,83,120,82,122,86,122,79,123,85,124,76,125,84,125,74,126,83,127,79,171,83,171,83,173,83,173,80,121,82,121,79,167,83,167,78,168,82,168,72,128,82,128,78,172,81,172,74,129,81,129,80,165,80,165,76,173,80,173,79,100,141,110,77,169,80,169,78,109,78,109,77,166,78,166,75,170,78,170,73,175,78,175,75,174,78,174,77,177,77,177,73,107,76,107,76,109,76,110,73,171,77,171,72,176,76,176,72,172,76,172,72,108,74,108,70,173,74,173,69,177,74,177,69,174,73,174,68,178,73,178,70,112,73,112,67,179,71,179,66,180,70,180,67,175,71,175,66,176,69,176,63,177,67,177,63,182,67,182,66,173,66,174,61,178,66,178,64,181,67,181,64,174,65,174,60,179,65,179,61,183,65,183,63,54,64,54,60,184,64,184,63,185,63,185,62,55,62,56,59,180,63,180,57,124,73,124,57,125,71,125,58,181,61,181,57,185,61,186,58,59,60,59,60,65,60,65,56,67,60,67,60,68,60,68,56,182,60,182,60,188,60,188,59,51,59,52,57,108,61,108,55,187,59,187,58,52,58,52,57,54,58,54,56,68,58,68,58,69,58,69,57,99,61,101,58,109,60,109,58,110,59,110,58,177,58,177,58,179,58,179,55,183,58,183,58,184,58,184,53,188,58,188,57,55,57,56,55,111,58,112,56,56,56,56,56,100,56,104,56,175,56,176,53,184,56,184,55,44,55,44,54,57,55,57,54,69,56,69,50,70,55,70,54,113,56,114,49,121,56,123,52,185,55,186,51,189,56,189,50,190,55,190,54,58,54,58,53,68,54,68,54,71,54,71,53,76,54,76,54,182,54,182,52,59,53,59,49,61,53,61,53,62,53,62,53,101,55,104,53,110,53,112,53,114,53,120,53,124,53,134,48,191,53,191,52,42,52,42,52,60,52,60,52,63,52,63,52,114,52,114,49,135,52,136,51,182,52,182,52,183,52,183,51,45,51,45,51,62,51,62,47,71,52,71,51,73,51,73,51,76,51,76,51,102,52,106,51,109,52,109,49,115,51,115,51,131,52,133,50,186,51,188,46,132,50,132,50,133,50,134,49,37,49,38,49,62,49,62,45,127,52,128,48,134,49,134,47,188,49,189,46,45,48,45,48,70,48,70,47,72,50,72,48,77,48,77,48,105,50,108,44,190,48,190,45,73,48,73,47,106,47,115,46,133,47,133,47,137,49,140,47,186,47,186,45,35,46,35,44,38,46,38,44,74,46,75,45,189,46,189,42,191,46,191,45,32,45,34,43,65,45,65,45,76,45,76,45,109,46,111,42,39,44,39,44,46,44,46,43,49,44,49,40,66,43,66,41,81,43,83,42,84,43,84,43,113,44,114,41,31,42,31,42,32,42,32,39,67,42,67,41,75,43,75,42,78,42,78,42,115,43,115,41,30,41,30,41,33,41,35,40,65,41,65,39,68,41,68,38,80,41,80,41,117,42,118,40,34,40,34,38,76,41,77,34,78,40,78,39,79,40,79,40,83,40,84,40,120,41,120,40,125,40,125,39,32,39,33,39,73,39,74,38,24,38,24,37,75,38,75,37,22,37,22,37,30,37,30,35,73,37,73,36,74,37,74,36,76,37,76,36,77,36,77,34,79,37,79,35,98,36,99,35,25,35,25,35,40,35,40,35,69,35,72,35,97,35,97,35,123,35,123,34,4,34,15,34,27,34,27,34,33,34,33,34,38,34,38,34,70,34,72,32,75,34,75,34,127,34,127,34,149,34,149,7,2,33,3,33,5,33,14,31,25,33,25,32,26,33,26,33,30,33,30,32,48,33,48,33,64,33,64,33,74,33,74,32,76,33,76,32,80,35,80,33,81,33,82,32,91,33,91,32,128,33,128,22,6,32,7,28,8,32,8,29,9,32,10,31,11,32,12,32,13,32,13,32,78,32,78,32,89,32,90,32,127,32,127,15,4,32,4,28,82,31,83,31,84,31,84,30,118,31,118,23,5,31,5,30,26,30,28,29,46,30,46,30,128,30,129,24,22,29,22,26,93,29,93,28,98,29,99,28,104,29,107,28,114,29,114,28,27,28,27,28,67,28,67,24,84,28,84,27,94,28,95,24,112,28,112,28,113,28,113,28,115,28,115,26,83,27,83,27,89,27,92,26,110,27,111,22,85,26,85,26,87,26,87,26,90,26,90,26,96,26,96,25,115,26,115,26,140,29,150,26,180,26,180,25,31,25,31,23,50,25,50,25,81,25,81,21,106,25,106,22,107,25,109,25,111,25,111,24,113,25,113,25,114,25,114,25,118,25,118,23,141,25,141,14,9,24,9,24,29,24,29,22,51,24,51,24,83,24,83,21,86,24,86,21,104,24,104,21,110,24,110,23,142,24,142,23,10,23,10,22,43,23,43,23,52,23,53,21,105,23,105,21,116,23,116,22,144,25,144,18,8,25,8,22,44,22,44,21,53,22,53,19,87,22,87,21,93,22,93,21,117,22,117,22,143,22,143,22,188,22,188,21,7,21,7,20,31,21,31,21,94,21,94,21,99,21,99,21,108,21,109,21,111,21,111,21,130,21,130,21,162,21,163,20,52,20,52,18,100,20,100,20,109,20,109,20,184,20,184,11,11,19,11,18,32,19,32,19,56,19,57,9,101,19,101,13,102,19,103,19,165,19,165,13,10,20,10,18,14,18,14,18,26,18,26,18,52,18,53,15,89,18,89,18,92,18,93,17,96,18,98,18,99,18,99,17,104,18,105,9,12,17,12,16,88,19,88,17,93,17,94,17,112,17,112,16,20,16,20,13,90,16,90,16,91,16,91,13,94,16,95,15,96,15,96,15,100,15,100,5,14,14,14,13,41,14,42,14,57,14,57,13,81,14,82,14,87,14,87,14,92,14,93,11,104,14,104,9,106,14,106,14,109,14,113,14,168,14,168,11,91,13,91,11,105,13,105,13,110,13,115,13,190,13,190,12,78,12,78,9,92,12,92,12,93,12,93,12,96,12,99,9,103,12,103,7,107,12,107,10,108,12,108,12,114,12,114,12,188,12,188,7,13,13,13,9,41,11,41,11,95,11,95,10,100,11,100,11,109,11,109,10,126,11,126,11,180,11,182,10,56,10,56,9,58,10,59,10,81,10,84,10,86,10,86,10,90,10,90,5,93,10,94,10,96,10,96,9,102,10,102,10,124,10,125,9,57,9,57,8,60,9,60,9,82,9,84,8,87,9,87,8,99,9,99,9,172,9,172,7,15,9,15,7,42,8,42,8,61,8,61,6,83,8,83,7,84,8,84,8,88,8,88,8,91,8,91,3,95,8,95,6,108,8,109,0,16,7,16,7,19,7,20,7,39,7,39,7,43,7,43,7,78,7,82,6,85,7,85,7,92,7,92,7,171,7,173,0,2,6,2,6,20,6,20,6,77,6,77,6,79,6,82,5,97,6,97,6,174,6,174,4,55,5,57,3,81,5,81,5,87,5,88,4,103,5,103,5,175,5,175,4,13,4,13,3,15,5,15,3,17,4,17,3,82,4,82,3,86,4,86,0,88,4,88,3,102,4,102,4,176,4,176,3,14,3,14,2,27,3,28,2,41,3,41,2,80,3,80,3,83,3,84,2,89,3,89,0,97,3,97,3,100,3,100,2,118,3,119,2,122,3,122,2,131,3,132,0,18,2,18,2,42,2,42,2,78,2,79,0,87,2,87,1,96,4,96,2,121,2,121,0,54,1,54,0,58,1,59,0,91,1,91,0,98,1,99,0,110,1,114,0,19,0,20,0,60,0,61,0,74,0,76,0,89,0,89);
	data_65fadaa9_2: array [0..2999] of byte = (159,34,159,34,159,36,159,36,156,39,159,39,158,40,159,45,159,46,159,46,159,146,159,146,159,148,159,148,158,35,158,35,158,38,158,38,158,47,158,47,157,149,158,149,158,151,158,151,157,22,157,22,156,42,157,42,157,46,157,46,155,147,157,147,155,150,157,150,156,38,156,38,156,50,156,50,129,79,156,80,130,81,156,81,154,148,156,148,156,151,156,151,155,40,155,40,149,51,155,51,132,82,155,82,133,83,155,83,79,109,155,109,155,145,155,145,154,42,154,43,153,50,154,50,131,84,154,84,80,110,154,110,153,146,154,146,154,149,154,149,153,43,153,43,149,52,153,52,150,53,153,53,153,54,153,55,129,78,153,78,79,108,153,108,153,144,153,144,153,147,153,147,152,44,152,44,78,107,152,107,80,111,152,112,151,46,151,46,148,50,151,50,151,56,151,56,78,113,151,113,150,146,151,146,151,148,151,148,150,47,150,47,150,59,150,59,129,77,150,77,77,106,150,106,91,114,150,114,74,105,149,105,105,115,149,115,148,142,149,142,148,147,149,147,147,18,148,18,147,20,148,20,148,54,148,54,147,85,148,85,123,116,148,116,147,144,148,145,146,148,148,148,147,16,147,16,147,63,147,63,129,76,147,76,74,104,147,104,146,52,146,52,146,57,146,61,146,64,146,64,75,103,146,103,136,117,146,117,146,142,146,142,144,146,146,146,145,17,145,17,145,19,145,19,145,54,145,55,142,59,145,59,143,60,145,60,145,65,145,65,76,102,145,102,145,141,145,141,144,144,145,144,143,58,144,58,141,61,144,61,144,63,144,63,129,75,144,75,76,101,144,101,143,57,143,57,142,142,143,142,143,145,143,145,140,18,142,18,142,65,142,65,142,69,142,69,141,85,142,85,142,140,142,140,142,146,142,146,141,16,141,16,141,60,141,60,141,64,141,64,141,67,141,67,129,74,141,74,77,100,141,100,140,68,140,68,139,15,139,15,139,17,139,17,59,99,139,99,138,143,139,143,138,64,138,64,136,73,138,73,137,16,137,16,135,35,137,35,97,98,137,98,137,140,137,140,135,34,136,34,136,36,136,38,135,41,136,42,136,44,136,44,134,47,136,53,133,55,136,55,136,141,136,141,134,37,135,38,135,39,135,40,134,43,135,43,133,54,135,54,133,56,135,56,134,57,135,64,135,93,135,97,134,142,135,142,134,36,134,36,134,46,134,46,132,65,134,66,133,85,134,85,133,184,134,184,134,185,134,186,133,188,134,190,133,52,133,53,133,58,133,64,131,67,133,67,131,69,133,73,129,97,133,97,133,140,133,140,131,180,133,180,133,181,133,182,132,13,132,13,132,59,132,64,131,68,132,68,132,189,132,189,131,64,131,64,131,66,131,66,131,85,131,85,128,96,131,96,131,188,131,188,130,71,130,73,130,137,130,137,128,59,129,59,128,95,129,95,128,187,129,187,129,188,129,188,128,11,128,11,128,13,128,13,128,64,128,65,128,80,128,80,127,176,128,176,128,181,128,181,123,189,128,189,125,190,128,190,128,191,128,191,126,12,127,12,127,61,127,63,127,76,127,76,110,94,127,94,127,186,127,186,127,188,127,188,126,68,126,68,126,77,126,77,111,93,126,93,109,95,126,97,125,59,125,66,113,92,133,92,124,11,124,11,124,62,124,69,119,8,123,8,123,64,123,71,114,91,132,91,123,191,123,191,121,10,122,10,122,68,122,72,111,70,121,70,121,71,121,76,114,90,121,90,114,119,121,119,121,120,121,120,98,72,120,72,115,73,120,79,91,121,120,121,110,71,119,71,109,80,119,80,116,81,119,85,115,87,119,87,114,89,119,89,118,141,119,141,115,86,118,86,114,88,118,88,118,147,118,147,116,9,117,9,115,69,117,69,116,68,116,68,96,82,115,83,115,84,115,85,112,6,114,6,114,8,114,8,114,74,114,79,107,81,114,81,114,146,114,146,113,75,113,79,102,84,113,85,109,73,112,73,112,76,112,79,100,86,112,86,112,119,112,119,112,151,112,151,106,65,111,65,107,74,111,75,111,77,111,79,103,87,111,88,91,120,111,120,111,145,111,146,108,56,110,57,109,63,110,64,104,66,110,66,103,76,110,76,110,78,110,79,103,89,110,89,108,55,109,55,109,62,109,62,103,67,109,68,109,79,109,79,102,90,109,91,109,149,109,149,109,151,109,151,108,54,108,54,108,58,108,58,107,64,108,64,100,69,108,69,93,77,108,77,99,92,108,92,108,96,108,97,107,4,107,4,106,6,107,6,105,17,107,17,100,70,107,70,98,93,107,93,106,97,107,97,105,18,106,20,99,71,106,71,99,73,106,73,105,75,106,75,100,78,106,79,103,94,106,94,106,155,106,155,104,21,105,22,99,80,105,80,105,154,105,154,103,5,104,5,104,19,104,20,103,23,104,24,97,81,104,81,102,95,104,95,99,97,104,97,102,25,103,29,94,96,103,96,103,157,103,157,101,30,102,30,102,38,102,39,92,74,102,74,92,117,102,117,101,28,101,29,101,31,101,31,101,37,101,37,101,40,101,41,99,87,101,87,101,91,101,91,92,118,101,119,100,32,100,33,89,75,100,75,98,88,100,88,96,89,99,89,97,94,99,94,99,154,99,154,98,1,98,1,98,38,98,38,85,76,98,76,81,78,98,78,94,84,98,85,95,95,98,95,94,73,97,73,95,90,97,90,97,161,97,161,95,1,96,1,95,3,96,3,91,79,96,79,95,86,96,86,95,91,96,91,62,97,96,97,94,83,95,83,95,92,95,92,61,98,95,98,95,161,95,161,94,6,94,6,92,7,93,8,93,55,93,55,93,57,93,57,89,93,93,93,93,158,93,158,93,160,93,160,93,162,93,162,91,5,92,6,91,9,92,9,92,10,92,10,92,60,92,60,90,80,92,80,92,82,92,82,92,92,92,92,89,94,92,95,92,163,92,163,83,77,91,77,89,81,91,81,86,96,91,96,62,90,90,91,89,92,90,92,90,160,90,160,89,4,89,5,89,8,89,8,89,13,89,13,89,15,89,15,87,82,89,82,88,84,89,84,85,88,89,89,77,114,89,114,89,125,144,125,89,165,89,165,87,1,88,1,88,6,88,7,88,17,88,17,79,79,88,79,86,83,88,83,87,87,88,87,88,95,88,95,65,115,88,115,88,162,88,162,87,166,88,166,87,18,87,19,62,67,87,67,86,10,86,10,86,20,86,20,59,66,86,66,62,68,86,69,84,80,86,80,84,84,86,84,62,92,86,92,73,116,86,116,84,122,86,122,86,163,86,163,86,167,86,168,85,1,85,1,85,14,85,14,85,16,85,19,85,22,85,23,62,65,85,65,62,70,85,70,83,81,85,81,84,121,85,121,84,123,85,124,85,169,85,169,84,13,84,13,83,23,84,23,84,24,84,24,62,64,84,64,63,71,84,72,81,86,84,86,62,89,84,89,61,93,84,93,63,96,84,96,84,125,84,125,82,0,83,0,83,1,83,1,83,15,83,18,83,25,83,25,62,63,83,63,63,73,83,73,76,82,83,82,83,85,83,85,64,94,83,95,74,117,83,117,83,167,83,167,82,16,82,16,81,21,82,21,82,26,82,27,62,62,82,62,63,74,82,74,80,83,82,83,64,87,82,88,74,118,82,118,82,128,82,128,81,27,81,29,62,61,81,61,63,75,81,75,78,80,81,80,79,84,81,84,61,119,81,119,81,123,81,123,81,129,81,129,80,20,80,20,80,30,80,31,62,60,80,60,63,76,80,76,77,81,80,81,74,126,80,127,76,130,80,130,80,167,80,167,80,169,80,169,80,171,80,171,79,32,79,33,62,59,79,59,63,77,79,77,73,85,79,85,79,112,79,112,60,120,79,120,72,128,79,128,74,129,79,129,78,131,79,141,78,23,78,23,78,26,78,26,75,34,78,34,62,58,78,58,62,78,78,78,75,83,78,83,64,86,78,86,78,111,78,111,59,121,78,121,78,124,78,125,78,174,78,174,77,24,77,25,71,35,77,35,77,36,77,36,63,57,77,57,63,79,77,79,75,84,77,84,77,110,77,110,58,122,77,122,76,125,77,125,77,171,77,171,77,173,77,173,76,13,76,13,76,27,76,27,76,29,76,30,72,37,76,38,63,56,76,56,63,80,76,80,76,109,76,109,76,112,77,112,76,172,76,172,75,12,75,12,75,28,75,28,73,31,75,31,74,36,75,36,75,39,75,39,73,106,75,107,75,114,75,114,58,123,75,123,75,170,75,170,75,176,75,176,73,10,74,10,74,11,74,11,74,30,74,30,73,32,74,33,64,55,74,55,74,113,74,113,74,171,74,171,72,8,73,8,73,34,73,34,72,40,73,40,65,54,73,54,62,81,73,81,57,100,73,100,73,103,73,103,72,108,73,108,72,112,73,112,62,124,73,124,73,127,73,127,72,33,72,33,72,36,72,36,63,82,72,82,54,101,72,101,71,104,72,104,71,109,72,109,72,110,73,110,72,174,72,174,72,176,72,176,72,178,72,178,71,34,71,34,69,38,71,38,66,53,71,53,62,83,71,84,64,85,71,85,70,105,71,105,71,113,72,113,70,114,71,114,62,118,72,118,62,125,71,125,70,173,71,173,70,175,71,175,70,36,70,37,69,39,70,39,68,52,70,52,66,102,70,102,69,106,70,106,69,110,70,111,70,112,70,112,64,116,71,116,63,117,70,117,61,126,70,126,70,177,70,177,65,103,69,103,69,107,69,107,69,176,69,176,69,178,69,178,69,180,69,180,64,104,68,104,68,108,68,108,68,111,68,114,50,127,68,127,63,105,67,105,67,112,67,114,50,128,67,128,67,175,67,175,67,179,67,179,67,181,67,181,66,113,66,114,66,176,66,176,66,180,66,180,66,182,66,182,65,114,65,114,53,129,65,129,60,102,64,102,63,106,64,107,63,95,63,95,51,103,63,103,52,130,63,130,63,178,63,178,63,180,63,180,63,184,63,184,60,107,62,107,52,131,62,131,50,104,61,104,58,105,61,105,61,106,61,106,60,108,61,108,51,132,61,132,61,179,61,179,61,183,61,183,61,185,61,185,59,109,60,109,57,124,60,125,60,180,60,180,58,106,59,106,59,110,59,110,56,126,59,126,51,133,59,133,57,67,58,67,52,102,58,102,57,107,58,107,58,111,58,112,54,134,58,134,58,185,58,187,57,112,57,112,57,187,57,188,56,68,56,69,56,113,56,114,55,120,56,120,56,121,56,123,54,135,56,135,56,182,56,182,56,188,56,189,55,114,55,114,46,124,55,124,55,125,55,125,48,136,55,136,55,187,55,187,54,69,54,70,54,115,54,116,53,121,54,123,46,126,54,126,54,189,54,189,48,106,53,106,53,107,53,108,52,116,53,120,45,125,53,125,53,184,53,184,53,186,53,186,53,190,53,190,52,71,52,71,49,105,52,105,52,108,52,109,46,123,52,123,51,137,52,155,52,187,52,187,52,189,52,189,52,191,52,191,51,70,51,70,47,107,51,107,50,110,51,111,49,117,51,117,50,118,51,122,45,129,51,129,50,134,51,135,49,72,50,72,46,108,50,108,46,112,50,112,47,113,50,114,49,115,50,116,45,130,50,130,47,138,50,138,50,188,50,188,46,109,49,109,49,121,49,122,46,131,49,132,49,135,49,135,48,137,49,137,46,139,49,140,48,187,49,187,48,73,48,73,45,110,48,111,48,122,48,122,45,127,48,128,46,115,47,115,47,120,47,121,47,188,47,188,46,114,46,114,46,116,46,118,46,133,46,133,46,141,46,141,45,74,45,74,45,117,45,120,45,189,45,189,43,75,44,75,44,113,44,114,44,119,44,123,44,190,44,190,43,28,43,28,43,115,43,116,43,121,43,125,43,191,43,191,40,76,42,76,42,117,42,118,42,123,42,125,42,133,42,134,41,77,41,77,41,119,41,120,41,124,41,124,40,121,40,123,39,78,39,78,37,123,38,123,37,78,37,79,36,125,38,126,34,79,35,80,31,0,34,1,25,143,34,144,31,2,33,2,30,81,33,81,26,142,33,142,24,145,33,145,32,3,32,4,32,80,32,80,23,146,32,147,31,5,31,5,22,148,31,148,29,3,30,3,30,4,30,4,28,6,30,6,30,82,30,82,26,141,30,141,21,149,30,149,29,83,29,83,27,140,29,140,21,150,29,150,28,2,28,2,28,82,28,82,28,139,28,139,20,151,28,151,25,84,27,84,20,152,27,152,25,7,26,7,26,83,26,83,19,153,26,153,25,5,25,5,23,8,25,8,23,85,25,85,19,154,25,154,24,6,24,6,24,144,24,144,18,155,24,155,22,9,23,9,18,156,23,156,22,7,22,7,21,86,22,86,22,147,22,147,18,157,22,157,17,158,21,158,19,10,20,10,20,87,20,87,17,159,20,159,19,9,19,9,18,88,19,88,16,160,19,160,16,161,18,161,16,10,17,10,17,11,17,11,15,89,17,89,15,162,17,162,16,12,16,12,15,163,16,163,14,164,15,164,13,11,14,11,13,165,14,165,12,13,13,13,13,90,13,90,13,166,13,166,12,167,12,167,11,14,11,14,9,92,11,92,11,168,11,168,8,93,10,93,9,13,9,13,9,15,9,15,7,14,7,14,7,94,7,94,5,15,5,15,5,95,5,95,3,96,4,96,3,95,3,95,1,97,2,97,0,17,0,17,0,98,0,98);
	data_65fadaa9_0: array [0..895] of byte = (150,96,150,96,148,97,148,97,145,95,146,95,146,98,146,98,145,128,145,130,144,99,144,99,90,125,144,125,83,129,144,131,90,126,143,128,63,132,143,132,141,99,142,99,65,133,142,133,130,94,140,94,132,95,140,95,90,124,140,124,129,134,140,134,138,96,139,97,128,93,138,93,124,120,138,120,132,121,138,123,137,92,137,92,135,119,137,119,134,96,136,96,126,92,133,92,124,91,132,91,132,118,132,119,131,52,131,53,124,119,131,119,121,122,131,123,125,118,130,118,123,121,130,121,129,63,129,63,125,117,129,117,126,87,128,90,128,142,128,143,128,147,128,147,65,134,127,134,126,60,126,60,65,135,126,135,122,136,126,136,126,139,126,139,123,86,125,86,121,88,125,89,123,90,125,90,124,140,125,140,123,137,124,137,124,145,124,145,122,87,123,87,123,146,123,146,115,117,122,117,122,138,122,138,115,118,121,118,121,139,121,139,114,119,120,119,88,123,120,123,119,138,120,138,113,120,119,122,116,136,118,136,118,139,118,139,118,141,118,141,113,65,117,66,117,116,117,116,116,62,116,62,114,64,115,64,114,67,115,67,112,61,113,62,105,116,113,117,112,136,113,136,112,63,112,63,112,121,112,122,112,143,112,143,111,60,111,60,111,62,111,62,104,118,111,118,91,122,111,122,111,145,111,145,110,61,110,61,103,119,110,121,101,136,110,136,108,137,109,137,105,49,105,49,91,120,102,121,89,116,101,116,91,115,100,115,92,117,100,119,99,136,99,136,90,136,96,136,94,155,94,155,90,137,92,138,91,119,91,119,90,139,91,139,89,117,90,117,90,118,90,118,90,140,90,140,88,122,89,122,85,127,89,128,87,124,88,124,85,126,88,126,86,125,87,125,84,128,84,128,65,136,84,136,83,119,83,119,65,137,83,137,82,120,82,120,82,130,82,131,52,138,82,138,81,131,81,131,64,139,81,140,80,121,80,122,65,141,80,141,79,122,79,122,65,142,78,142,77,112,77,112,64,131,76,131,76,144,76,144,73,115,74,115,74,116,74,116,66,130,74,130,70,143,74,143,73,110,73,110,73,114,73,114,46,144,73,145,72,146,73,146,72,112,72,113,72,117,72,118,70,115,71,115,71,116,71,116,67,129,71,129,70,114,70,114,69,128,70,128,44,146,69,147,46,143,68,143,42,148,67,148,41,149,65,149,62,89,63,93,61,133,63,133,48,141,63,142,38,150,63,150,62,81,62,81,62,83,62,84,62,86,62,86,62,88,62,88,62,94,62,94,60,134,62,137,51,139,62,140,61,93,61,93,61,96,61,96,39,151,60,151,58,135,59,137,41,152,58,152,43,153,58,153,57,136,57,137,55,110,56,111,54,137,56,137,54,112,55,112,41,154,55,154,54,113,54,113,53,114,53,114,40,155,53,155,39,156,51,157,49,140,50,140,48,134,48,134,41,158,48,158,47,135,47,135,47,142,47,142,40,159,47,159,47,160,47,160,45,145,45,145,40,160,45,160,44,144,44,144,43,131,43,131,43,147,43,147,42,146,42,146,39,161,42,162,41,145,41,145,41,153,41,153,36,163,41,163,40,133,40,133,40,146,40,147,36,164,40,164,39,124,39,124,38,147,39,148,37,158,39,158,37,125,38,126,35,132,38,133,36,135,38,135,38,136,38,136,36,149,38,149,38,157,38,157,35,159,38,159,36,165,38,165,36,127,37,127,36,131,37,131,35,134,37,134,37,137,37,137,37,148,37,148,37,151,37,151,35,166,37,166,35,128,36,128,36,129,36,129,36,136,36,136,36,150,36,150,33,160,36,160,34,151,35,152,32,161,35,161,35,162,35,162,33,153,33,154,32,168,33,169,31,154,32,154,29,162,32,162,30,163,32,163,31,170,32,170,30,155,31,155,30,164,31,165,30,171,31,171,29,156,30,156,30,172,30,172,28,157,29,157,27,158,28,158,25,159,26,159,24,160,25,160,22,161,24,161,21,162,21,162,18,163,19,163);

var
	i:dword;
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

begin
	initgraph(16+15);
	SetColor(3);
	B(0,0,160,192);
	setColor(1);
	for i := 0 to 643 do
	begin
		B(data_65fadaa9_1[i*4],data_65fadaa9_1[i*4+1],data_65fadaa9_1[i*4+2],data_65fadaa9_1[i*4+3]);
	end;
	setColor(2);
	for i := 0 to 749 do
	begin
		B(data_65fadaa9_2[i*4],data_65fadaa9_2[i*4+1],data_65fadaa9_2[i*4+2],data_65fadaa9_2[i*4+3]);
	end;
	setColor(0);
	for i := 0 to 223 do
	begin
		B(data_65fadaa9_0[i*4],data_65fadaa9_0[i*4+1],data_65fadaa9_0[i*4+2],data_65fadaa9_0[i*4+3]);
	end;
	repeat until false;
end.