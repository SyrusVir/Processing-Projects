
import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;  
AudioInput in;
FFT fft; 
BeatDetect beat;
PFont f;
float r_width;

//contains max values of each band for normalization
float[] normVect;

float[] fftNorm;

float[] fftOld;


void setup()
{
  size(1024, 512);
  //fullScreen();
  f = createFont("Arial",16, true);
  
  minim = new Minim(this);
  in = minim.getLineIn();
  fft = new FFT(in.bufferSize(), in.sampleRate());
  //fft.logAverages(140,12);
 fft.window(FFT.HAMMING);
  
  fftOld = new float[fft.specSize()];
  beat = new BeatDetect();
    
  r_width = (float)width/fft.specSize(); 
  rectMode(CORNERS);
 
  normVect = new float[fft.specSize()];
  for (int i = 0; i < normVect.length; i++) normVect[i] = 0;

  fftNorm = new float[fft.specSize()];
}

void draw()
{
  beat.detect(in.mix);
  if (beat.isOnset()) background(0,0,255);
  else background(0);
 
  fft.forward(in.mix);
  for (int i = 0; i < fft.specSize(); i++) {
    if (fft.getBand(i) > normVect[i]) {
      normVect[i] = fft.getBand(i);
    }
    fftNorm[i] = fft.getBand(i)/normVect[i]; 
}
  float smoothFact = 0.0;
  fill(255);
  stroke(255);
  strokeWeight(0);
  
  for (int i = 0; i < fft.specSize(); i++) {
    rect(i*r_width, height-10, i*r_width+r_width, height-10-((1-smoothFact)*fft.getBand(i)+smoothFact*fftOld[i])*200);
    fftOld[i] = fft.getBand(i);
  }
  
}

void mousePressed() {
  int index = floor(mouseX / r_width);
  println(fft.indexToFreq(index));
}