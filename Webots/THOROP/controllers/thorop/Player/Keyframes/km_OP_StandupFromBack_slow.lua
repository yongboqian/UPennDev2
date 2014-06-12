local mot={};
mot.servos={
1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,};
mot.keyframes={ 
   {
    angles={
0,0,
2.1526863723328,0.19941750242513,-0.80278327899349,
0,0,-1.0891263593988,1.6924921359672,-0.73631077818511,0.097152116566091,
0,0,-1.0942396286918,1.6618125202094,-0.79255674040758,0.092038847273138,
2.1526863723328,-0.19941750242513,-0.80278327899349,
    },
duration = 0.5; 
  },
  {
    angles={
0,0,
3.7991590846634,0.0051132692929521,-2.5719744543549,
0,0,-0.78744347111463,1.6157930965729,0.46530750565864,0.046019423636569,
0,0,-0.76699039394282,1.5953400194011,0.45508096707274,0.17896442525332,
3.7991590846634,-0.0051132692929521,-2.5719744543549,
    },
duration = 0.5; 
  },
  {
    angles={
0,0,
4.0855021650688,0.056245962222474,-1.8100973297051,
0,0,-1.1965050145508,1.7794177139473,0.32724923474894,-0.010226538585904,
0,0,-1.2322978996015,1.7691911753614,0.39372173555731,-0.035792885050665,
4.0855021650688,-0.056245962222474,-1.8100973297051,
    },
duration = 0.5; 
  },

  {
    angles={
-0.0015339807878856,-0.69796125848797,3.822680123411,0.42951462060798,-0.63660202697254,0.023009711818285,0.0015339807878856,0.57370881466923,1.0246991663076,-0.0015339807878856,-0.016873788666742,0.0076699039394282,0.0015339807878856,0.53535929497209,1.020097223944,0.0015339807878856,0.023009711818285,3.9500005288055,-0.45099035163838,-0.65961173879083,
    },
duration = 1; 
  },
  {
    angles={
-0.0015339807878856,-0.69796125848797,2.8823499004371,0.2561747915769,-0.16720390587953,0.023009711818285,0.0015339807878856,0.58444668018443,1.9036701577661,-1.4066603824911,-0.016873788666742,0.0076699039394282,0.0015339807878856,0.5445631796994,1.8484468494022,-1.368310862794,0.023009711818285,3.1109130378321,-0.11965050145508,-0.30679615757713,
    },
duration = 1; 
  },
  {
    angles={
-0.0015339807878856,-0.69796125848797,1.0584467436411,0.2561747915769,-0.16720390587953,0.023009711818285,0.0015339807878856,0.58444668018443,1.6474953661892,-1.4066603824911,-0.016873788666742,0.0076699039394282,0.0015339807878856,0.5445631796994,1.5922720578253,-1.368310862794,0.023009711818285,1.0615147052169,-0.11965050145508,-0.30679615757713,
    },
duration = 1; 
  },


--SJ: This is final pose of bodySit
  {
    angles={
	0,0,
	105*math.pi/180, 30*math.pi/180, -45*math.pi/180,
	0,  0.055, -0.77, 2.08, -1.31, -0.055, 
	0, -0.055, -0.77, 2.08, -1.31, 0.055,
	105*math.pi/180, -30*math.pi/180, -45*math.pi/180,
	},
    duration=0.7;
  },


};

return mot;
