10 'ChanTST by FRS, 2017
20 'Plays one note in each channel of the OPLL and PSG, to test if all channels are working properly
30 'The FM channels 1 to 3 will play the piano so the envelope generator can be  tested
40 'The FM channels 4 to 9 will play a square wave to allow the volume of the PSG and FM match
55 '
50 _MUSIC(0,0,1,1,1,1,1,1,1,1,1)
60 DIMX%(15)
70 RESTORE90:FORY=0TO15:READW$:X%(Y)=VAL("&H"+W$):NEXTY
80 _VOICECOPY(X%,@63)
90 DATA 0,0,0,0,0,1E,0,0,9524,FFF0,0,0,4022,FFF0,0,0:'Square wave on FM
100 _VOICE(@0,@0,@0,@63,@63,@63,@63,@63,@63)
110 PLAY#2,"v15","v15","v15","v15","v15","v15","v15","v15","v15","v15","v15","v15"
120 PLAY#2,"c","rd","rre","rrrf","rrrrg","rrrrra","rrrrrrb","rrrrrrrc","rrrrrrrrd","rrrrrrrrre","rrrrrrrrrrf","rrrrrrrrrrrg"
130 GOTO 110