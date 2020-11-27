import ddf.minim.*;
import ddf.minim.analysis.*;

//analysis objects//
Minim minim;  
AudioInput in;
FFT fft; 
FFT fftLog;
BeatDetect beat;

float t; //camera orbit parameter
float tOld; //smoothing variable for transitions
float o; //camera orientation parameter
float a; //camera oscillation parameter
float r; //sphere radius
float rOld;
float boxEdgeLength;

float orientOffset;
float orientMult1;
float orientMult2;

float camX;
float camY;
float camZ;

boolean rotMode; //true = full rotation; false = 120 degree oscillation

PImage img; //contains image to be mapped to inside of sphere

float[] fftMaxVals;
float[] fftSmooth;
float[] fftOld;
float smoothFact = 0.8;

//variables for score calculation
//portions of the spectrum
float specLow = 0.03; // 3%
float specMid = 0.125;  // 12.5%
float specHi = 0.20;   // 20%

//contains current score
float scoreLow = 0;
float scoreMid = 0;
float scoreHi = 0;

//previous score initialized to 0
float oldScoreLow = scoreLow;
float oldScoreMid = scoreMid;
float oldScoreHi = scoreHi;

float scoreDecreaseRate = 10;

void setup() {
  //size(1024, 512, P3D);
  fullScreen(P3D);
  background(100);

  r = 200;
  boxEdgeLength = r / 4;
  t = 0;
  tOld = t;
  a = 0;
  o = 0;
  rotMode = true;

  orientOffset = random(0, HALF_PI);
  orientMult1 = random(0, 3);
  orientMult2 = random(0, 3);

  img = loadImage("starry-sky.jpg");

  minim = new Minim(this);
  in = minim.getLineIn();
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.window(FFT.HAMMING);
 
  //FFT for extrusion; should be more visually appealing; need to decide frequency ranges for low, hi, and mid
  fftLog = new FFT(in.bufferSize(), in.sampleRate());
  fftLog.logAverages(88, 12);
  fftLog.window(FFT.HAMMING);
  
  //smoothing setup; used for extrusion
  fftOld = new float[fft.specSize()];
  fftSmooth = new float[fft.specSize()];
  beat = new BeatDetect();
}

void draw() {
  background(0);
  
  //save old FFT//////////////////////////
  for (int i=0; i<fft.specSize(); i++) {
     fftOld[i] = fft.getBand(i); 
  }
  
  //Compute score///////////////////////
  fft.forward(in.mix);
  fftLog.forward(in.mix);
  
  for (int i=0; i<fft.specSize(); i++) {
     fftSmooth[i] = (1-smoothFact)*fft.getBand(i) + smoothFact*fftOld[i]; 
  }
  
  oldScoreLow = scoreLow; //save previous values
  oldScoreMid = scoreMid;
  oldScoreHi = scoreHi;
  
  scoreLow = 0; //reinitialize
  scoreMid = 0;
  scoreHi = 0;
  
  for (int i = 0; i < fft.specSize()*specLow; i++)
  {
    scoreLow += fft.getBand(i); //sum magnitudes of lower bands
  }

  for (int i = (int)(fft.specSize()*specLow); i < fft.specSize()*specMid; i++)
  {
    scoreMid += fft.getBand(i); //sum magnitudes of mid bands
  }

  for (int i = (int)(fft.specSize()*specMid); i < fft.specSize()*specHi; i++)
  {
    scoreHi += fft.getBand(i); //sum magnitudes of hi bands
  }

  //score decay
  if (oldScoreLow > scoreLow) {
    scoreLow = oldScoreLow - scoreDecreaseRate;
  }

  if (oldScoreMid > scoreMid) {
    scoreMid = oldScoreMid - scoreDecreaseRate;
  }

  if (oldScoreHi > scoreHi) {
    scoreHi = oldScoreHi - scoreDecreaseRate;
  }
  //////////////////////////////////////////////////////
  
  beat.detect(in.mix);

  //draw sphere//////////
  PShape sp = createShape(SPHERE, r*3);
  sp.setTexture(img);
  sp.setStrokeWeight(0);
  shape(sp);
  /////////////////////////////////////////////////

  //draw center cube////
  pushStyle();
  fill(scoreLow, scoreMid, scoreHi);
  strokeWeight(2);
  box(boxEdgeLength + r/12);
  //////////////////////


  int incrementLowBands = floor(fft.specSize()*specLow / 9.0);
  int incrementMidBands = floor((fft.specSize()*specMid - fft.specSize()*specLow) / 9.0);
  int incrementHiBands = floor((fft.specSize()*specHi - fft.specSize()*specMid)/9.0);
  
  //draw on 2 sides of the cube extruding rectangles using specLow////
  pushMatrix();
  for (int i = 0; i < 2; i++) {
    pushMatrix();
    translate(-r / 12, -r / 12, r / 8);
    extrusion(incrementLowBands,0, 2);
    popMatrix();
    rotateX(radians(180));
  }
  popMatrix();
  ///////////////////////////////////////////////////////

 //draw on 2 sides of the cube extruding rectangles using specMid////
  rotateX(radians(90));
  pushMatrix();
  for (int i = 0; i < 2; i++) {
    pushMatrix();
    translate(-r / 12, -r / 12, r / 8);
    extrusion(incrementMidBands,floor(fft.specSize()*specLow), 6);
    popMatrix();
    rotateX(radians(180));
  }
  popMatrix();
  ///////////////////////////////////////////////////////


  //draw on remaining 2 sides extruding rectangles using specHi////
  pushMatrix();
  rotateY(radians(90));
  for (int i = 0; i < 2; i++) {
    pushMatrix();
    translate(-r / 12, -r / 12, r / 8);
    extrusion(incrementHiBands, floor(fft.specSize()*specMid), 10);
    popMatrix();
    rotateY(radians(180));
  }
  popMatrix();
  ///////////////////////////////////////////////////

  popStyle();
  
  //calculate camera coordinates and set camera///////////////////
  camY = r / 1.75 * cos(3.75 * o);
  camX = 1.5*sqrt(sq(r) - sq(camY)) * cos(t);
  camZ = 1.5*sqrt(sq(r) - sq(camY)) * sin(t);

  camera(camX, camY, camZ, 0, 0, 0, cos(o * orientMult1), 0.2 * cos(o / 25), cos(o * orientMult2 + orientOffset));
  ////////////////////////////////////////////////////////////////

  //check rotation mode and increment parameters/////
  if (rotMode) t += radians(0.5);
  else t = radians(120) * sq(sin(a)) + tOld;
  a += radians(0.2);
  o += radians(0.2);
  ///////////////////////////////////////////////////
}

void keyPressed() {
  if (key == 'R' || key == 'r') {
    rotMode = !rotMode;
    tOld = t;
    a = 0;
  }
}

void extrusion(int inc, int offset, float scale) {
  for (int i = 0; i < 3; i++) {
    pushMatrix();
    for (int j = 0; j < 3; j++) {
      int x = (j+i*3)*inc;
      //float H = map(random(0, 10), 0, 10, 20, 80);
      float H = constrain(fftSmooth[x + offset]*scale, 0, 100);
      pushMatrix();
      translate(0, 0, H / 2);
      box(boxEdgeLength / 3, boxEdgeLength / 3, H);
      popMatrix();
      translate(boxEdgeLength / 3, 0, 0);
    }
    popMatrix();
    translate(0, r / 12, 0);
  }
}
