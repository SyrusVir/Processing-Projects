
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

  minim = new Minim(this);
  in = minim.getLineIn();
  fft = new FFT(in.bufferSize(), in.sampleRate());
  
  fftOld = new float[fft.specSize()];
  beat = new BeatDetect();
    
  r_width = width/fft.specSize()*2; 
  rectMode(CORNERS);

  normVect = new float[fft.specSize()];
  for (int i = 0; i < normVect.length; i++) normVect[i] = 0;

  fftNorm = new float[fft.specSize()];
}

void draw()
{
  beat.detect(in.mix);
  if (beat.isOnset()) background(0,0,255);
  else background(255);
 
  fft.forward(in.mix);
  fill(0);
  for (int i = 0; i < fft.specSize()*0.25; i++) {
   rect(i*r_width, height, i*r_width + r_width, height - fft.getBand(i)*5); 
  }
}
