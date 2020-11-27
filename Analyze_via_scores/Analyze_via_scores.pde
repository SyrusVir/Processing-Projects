
import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;  
AudioInput in;
FFT fft; 
BeatDetect beat;
PFont font;
float r_width;

float specLow = 0.03;
float specMid = 0.125;
float specHi = 0.2;

float scoreLow = 0;
float scoreMid = 0;
float scoreHi = 0;

float oldScoreLow;
float oldScoreMid;
float oldScoreHi;

float scoreDecreaseRate = 25;

void setup()
{
  size(1024, 512);
  //fullScreen();
  font = createFont("Arial", 16, true);

  minim = new Minim(this);
  in = minim.getLineIn();
  fft = new FFT(in.bufferSize(), in.sampleRate());
 // fft.window(FFT.HAMMING);

  beat = new BeatDetect();

  r_width = width / fft.specSize() / specHi;
  rectMode(CORNERS);
}

void draw()
{
  float smoothFact = 0.5;
  background(0);

  fft.forward(in.mix);
  
  oldScoreLow = scoreLow;
  oldScoreMid = scoreMid;
  oldScoreHi = scoreHi;
  
  scoreLow = 0;
  scoreMid = 0;
  scoreHi = 0;
  
   for (int i = 0; i < fft.specSize()*specLow; i++)
  {
    scoreLow += fft.getBand(i);
  }

  for (int i = (int)(fft.specSize()*specLow); i < fft.specSize()*specMid; i++)
  {
    scoreMid += fft.getBand(i);
  }

  for (int i = (int)(fft.specSize()*specMid); i < fft.specSize()*specHi; i++)
  {
    scoreHi += fft.getBand(i);
  }

    if (oldScoreLow > scoreLow) {
    scoreLow = oldScoreLow - scoreDecreaseRate;
  }

  if (oldScoreMid > scoreMid) {
    scoreMid = oldScoreMid - scoreDecreaseRate;
  }

  if (oldScoreHi > scoreHi) {
    scoreHi = oldScoreHi - scoreDecreaseRate;
  }
  
  float scoreGlobal = 0.66*scoreLow + 0.8*scoreMid + 1*scoreHi;

  fill(255);
  stroke(255);
  strokeWeight(1);

  print(scoreLow, scoreMid, scoreHi, scoreGlobal, "\n");
  float[] scores = {scoreLow, scoreMid, scoreHi};
  r_width = width /3;
  for (int i = 0 ; i<fft.specSize()*specHi; i++) {
     float I = map(i, 0,fft.specSize()*specHi,0,width);
     line(I, height, I, height - fft.getBand(i)*5);
  }

}

void mousePressed() {
 
}
