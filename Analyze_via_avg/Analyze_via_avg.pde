
import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;  
AudioInput in;
FFT fft; 
BeatDetect beat;
PFont f;
float r_width;

//contains max values of each average
float[] fftMaxVals;
float[] fftSmooth;
float[] fftOld;
float smoothFact = 0.8;

void setup()
{
  size(1024, 512, P3D);
  //fullScreen();
  f = createFont("Arial", 16, true);

  minim = new Minim(this);
  in = minim.getLineIn();
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.logAverages(88, 12);
  fft.window(FFT.HAMMING);

  fftOld = new float[fft.avgSize()];
  fftMaxVals = new float[fft.avgSize()];
  for (int i=0; i<fft.avgSize(); i++) fftMaxVals[i] = 0;
  fftSmooth = new float[fft.avgSize()];

  beat = new BeatDetect();

  r_width = (float)width/fft.avgSize(); 
  rectMode(CORNERS);
  colorMode(HSB, 360, 100, 100);
  println(fft.avgSize());
}

void draw()
{
  smoothFact = 0.65;
  //precaution for controlling smoothFact in runtime
  constrain(smoothFact, 0, 1);
  
  //gets the index of the rectangle cursor is over
  int index = floor(mouseX/r_width);

  beat.detect(in.mix);
  if (beat.isOnset()) background(#0A07F2);
  else background(0);

  //analyze audio stream
  fft.forward(in.mix);

  //save previous smoothed spectrum
  arrayCopy(fftSmooth, fftOld);

  //update max values and smooth current spectrum
  for (int i=0; i<fft.avgSize(); i++) {
    if (fft.getAvg(i) > fftMaxVals[i]) fftMaxVals[i] = (fftMaxVals[i] + fft.getAvg(i))/3.0;
    fftSmooth[i] = (1-smoothFact)*fft.getAvg(i)+smoothFact*fftOld[i];
  }

  fill(255);
  stroke(0);
  strokeWeight(1);

  //draw spectrum
  for (int i = 0; i < fft.avgSize(); i++) {
    float hue = map(i, 0, fft.avgSize()-1, 0, 360);
    float sat = map(fftSmooth[i], 0, fftMaxVals[i], 0, 100);
    if (i==index) fill(#FA1A05);
    else fill(hue, sat, 100);
    rect(i*r_width, height-1, i*r_width+r_width, constrain(height-1-fftSmooth[i]*10, 0, height));
  }
}

void mousePressed() {
  int index = floor(mouseX/r_width);
  println(index,fft.getAverageCenterFrequency(index), fft.getAverageBandWidth(index), fft.getAvg(index));
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
     for (int i=0; i<fftMaxVals.length; i++) fftMaxVals[i]=0; 
  }
}
