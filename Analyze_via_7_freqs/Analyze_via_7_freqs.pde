
import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;  
AudioInput in;
FFT fft; 
BeatDetect beat;
PFont f;
float r_width;

float[] freqArray = {63, 160, 400, 1000, 2500, 6250, 1600};
//contains max values of each band for normalization

float[] normVect;
float[] fftNorm;
float[] fftCurr;
float[] fftOld;
float[] fftSmooth;


void setup()
{
  size(1024, 512);
  //fullScreen();
  f = createFont("Arial", 16, true);

  minim = new Minim(this);
  in = minim.getLineIn();
  fft = new FFT(in.bufferSize(), in.sampleRate());
  //fft.logAverages(140,12);
  fft.window(FFT.HAMMING);

  fftOld = new float[freqArray.length];
  normVect = new float[freqArray.length];
    for (int i = 0; i < normVect.length; i++) normVect[i] = 0;
  fftNorm = new float[freqArray.length];
  fftCurr = new float[freqArray.length];
  fftSmooth = new float[freqArray.length];

  beat = new BeatDetect();

  r_width = (float)width/freqArray.length; 
  rectMode(CORNERS);
}

void draw()
{
  float smoothFact = 0.5;
  beat.detect(in.mix);
  if (beat.isOnset()) background(0, 0, 255);
  else background(0);

  fft.forward(in.mix);
  arrayCopy(fftCurr, fftOld);

  for (int i=0; i<freqArray.length; i++) {
    float I = freqArray[i];
    fftCurr[i] = fft.getFreq(I);
    if(fftCurr[i] > normVect[i]) normVect[i] = fftCurr[i];
    fftSmooth[i] = ((1-smoothFact)*fftCurr[i] + (smoothFact*fftOld[i]));
    fftNorm[i] = fftSmooth[i]/normVect[i];
    
  }

  fill(255);
  stroke(255);
  strokeWeight(0);

  
  for (int i = 0; i < freqArray.length; i++) {
    rect(i*r_width, height-10, i*r_width+r_width, height-10-fftNorm[i]*200);
  }
}

void mousePressed() {
  int index = floor(mouseX / r_width);
  println(fft.getFreq(freqArray[index]));
}