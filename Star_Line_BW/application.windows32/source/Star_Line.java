import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.analysis.*; 
import ddf.minim.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Star_Line extends PApplet {





Minim minim;  
AudioInput in;
FFT fft; 
BeatDetect beat;
float[] scaledFFT;
float starCenterRadius = 20;
float inScaleFactor = 50;
float fftScaleFactor = 8;
float dTheta = 0;

public void setup()
{
  //size(1024, 512, P3D);
  
  
  minim = new Minim(this);
  in = minim.getLineIn();
  
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.logAverages(60,7);
  fft.window(FFT.HAMMING);
  scaledFFT = new float[fft.avgSize()];
  
  beat = new BeatDetect();
  beat.detectMode(BeatDetect.FREQ_ENERGY);
    
  rectMode(CORNERS);
  ellipseMode(RADIUS);
}

public void draw()
{
  background(0);
  
  fft.forward(in.mix); 
  beat.detect(in.mix);
  
  for (int i = 0; i < fft.avgSize(); i++) {
    scaledFFT[i] = fft.getAvg(i) * fftScaleFactor;  
  } 

  stroke(255);
  strokeWeight(2);
  translate(width/2,height/2);
  
  //reset dTheta to 0 once a full cycle is traversed. Prevent case of overflow.
  if(dTheta >= 2*PI) dTheta = 0;
  if(beat.isOnset()) dTheta -= radians(360);
  
  pushMatrix();
  rotate(dTheta);
  CWlineDraw();
  popMatrix();
  
  pushMatrix();
  rotate(-dTheta);
  CCWlineDraw();
  popMatrix();
  
  //Circle pulse
  if (starCenterRadius < 20) starCenterRadius = 20;
  noStroke();
  fill(255);
  if (beat.isHat()) starCenterRadius = 40;
  ellipse(0, 0, starCenterRadius,starCenterRadius);
   
  pushMatrix();
  for(int i = 0; i<4; i++) {
  triangle(-10,0,10,0,0,60 + starCenterRadius);
  rotate(radians(90));
  }
  popMatrix();
  
  dTheta += radians(0.30f);
  starCenterRadius *= 0.90f;
}

public void CWlineDraw() {
  stroke(255);
  strokeWeight(1);
  
  for(int j=0; j<4; j++) {
    int dummy=0;
    for(int i=0; i<in.bufferSize()-1; i++) {
      float I = map(i, 0, in.bufferSize(), 0, sqrt(sq(width/2)+sq(height/2)));
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

public void CCWlineDraw() {
  stroke(255);
  strokeWeight(1);
  
  for(int j=0; j<4; j++) {
    int dummy=0;
    for(int i=0; i<in.bufferSize()-1; i++) {
      float I = map(i, 0, in.bufferSize(), 0, sqrt(sq(width/2)+sq(height/2)));
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
  public void settings() {  fullScreen(P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Star_Line" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
