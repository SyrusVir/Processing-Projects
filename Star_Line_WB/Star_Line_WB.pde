
import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;  
AudioInput in;
BeatDetect beat;

float starCenterRadius = 20;
float inScaleFactor = 50;
float dTheta = 0;
float rotSpeed = radians(0.03);
float oldClr = 180;
float diagonal;

boolean doFade = false;
boolean doLine = false;

AudioBuffer left;
AudioBuffer right;
AudioBuffer mix;

void setup()
{
  //size(1024, 512, P3D);
  fullScreen(P3D);

  minim = new Minim(this);
  in = minim.getLineIn();
  
  
  beat = new BeatDetect();
  beat.detectMode(BeatDetect.FREQ_ENERGY);
  left = in.left;
  right = in.right;
  mix = in.mix;
  
  //Set Draw Properties
  rectMode(CORNERS);
  ellipseMode(RADIUS);
  colorMode(HSB, 360, 100, 100);
}

void draw()
{
  background(0, 0, 0);
  diagonal = sqrt(sq(width)+sq(height))/2;
  
  beat.detect(in.mix);

  //slow down changes if no music playing///////////////
  if (mix.level() > 0.0001) rotSpeed = radians(0.3);
  else {
    rotSpeed = radians(0.03);
  }
  /////////////////////////////////////////////////////

  stroke(0);
  fill(oldClr, 0, 100);
  strokeWeight(3);
  translate(width/2, height/2); //all subsequent draws relative to center of screen
  
  //reset dTheta to 0 once a full cycle is traversed. Prevent case of overflow.
  if (dTheta >= 2*PI) dTheta = 0;
  if (beat.isSnare()) {
    dTheta += radians(12);
  }

  pushStyle(); //pop on line 93

  noStroke();
  
  //draw CW rotating lines
  pushMatrix();
  pushStyle();
  rotate(dTheta);
  lineDraw(left, 1);
  popStyle();
  popMatrix();
  //////////////////////////
  
  //draw CCW rotating lines
  pushMatrix();
  pushStyle();
  rotate(-dTheta);
  lineDraw(right, -1);
  popStyle();
  popMatrix();
  //////////////////////////
  
  //draw line for illusory reflection////
  if (doLine) {
   pushMatrix();
   pushStyle();
   translate(0,0,1);
   stroke(0);
   strokeWeight(7);
   line(-width/2,0,width/2,0);
   popStyle();
   popMatrix();
  }
  ///////////////////////////////////////
  
  //Circle pulse///////////////////////////////////////////////
  pushMatrix();
  translate(0,0,2);
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
  popMatrix();
  popStyle(); //push on line 60

  dTheta += rotSpeed;
  //dTheta %= TWO_PI;  //Gives cyclical behavior and prevents possible overflow
  starCenterRadius *= 0.90;
}

void lineDraw(AudioBuffer chan, int neg) {
  float buffSize = in.bufferSize();
  float I;
  float B;
  
  for (int j=0; j<4; j++) {
    int dummy=0;
    for (int i=0; i<buffSize-1; i++) {
      I = map(i, 0, buffSize-2, 0, diagonal);
      if (doFade) B = 100.0 * 23.00 * pow((I/diagonal), 2);
      else B = 100;
      B = constrain(B, 0, 100);
      stroke(0, 0, B);
      line(I, chan.get(i)*dummy*inScaleFactor*neg, I+1, chan.get(i+1)*dummy*inScaleFactor*neg);
      rotate(radians(45));
      line(I, -mix.get(i)*dummy*inScaleFactor*neg, I+1, -mix.get(i+1)*dummy*inScaleFactor*neg);
      rotate(radians(-45));
      //This line anchors one side of the line to the center of the circle
      dummy = 1;
    }
    rotate(radians(90));
  }
}

void keyPressed() {
 if (key == 'f' || key == 'F') {
   if (doLine && !doFade) doLine = false; //if turning fade on and line is on, turn off line
   doFade = !doFade;
 }
 if (key == 'l' || key == 'L') {
   if (doFade && !doLine) doFade = false; //if turning line on and fade is on, turn off fade
   doLine = !doLine;
 }

}
