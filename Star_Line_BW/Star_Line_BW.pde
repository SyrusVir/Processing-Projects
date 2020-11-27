
import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;  
AudioInput in;
FFT fft; 
BeatDetect beat;

float[] fftOld;
float[] scaledFFT;
float[] fftMaxVals;
float[] fftSmooth;
float starCenterRadius = 20;
float inScaleFactor = 50;
float fftScaleFactor = 8;
float dTheta = 0;
float rotSpeed = radians(0.03);
float[] buff;
float oldClr = 180;
float diagonal;
float smoothFact = 0.45;
float[] activeBands;

void setup()
{
  //size(1024, 512, P3D);
  fullScreen(P3D);
  diagonal = sqrt(sq(width)+sq(height))/2;

  minim = new Minim(this);
  in = minim.getLineIn();
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.logAverages(88, 12);
  fft.window(FFT.HAMMING);
  scaledFFT = new float[fft.avgSize()];
  fftMaxVals = new float[fft.avgSize()];
  for (int i=0; i<fft.avgSize(); i++) fftMaxVals[i]=0;
  fftOld = new float[fft.avgSize()];
  fftSmooth = new float[fft.avgSize()];
  activeBands = new float[fft.avgSize()];

  beat = new BeatDetect();
  beat.detectMode(BeatDetect.FREQ_ENERGY);

  buff = new float[in.bufferSize()];

  //Set Draw Properties
  rectMode(CORNERS);
  ellipseMode(RADIUS);
  colorMode(HSB, 360, 100, 100);
}

void draw()
{
  background(0, 0, 100);

  fft.forward(in.mix); 
  beat.detect(in.mix);

  //slow down changes if no music playing///////////////
  if (in.mix.level() > 0.0001) rotSpeed = radians(0.3);
  else {
    rotSpeed = radians(0.03);
  }
  /////////////////////////////////////////////////////



  stroke(0);
  fill(oldClr, 0, 0);
  strokeWeight(5);
  translate(width/2, height/2);

  //reset dTheta to 0 once a full cycle is traversed. Prevent case of overflow.
  if (dTheta >= 2*PI) dTheta = 0;
  if (beat.isSnare()) {
    dTheta += radians(12);
  }

  pushStyle();

  noStroke();

  colorMode(HSB, 360, 100, 100);
  // RadialGradDraw(oldClr);

  pushMatrix();
  rotate(dTheta);
  CWlineDraw(oldClr-3);
  popMatrix();

  pushMatrix();
  rotate(-dTheta);
  CCWlineDraw(oldClr-3);
  popMatrix();

  //Circle pulse///////////////////////////////////////////////
  noStroke();
  if (starCenterRadius < 20) starCenterRadius = 20;
  if (beat.isHat()) starCenterRadius = 40;
  ellipse(0, 0, starCenterRadius, starCenterRadius);
  pushMatrix();
  for (int i = 0; i<4; i++) {
    triangle(-10, 0, 10, 0, 0, 60 + starCenterRadius);
    rotate(radians(90));
  }
  popMatrix();
  /////////////////////////////////////////////////////////

  popStyle();

  if (in.mix.level() > 0.001) oldClr = (oldClr + 1) % 360;
  else oldClr = (oldClr + 0.3)%360;
  if (beat.isKick()) oldClr = (oldClr + 15) % 360;

  dTheta += rotSpeed;
  starCenterRadius *= 0.90;
}

void CWlineDraw(float clr) {
  for (int j=0; j<4; j++) {
    int dummy=0;
    for (int i=0; i<in.bufferSize()-1; i++) {
      float I = map(i, 0, in.bufferSize(), 0, sqrt(sq(width/2)+sq(height/2)));
      float hue = map(I, 0, sqrt(sq(width/2)+sq(height/2)), clr, clr+180);
      stroke(hue, 0, 0);
      line(I, in.left.get(i)*dummy*inScaleFactor, I+1, in.left.get(i+1)*dummy*inScaleFactor);
      rotate(radians(45));
      line(I, -in.mix.get(i)*dummy*inScaleFactor, I+1, -in.mix.get(i+1)*dummy*inScaleFactor);
      rotate(radians(-45));
      //This line anchors one side of the line to the center of the circle
      dummy = 1;
    }
    rotate(radians(90));
  }
}

void CCWlineDraw(float clr) {
  for (int j=0; j<4; j++) {
    int dummy=0;
    for (int i=0; i<in.bufferSize()-1; i++) {
      float I = map(i, 0, in.bufferSize(), 0, sqrt(sq(width/2)+sq(height/2)));
      float hue = map(I, 0, sqrt(sq(width/2)+sq(height/2)), clr, clr+180);
      stroke(hue, 0, 0);
      line(I, -in.right.get(i)*dummy*inScaleFactor, I+1, -in.right.get(i+1)*dummy*inScaleFactor);
      rotate(radians(45));
      line(I, in.mix.get(i)*dummy*inScaleFactor, I+1, in.mix.get(i+1)*dummy*inScaleFactor);
      rotate(radians(-45));
      //This line anchors one side of the line to the center of the circle
      dummy = 1;
    }
    rotate(radians(90));
  }
}

float RadialGradDraw(float clr) {
  int rad = ceil(sqrt(sq(width) + sq(height))) / 2;
  float hue = clr;
  for (int r = rad; r >= 0; r--) {
    float R = map(r, 0, rad, hue, (hue + 180));
    fill(R%360, 100, 100);
    ellipse(0, 0, r, r);
  }
  return hue + 180;
}

int timeSeed() {
  return year()+month()+day()+hour()+minute()+second()+millis();
}
